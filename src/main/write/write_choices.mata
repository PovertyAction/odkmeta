vers 11.2

matamac
matainclude DoFileWriter List

mata:

// See <http://www.stata.com/statalist/archive/2013-04/msg00684.html> and
// <http://www.stata.com/statalist/archive/2006-05/msg00276.html>.
transmorphic cp(transmorphic original)
{
	transmorphic copy

	copy = original
	return(copy)
}

void write_lists(`DoFileWriterS' df, `ListR' lists, `RS' oneline, |`SS' action)
{
	// "nassoc" for "number of associations"
	`RS' labdef, nlists, mindelim, maxdelim, delim, nassoc, maxspaces, i, j
	`RC' diff
	`ListS' list
	// "ls" for "lists"
	`ListR' ls

	ls = `List'(0)
	labdef = action != "encode"
	nlists = length(lists)
	for (i = 1; i <= nlists; i++) {
		list = cp(lists[i])
		// Defining the label
		if (labdef) {
			if (!list.vallab)
				list.names = strofreal(1::rows(list.names), `RealFormat')
			if (!list.matalab) {
				list.labels = adorn_quotes(strip_quotes(list.labels), "label")
			}
			ls = ls, list
		}
		// Encoding
		else if (!list.vallab) {
			// Exclude name-label associations if the name equals the label.
			diff = list.names :!= list.labels
			if (any(diff)) {
				list.names  = select(list.names,  diff)
				list.labels = select(list.labels, diff)
				ls = ls, list
			}
		}
	}

	// mindelim is the index of the list before which -#delimit ;- is required.
	// maxdelim is the index of the list after which -#delimit cr- is required.
	mindelim = maxdelim = 0
	nlists = length(ls)
	if (labdef & !oneline) {
		/* Make mindelim the index of the first list that does not require Mata.
		Make maxdelim the index of the last list that does not require Mata.
		The definitions will appear as follows:

		Lists that require Mata
		#delimit ;
		List that does not require Mata
		Lists
		List that does not require Mata
		#delimit cr
		Lists that require Mata

		All the above elements are optional. If there are no lists that do not
		require Mata, the -#delimit- commands are skipped.
		*/
		for (i = 1; i <= nlists; i++) {
			if (!ls[i].matalab) {
				mindelim = mindelim ? mindelim : i
				maxdelim = i
			}
		}
	}

	for (i = 1; i <= nlists; i++) {
		if (i == mindelim)
			df.put("#delimit ;")

		delim = i >= mindelim & i <= maxdelim
		if (!(labdef & oneline)) {
			df.put(sprintf("* %s%s", ls[i].listname, delim * ";"))
		}

		// Start of the label
		if (!labdef) {
			df.put(sprintf(`"%sif "\`list'" == "%s" {"',
				(i > 1) * "else ", ls[i].listname))
		}
		else if (!ls[i].matalab) {
			df.write("label define " + ls[i].listname)
			if (!oneline) {
				df.put("")
				df.indent()
			}
		}

		// Middle of the label: write each association.
		nassoc = length(ls[i].labels)
		if (!labdef)
			maxspaces = max(strlen(ls[i].labels))
		else if (!ls[i].matalab)
			maxspaces = max(strlen(ls[i].names))
		for (j = 1; j <= nassoc; j++) {
			// -replace-
			if (!labdef) {
				df.put(sprintf("replace \`temp' = %s%s if \`var' == %s",
					ls[i].labels[j],
					" " * (maxspaces - strlen(ls[i].labels[j])),
					ls[i].names[j]))
			}
			// -label define-
			else if (!ls[i].matalab) {
				if (oneline)
					df.write(sprintf(" %s %s", ls[i].names[j], ls[i].labels[j]))
				else {
					df.put(ls[i].names[j] +
						" " * (maxspaces - strlen(ls[i].names[j]) + 1) +
						ls[i].labels[j])
				}
			}
			// -st_vlmodify()-
			else {
				df.write(sprintf(`"mata: st_vlmodify("%s", %s, %s)"',
					ls[i].listname, ls[i].names[j], ls[i].labels[j]))
				if (delim)
					df.write(";")
				df.put("")
			}
		}

		// End of the label
		if (!labdef)
			df.put("}")
		else if (!ls[i].matalab) {
			if (delim) {
				df.indent(-1)
				df.write(";")
			}
			df.put("")
		}

		if (i == maxdelim)
			df.put("#delimit cr")
	}

	if (nlists)
		df.put("")
}

