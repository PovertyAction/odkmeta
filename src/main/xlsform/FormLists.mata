vers 11.2

matamac
matainclude List ChoicesOptions

mata:

class `FormLists' {
	public:
		`RS' length()
		pointer(`ListS') scalar get()
		void init()

	private:
		`ListR' lists
}

void `FormLists'::init(`ChoicesOptionsS' options)
{
	`RS' listname, name, label, nvals, nstrs, i, j
	`RR' col
	`SR' listnames
	`SM' choices
	`ListS' list

	lists = `List'(0)

	choices = read_csv(options.filename())
	if (rows(choices) < 2)
		return

	col = 1..cols(choices)
	listname = min(select(col, choices[1,] :== options.list_name()))
	name     = min(select(col, choices[1,] :== options.name()))
	label    = min(select(col, choices[1,] :== options.label()))
	choices = choices[,(listname, name, label)]
	listname = 1
	name     = 2
	label    = 3
	choices = choices[|2, . \ ., .|]
	choices[,(listname, name)] = strtrim(choices[,(listname, name)])

	if (rows(choices) == 0)
		return

	listnames = J(1, 0, "")
	for (i = 1; i <= rows(choices); i++) {
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
				(::length(uniqrows(list.names))) ==
				(::length(uniqrows(strtoreal(list.names))))

			// .matalab is 1 if the value label must be created in Mata; it
			// is 0 if not.
			list.matalab = 0
			nvals = ::length(list.names)
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
}

`RS' `FormLists'::length()
	return(::length(lists))

pointer(`ListS') scalar `FormLists'::get(`RS' index)
	return(&lists[index])

end
