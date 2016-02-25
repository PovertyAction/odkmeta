vers 11.2

matamac
matainclude ODKMetaBaseWriter SurveyOptions ChoicesOptions FormFields ///
	FormLists DoFileWriter

mata:

class `ODKMetaController' extends `ODKMetaBaseWriter' {
	public:
		virtual void write(), put()
		void new(), init(), write_all()

	protected:
		static `NameS' CHAR_PREFIX

		// Main
		`SS' filename
		`SS' csv
		// Fields
		`BooleanS' relax
		// Lists
		`SS' other
		`BooleanS' oneline
		// Non-option values
		`SS' command_line

		// Form
		`FormFieldsS' fields
		`FormListsS' lists

		`DoFileWriterS' df

		// Helpers
		`SS' current_date()
		`SS' string_lists()
		`TM' cp()
		`BooleanS' insheetable_names()
		`NameS' char_name()
		void copy()

	private:
		// Control logic
		void write_lists()
		void write_sysmiss_labs()
		void write_survey_start()
		void write_char()
		void write_fields()
		void write_rename_for_split()
		void write_clean_before_final_save()
		void write_merge_repeat()
		void write_merge_repeats()
}

/* -------------------------------------------------------------------------- */
					/* initialize */

void `ODKMetaController'::new()
{
	if (CHAR_PREFIX == "")
		CHAR_PREFIX = "Odk_"
}

void `ODKMetaController'::init(
	// Main
	`SS' filename,
	`SS' csv,
	`SurveyOptionsS' survey,
	`ChoicesOptionsS' choices,
	// Fields
	`SS' dropattrib,
	`SS' keepattrib,
	`BooleanS' relax,
	// Lists
	`SS' other,
	`BooleanS' oneline,
	// Non-option values
	`SS' command_line)
{
	this.filename = filename
	this.csv = csv
	this.relax = relax
	this.other = other
	this.oneline = oneline
	this.command_line = command_line

	fields.init(survey, dropattrib, keepattrib, CHAR_PREFIX)
	lists.init(choices)
}

					/* initialize */
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* override write() and put() */

void `ODKMetaController'::write(`SS' s)
	df.write(s)

void `ODKMetaController'::put(|`SS' s)
	df.put(s)

					/* override write() and put() */
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* core logic */

void `ODKMetaController'::write_all()
{
	`SS' in_progress, strlists

	in_progress = st_tempfilename()
	df.open(in_progress)

	write_do_start()

	if (lists.length() > 0) {
		write_lists()
		write_sysmiss_labs()

		if (length(fields.other_lists()))
			write_other_labs()

		write_save_label_info()
	}

	write_survey_start()
	write_fields()

	if (fields.has_repeat())
		write_dta_loop_start()

	if (fields.has_field_of_type("select_multiple")) {
		write_rename_for_split()
		write_split_select_multiple()
	}

	if (fields.has_field_of_type("note"))
		write_drop_note_vars()

	write_dates_times()

	strlists = string_lists()
	if (strlists != "") {
		write_encode_start(strlists)
		write_lists("encode")
		write_encode_end()
	}

	if (fields.has_field_of_type("select_one") ||
		fields.has_field_of_type("select_multiple"))
		write_attach_vallabs()

	if (length(fields.other_lists()))
		write_recode_or_other()

	write_field_labels()
	write_repeat_locals()

	if (!fields.has_repeat()) {
		write_clean_before_final_save()
		write_save_dta("")
	}
	else {
		write_dta_loop_end()
		write_merge_repeats()
	}

	write_do_end()

	df.close()
	copy(in_progress, filename)
}

					/* core logic */
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* helpers */

`SS' `ODKMetaController'::current_date()
	return(strofreal(date(c("current_date"), "DMY"), "%tdMonth_dd,_CCYY"))