void write_sysmiss_labs(`DoFileWriterS' df, `ListR' lists)
{
	`RS' nlists, nsysmiss, i
	`SR' listnames

	listnames = J(1, 0, "")
	nlists = length(lists)
	for (i = 1; i <= nlists; i++) {
		if (any(lists[i].names :== adorn_quotes(".")))
			listnames = listnames, lists[i].listname
	}

	if (nsysmiss = length(listnames)) {
		printf("{p}{txt}note: list%s {res:%s} contain%s a name equal to " +
			`"{res:"."}. Because of the do-file's use of {cmd:insheet}, "' +
			`"it may not be possible to distinguish {res:"."} from "' +
			"{res:sysmiss}. When it is unclear, the do-file will assume that " +
			`"values equal the name {res:"."} and not {res:sysmiss}. "' +
			"See the help file for more information.{p_end}\n",
			(nsysmiss > 1) * "s", invtokens(listnames), (nsysmiss == 1) * "s")

		df.put(`"* Lists with a name equal to ".""')
		df.put("local sysmisslabs " + invtokens(listnames))
		df.put("")
	}
}

void write_other_labs(`DoFileWriterS' df, `SR' otherlists, `SS' other)
{
	`SS' otherval

	df.put(`"* Add "other" values to value labels that need them."')
	df.put("local otherlabs " + invtokens(otherlists))
	df.put("foreach lab of local otherlabs {")
	df.put(`"mata: st_vlload("\`lab'", \`values' = ., \`text' = "")"')
	if (other == "max" | other == "min") {
		df.put(sprintf(`"mata: st_local("otherval", "' +
			`"strofreal(%s, "%s"))"',
			(other == "max" ? "max(\`values') + 1" : "min(\`values') - 1"),
			`RealFormat'))
		otherval = "\`otherval'"
	}
	else
		otherval = other
	df.put("local othervals \`othervals' " + otherval)
	df.put(sprintf("label define \`lab' %s other, add", otherval))
	df.put("}")
	df.put("")
}

void write_save_label_info(`DoFileWriterS' df)
{
	df.put("* Save label information.")
	df.put("label dir")
	df.put("local labs \`r(names)'")
	df.put("foreach lab of local labs {")
	df.put("quietly label list \`lab'")
	df.put(`"* "nassoc" for "number of associations""')
	df.put("local nassoc \`nassoc' \`r(k)'")
	df.put("}")
	df.put("")
}

void write_encode_start(`DoFileWriterS' df, `SS' strlists, `SS' listnamechar,
	`SS' isotherchar)
{
	df.put("* Encode fields whose list contains a noninteger name.")
	df.put("local lists " + strlists)
	df.put("tempvar temp")
	df.put(sprintf("ds, has(char %s)", listnamechar))
	df.put("foreach var in \`r(varlist)' {")
	df.put(sprintf("local list : char \`var'[%s]", listnamechar))
	df.put(sprintf("if \`:list list in lists' & !\`:char \`var'[%s]' {",
		isotherchar))
	df.put("capture confirm numeric variable \`var'")
	df.put("if !_rc {")
	df.put(sprintf("tostring \`var', replace format(%s)", `RealFormat'))
	df.put("if !\`:list list in sysmisslabs' ///")
	df.put(`"replace \`var' = "" if \`var' == ".""')
	df.put("}")
	df.put("generate \`temp' = \`var'")
	df.put("")
}

void write_encode_end(`DoFileWriterS' df)
{
	df.put("replace \`var' = \`temp'")
	df.put("drop \`temp'")
	df.put("encode \`var', gen(\`temp') label(\`list') noextend")
	df.put("move \`temp' \`var'")
	df.put("foreach char in \`:char \`var'[]' {")
	df.put(`"mata: st_global("\`temp'[\`char']", "' +
		`"st_global("\`var'[\`char']"))"')
	df.put("}")
	df.put("drop \`var'")
	df.put("rename \`temp' \`var'")
	df.put("}")
	df.put("}")
	df.put("")
}

end
