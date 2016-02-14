vers 11.2

matamac
matainclude DoFileWriter List

mata:

class `ChoicesController' extends `ChoicesBaseWriter' {
	public:
		virtual void write(), put()
		void init(), write_all()

	private:
}

void `ChoicesController'::init(
	/* output do-files */ `SS' vallabdo, `SS' encodedo,
	`SS' choices_filename,
	/* column headers */ `SS' listname_header, `SS' name_header, `SS' label_header,
	/* characteristic names */ `NameS' listnamechar, `NameS' isotherchar,
	/* other values */ `SR' otherlists, `SS' other,
	`BooleanS' oneline)
{
	this.vallabdo = vallabdo
	this.encodedo = encodedo
	this.choices_filename = choices_filename
	this.listname_header = listname_header
	this.name_header = name_header
	this.label_header = label_header
	this.listnamechar = listnamechar
	this.isotherchar = isotherchar
	this.otherlists = otherlists
	this.other = other
	this.oneline = oneline
}

void `ChoicesController'::write_all()
{
	`RS' listname, name, label, rows, nvals, nstrs, i, j
	`RR' col
	`SS' strlists
	`SR' listnames
	`SM' choices
	`DoFileWriterS' df
	`ListS' list
	`ListR' lists

	choices = read_csv(choices_filename)
	if (rows(choices) < 2)
		return

	col = 1..cols(choices)
	listname = min(select(col, choices[1,] :== listname_header))
	name     = min(select(col, choices[1,] :== name_header))
	label    = min(select(col, choices[1,] :== label_header))
	choices = choices[,(listname, name, label)]
	listname = 1
	name     = 2
	label    = 3
	choices = choices[|2, . \ ., .|]
	choices[,(listname, name)] = strtrim(choices[,(listname, name)])

	df.open(vallabdo)
	df.put("label drop _all")
	df.put("")

	if (rows = rows(choices)) {
		lists = `List'(0)
		strlists = ""
		listnames = J(1, 0, "")
		for (i = 1; i <= rows; i++) {
			if (!anyof(listnames, choices[i, listname])) {
				list.listname = choices[i, listname]
				listnames = listnames, list.listname
				list.names  = select(choices[,name],
					choices[,listname] :== list.listname)
				list.labels = select(choices[,label],
					choices[,listname] :== list.listname)
				// .vallab is 1 if list looks like an ordinary Stata value
				// label, and all its names are integers; it is 0 otherwise.
				list.vallab = !hasmissing(strtoreal(list.names)) &
					strtoreal(list.names) == floor(strtoreal(list.names)) &
					/* Distinct names can be converted to the same number, e.g.,
					1 and 01; guard against this. */
					length(uniqrows(list.names)) ==
					length(uniqrows(strtoreal(list.names)))
				if (!list.vallab)
					strlists = strlists + (strlists != "") * " " + list.listname

				// .matalab is 1 if the value label must be created in Mata; it
				// is 0 if not.
				list.matalab = 0
				nvals = length(list.names)
				for (j = 1; j <= nvals; j++) {
					if (!list.vallab)
						list.names[j] = specialexp(list.names[j])
					pragma unset nstrs
					list.labels[j] = specialexp(list.labels[j], nstrs)
					if (nstrs > 1)
						list.matalab = 1
				}

				lists = lists, list
			}
		}

		write_lists(df, lists, oneline)
		write_sysmiss_labs(df, lists)

		if (length(otherlists))
			write_other_labs(df, otherlists, other)

		write_save_label_info(df)
	}

	df.close()

	df.open(encodedo)

	if (strlists != "") {
		write_encode_start(df, strlists, listnamechar, isotherchar)
		write_lists(df, lists, oneline, "encode")
		write_encode_end(df)
	}

	df.close()
}

end