`SS' `ODKMetaController'::string_lists()
{
	`RS' i
	`SS' strlists
	pointer(`ListS') scalar list

	pragma unset strlists
	for (i = 1; i <= lists.length(); i++) {
		list = lists.get(i)
		if (!list->vallab)
			strlists = strlists + (strlists != "") * " " + list->listname
	}

	return(strlists)
}

// See <http://www.stata.com/statalist/archive/2013-04/msg00684.html> and
// <http://www.stata.com/statalist/archive/2006-05/msg00276.html>.
`TM' `ODKMetaController'::cp(transmorphic original)
{
	transmorphic copy

	copy = original
	return(copy)
}

`BooleanS' `ODKMetaController'::insheetable_names(pointer(`FieldS') rowvector fields,
	`SS' repeatname)
{
	`RS' i
	for (i = 1; i <= length(fields); i++)
		if (fields[i]->repeat()->long_name() == repeatname &
			fields[i]->insheet() != `InsheetOK')
			return(`False')
	return(`True')
}

`NameS' `ODKMetaController'::char_name(`SS' attribute)
	return(fields.attributes()->get(attribute)->char)

void `ODKMetaController'::copy(`SS' from, `SS' to)
	stata(sprintf(`"qui copy `"%s"' `"%s"', replace"', from, to))

					/* helpers */
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* control logic */

void `ODKMetaController'::write_lists(|`SS' action)
{
	// "nassoc" for "number of associations"
	`RS' labdef, nlists, mindelim, maxdelim, delim, nassoc, maxspaces, i, j
	`RC' diff
	`ListS' list
	// "ls" for "lists"
	`ListR' ls

	ls = `List'(0)
	labdef = action != "encode"
	nlists = lists.length()
	for (i = 1; i <= nlists; i++) {
		list = cp(*lists.get(i))
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

void `ODKMetaController'::write_sysmiss_labs()
{
	`RS' nlists, nsysmiss, i
	`SR' listnames

	listnames = J(1, 0, "")
	nlists = lists.length()
	for (i = 1; i <= nlists; i++) {
		if (any(lists.get(i)->names :== adorn_quotes(".")))
			listnames = listnames, lists.get(i)->listname
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

void `ODKMetaController'::write_survey_start()
{
	`RS' ndiffs, i
	`RR' form
	`RC' diff
	`SR' headers, chars

	form = fields.attributes()->vals("form")
	headers = select(fields.attributes()->vals("header"), form)
	chars   = select(fields.attributes()->vals("char"),   form)

	diff = headers :!= subinstr(chars, CHAR_PREFIX, "", 1)
	ndiffs = sum(diff)
	headers = select(headers, diff)
	chars   = select(chars,   diff)

	df.put(sprintf("%s Import ODK attributes as characteristics.",
		(ndiffs <= 3 ? "*" : "/*")))
	for (i = 1; i <= ndiffs; i++) {
		df.put(sprintf("%s- %s will be imported to the characteristic %s.",
			(ndiffs <= 3 ? "* " : ""), headers[i], chars[i]))
	}
	if (ndiffs > 3)
		df.put("*/")
	df.put("")
}

void `ODKMetaController'::write_char(`SS' var, `SS' attribute, `SS' text, `SS' suffix,
	`RS' loop)
{
	`RS' autotab, nstrs
	`SS' exp
	`NameS' char

	char = char_name(attribute)

	if (text != "" | suffix != "") {
		pragma unset nstrs
		exp = specialexp(text, nstrs)
		if (nstrs == 1) {
			// Turning off autotab because text could contain a trailing open
			// brace that `DoFileWriter'.put() could mistake as an open block.
			autotab = df.autotab()
			df.set_autotab(0)
			df.put(sprintf("char %s[%s] %s", var, char,
				adorn_quotes(strip_quotes(exp) + suffix, "char", loop)))
			df.set_autotab(autotab)
		}
		else {
			df.put(sprintf(`"mata: st_global("%s[%s]", %s%s)"', var, char,
				exp, (suffix != "") * (" + " + adorn_quotes(suffix))))
		}
	}
}

void `ODKMetaController'::write_fields()
{
	`RS' nfields, firstrepeat, insheetmain, nattribs, ngroups, other,
		geopoint, loop, pctr, i, j
	`RC' p
	`RM' order
	`SS' var, badname, list, space
	`SR' attribchars, suffix
	`InsheetCodeS' insheet
	pointer(`FieldS') rowvector fields
	pointer(`GroupS') rowvector groups

	fields = this.fields.fields()

	// Write fields according to repeat()->order() .order().
	if (nfields = length(fields)) {
		order = J(nfields, 2, .)
		for (i = 1; i <= nfields; i++) {
			order[i, 1] = fields[i]->repeat()->order()
			order[i, 2] = fields[i]->order()
		}
		p = order(order, (1, 2))
	}

	firstrepeat = 1
	insheetmain = 0
	attribchars = select(this.fields.attributes()->vals("name"),
		!this.fields.attributes()->vals("special"))
	nattribs = length(attribchars)
	for (pctr = 1; pctr <= nfields; pctr++) {
		i = p[pctr]

		// begin repeat
		if (fields[i]->begin_repeat()) {
			// Save the main .csv file.
			if (firstrepeat) {
				write_save_dta("")
				firstrepeat = 0
			}

			df.put("* begin repeat " + fields[i]->repeat()->name())
			df.put("")
			write_insheet(csv + "-" + fields[i]->repeat()->long_name() + ".csv",
				insheetable_names(fields, fields[i]->repeat()->long_name()))

			if (relax) {
				df.put("local formnotdata")
				df.put("")
			}
		}
		// Start of the main .csv file
		else if (fields[i]->repeat()->main() & !insheetmain) {
			write_insheet(csv + ".csv", insheetable_names(fields, ""))
			insheetmain = 1

			if (relax) {
				df.put("local formnotdata")
				df.put("")
			}
		}

		// begin group
		groups = fields[i]->begin_groups()
		if (ngroups = length(groups)) {
			for (j = 1; j <= ngroups; j++)
				df.put("* begin group " + groups[j]->name())
			df.put("")
		}

		// Field start
		df.put("* " + fields[i]->name())

		// Start the variables loop.
		other = regexm(fields[i]->type(), "^select_(one|multiple) .* or_other$")
		geopoint = fields[i]->type() == "geopoint"
		// select or_other variables
		if (other)
			suffix = "", "_other"
		// geopoint variables
		else if (geopoint)
			suffix = "Latitude", "Longitude", "Altitude", "Accuracy"
		else
			suffix = ""
		if (loop = geopoint | other) {
			df.write("foreach suffix in ")
			for (j = 1; j <= length(suffix); j++)
				df.write(adorn_quotes(suffix[j], "list") + " ")
			df.put("{")
		}

		// Stata name
		insheet = fields[i]->insheet()
		if (insheet == `InsheetOK') {
			if (strlen(fields[i]->st_long()) + max(strlen(suffix)) <= 32)
				var = fields[i]->st_long() + loop * "\`suffix'"
			else {
				// `varsuf' is never blank, because if it were,
				// strlen(fields[i]->st_long()) == 32, and
				// insheet != `InsheetOK'.
				df.put(sprintf(`"local varsuf = substr("\`suffix'", 1, %f)"',
					32 - strlen(fields[i]->st_long())))
				var = fields[i]->st_long() + "\`varsuf'"
			}

			badname = "0"
		}
		else {
			// Add a comment that describes the -insheet- issue.
			if (insheet == `InsheetDup') {
				if (fields[i]->dup_var() == "") {
					df.put("* Duplicate variable name with " +
						fields[i]->other_dup_name())
				}
				else {
					df.put(sprintf("* %s: duplicate variable name with %s.",
						fields[i]->dup_var(), fields[i]->other_dup_name()))
				}
			}
			else if (insheet == `InsheetV')
				df.put("* Variable name is v#.")

			// This could lead to incorrect results if there are duplicate field
			// names. Previous code checks that this is not the case.
			df.put(sprintf("local pos : list posof %s in fields",
				adorn_quotes(fields[i]->long_name() + geopoint * "-" +
				loop * "\`suffix'")))
			df.put("local var : word \`pos' of \`all'")

			// If insheet == `InsheetV', there is only a chance that the
			// variable name differs from the field name. In a loop, some but
			// not all variables could be problematic.
			if (insheet == `InsheetV' | loop) {
				df.write(`"local isbadname = "\`var'" != "')
				if (strlen(fields[i]->st_long()) + max(strlen(suffix)) <= 32) {
					df.put(adorn_quotes(fields[i]->st_long() +
						loop * "\`suffix'"))
				}
				else {
					df.put(sprintf(`"substr(%s, 1, 32)"',
						adorn_quotes(fields[i]->st_long() +
						loop * "\`suffix'")))
				}

				badname = "\`isbadname'"
			}
			else
				badname = "1"

			var = "\`var'"
		}

		// Implement -relax-.
		if (relax) {
			df.put(sprintf("capture confirm variable %s, exact", var))
			df.put("if _rc ///")
			df.put("local formnotdata \`formnotdata' " + var)
			df.put("else {")
		}

		// Field name
		write_char(var, "name", fields[i]->name(), "", loop)
		write_char(var, "bad_name", "", badname, loop)

		// Group
		if (fields[i]->group()->inside())
			write_char(var, "group", fields[i]->group()->st_list(), "", loop)
		write_char(var, "long_name", fields[i]->long_name(), "", loop)

		// Repeat
		if (fields[i]->repeat()->inside())
			write_char(var, "repeat", fields[i]->repeat()->long_name(), "", loop)

		// Type
		write_char(var, "type", fields[i]->type(), "", loop)
		if (prematch(fields[i]->type(), "select_one ") |
			prematch(fields[i]->type(), "select_multiple ")) {
			list = substr(fields[i]->type(),
				strpos(fields[i]->type(), " ") + 1, .)
			if (postmatch(list, " or_other"))
				list = substr(list, 1, strpos(list, " ") - 1)
			write_char(var, "list_name", list, "", loop)
		}
		else if (geopoint)
			write_char(var, "geopoint", "", "\`suffix'", loop)
		write_char(var, "or_other", (other ? "1" : "0"), "", loop)
		if (other)
			df.put(`"local isother = "\`suffix'" != """')
		write_char(var, "is_other", (other ? "" : "0"), other * "\`isother'", loop)

		// Label
		if (fields[i]->label() != "") {
			space = postmatch(fields[i]->label(), " ") ? "" : " "
			if (other) {
				df.put(sprintf("local labend " +
					`""\`=cond("\`suffix'" == "", "", "%s(Other)")'""', space))
			}
			write_char(var, "label", fields[i]->label(),
				loop * (geopoint ? space + "(\`suffix')" : "\`labend'"), loop)
		}

		// Other attributes
		for (j = 1; j <= nattribs; j++)
			write_char(var, attribchars[j], fields[i]->attrib(j), "", loop)

		if (relax)
			df.put("}")

		// End the variables loop.
		if (loop)
			df.put("}")

		df.put("")

		// end group
		groups = fields[i]->end_groups()
		if (ngroups = length(groups)) {
			for (j = 1; j <= ngroups; j++)
				df.put("* end group " + groups[j]->name())
			df.put("")
		}
		// end repeat
		if (fields[i]->end_repeat()) {
			write_save_dta(fields[i]->repeat()->long_name())
			df.put("* end repeat " + fields[i]->repeat()->name())
			df.put("")
		}
	}
}

void `ODKMetaController'::write_rename_for_split()
{
	`RS' n, i
	pointer(`RepeatS') scalar repeat

	df.put("* Rename any variable names that are difficult for -split-.")
	n = length(fields.repeats())
	if (n == 1)
		df.put("// rename ...")
	else {
		for (i = 1; i <= n; i++) {
			repeat = fields.repeats()[i]
			df.put(sprintf(`"%sif "\`repeat'" == %s%s {"',
				(i > 1) * "else ", adorn_quotes(repeat->long_name()),
				repeat->main() * " /* main fields (not a repeat group) */"))
			df.put("// rename ...")
			df.put("}")
		}
	}
	df.put("")
}

// -write_clean_before_final_save()- writes code to complete final cleaning of
// an end-user dataset immediately before it is saved.
// It is destructive, dropping characteristics for instance, so
// it is usually best to limit any code between this clean and -save-.
void `ODKMetaController'::write_clean_before_final_save()
{
	write_drop_attrib()
	write_compress()
}

void `ODKMetaController'::write_merge_repeat(pointer(`RepeatS') scalar repeat,
	`BooleanS' finalsave)
{
	`RS' nchildren, multiple, i
	`SS' loopname, setof

	// Start a loop if there are multiple children.
	nchildren = length(repeat->children())
	multiple = nchildren > 1
	if (!multiple)
		loopname = repeat->child(1)->long_name()
	else {
		df.write("foreach repeat in ")
		for (i = 1; i <= nchildren; i++) {
			df.write(sprintf("%s ", repeat->child(i)->long_name()))
		}
		df.put("{")
		loopname = "\`repeat'"
	}

	// Define setof, searching for the SET-OF variable if necessary.
	if (!multiple &
		repeat->child(1)->parent_set_of()->insheet() == `InsheetOK' &
		repeat->child(1)->child_set_of()->insheet()  == `InsheetOK') {
		setof = repeat->child(1)->parent_set_of()->st_long()
	}
	else {
		write_search_set_of(loopname)
		setof = "\`setof'"
	}

	write_merge_repeat_within_loop(repeat, loopname, setof)

	// End the children loop.
	if (multiple)
		df.put("}")
	df.put("")

	if (finalsave)
		write_clean_before_final_save()

	df.put("save, replace")
	df.put("")
}

void `ODKMetaController'::write_merge_repeats()
{
	`RS' nrepeats, pctr, i
	`RC' order, p
	// "dtaq" for ".dta (with) quotes"
	`SS' repeatcsv, dtaq
	pointer(`RepeatS') rowvector repeats

	repeats = fields.repeats()

	// Write repeats according to .order().
	if (nrepeats = length(repeats)) {
		df.put("* Merge repeat groups.")
		df.put("")

		order = J(nrepeats, 1, .)
		for (i = 1; i <= nrepeats; i++) {
			order[i] = repeats[i]->order()
		}
		p = order(-order, 1)
	}

	for (pctr = 1; pctr <= nrepeats; pctr++) {
		i = p[pctr]

		df.put("* " + (repeats[i]->name() != "" ? repeats[i]->name() :
			"Main fields (not a repeat group)"))
		df.put("")

		repeatcsv = csv + repeats[i]->inside() * "-" + repeats[i]->long_name()
		dtaq = adorn_quotes(repeatcsv + (strpos(repeatcsv, ".") ? ".dta" : ""),
			"list")
		df.put(sprintf("use %s, clear", dtaq))
		df.put("")

		df.put("* Rename any variable names that " +
			"are difficult for -merge- or -reshape-.")
		df.put("// rename ...")
		df.put("")

		if (length(repeats[i]->children()))
			write_merge_repeat(repeats[i], repeats[i]->main())
		if (repeats[i]->inside()) {
			write_reshape_repeat(repeats[i])

			df.put(sprintf("use %s, clear", dtaq))
			df.put("")
			write_clean_before_final_save()
			df.put("save, replace")
			df.put("")
		}
	}
}

					/* control logic */
/* -------------------------------------------------------------------------- */

end
