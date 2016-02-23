vers 11.2

matamac
matainclude DoFileWriter AttribSet FormFields SurveyBaseWriter

mata:

// Using `:char evarname[charname]' instead of `evarname[charname]':
// <http://www.stata.com/statalist/archive/2013-08/msg00186.html>.

class `SurveyController' extends `SurveyBaseWriter' {
	public:
		virtual void write(), put()
		void init(), write_all()

	private:
		// Output do-files
		`SS' chardo
		`SS' cleando1
		`SS' cleando2
		// Options
		`SS' csv
		`BooleanS' relax
		// Other
		pointer(`FormFieldsS') scalar fields
		`NameS' charpre

		`DoFileWriterS' df

		`SS' char_name()
		`BooleanS' insheetable_names()

		void write_survey_start()
		void write_char()
		void write_fields()
		void write_rename_for_split()
		void write_clean_before_final_save()
		void write_merge_repeat()
		void write_merge_repeats()
}

void `SurveyController'::init(
	// Output do-files
	`SS' chardo,
	`SS' cleando1,
	`SS' cleando2,
	// Options
	`SS' csv,
	`BooleanS' relax,
	// Other
	`FormFieldsS' fields,
	`NameS' charpre)
{
	this.chardo = chardo
	this.cleando1 = cleando1
	this.cleando2 = cleando2
	this.csv = csv
	this.relax = relax
	this.fields = &fields
	this.charpre = charpre
}

void `SurveyController'::write(`SS' s)
	df.write(s)

void `SurveyController'::put(|`SS' s)
	df.put(s)

`NameS' `SurveyController'::char_name(`SS' attribute)
	return(fields->attributes()->get(attribute)->char)

void `SurveyController'::write_all()
{
	`AttribSetS' attr

	attr = *fields->attributes()

	// Write the characteristics do-file, a section of the final do-file that
	// -insheet-s the .csv files and imports the characteristics.
	df.open(chardo)
	write_survey_start(df, attr, charpre)
	write_fields(df, fields->fields(), attr, csv, relax)
	df.close()

	// Write the first cleaning do-file, a section of the final do-file that
	// completes all cleaning before the -encode-ing of string lists.
	// (See `ChoicesController'.)
	df.open(cleando1)
	if (fields->has_repeat())
		write_dta_loop_start()
	if (fields->has_field_of_type("select_multiple")) {
		write_rename_for_split(df, fields->repeats())
		write_split_select_multiple()
	}
	if (fields->has_field_of_type("note"))
		write_drop_note_vars()
	write_dates_times()
	df.close()

	// Write the second cleaning do-file, a section of the final do-file that
	// completes all cleaning after the -encode-ing of string lists.

	df.open(cleando2, "w", `False')

	if (fields->has_field_of_type("select_one") ||
		fields->has_field_of_type("select_multiple"))
		write_attach_vallabs()
	if (length(fields->other_lists()))
		write_recode_or_other()

	write_field_labels()
	write_repeat_locals()

	if (!fields->has_repeat()) {
		write_clean_before_final_save(df, attr)
		write_save_dta("")
	}
	else {
		write_dta_loop_end()
		write_merge_repeats(df, fields->repeats(), attr, csv)
	}

	df.close()
}

void `SurveyController'::write_survey_start(`DoFileWriterS' df, `AttribSetS' attr, `SS' charpre)
{
	`RS' ndiffs, i
	`RR' form
	`RC' diff
	`SR' headers, chars

	form = attr.vals("form")
	headers = select(attr.vals("header"), form)
	chars   = select(attr.vals("char"),   form)

	diff = headers :!= subinstr(chars, charpre, "", 1)
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

`BooleanS' `SurveyController'::insheetable_names(pointer(`FieldS') rowvector fields,
	`SS' repeatname)
{
	`RS' i
	for (i = 1; i <= length(fields); i++)
		if (fields[i]->repeat()->long_name() == repeatname &
			fields[i]->insheet() != `InsheetOK')
			return(`False')
	return(`True')
}

void `SurveyController'::write_char(`DoFileWriterS' df, `SS' var, `SS' char, `SS' text, `SS' suffix,
	`RS' loop)
{
	`RS' autotab, nstrs
	`SS' exp

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

void `SurveyController'::write_fields(`DoFileWriterS' df, pointer(`FieldS') rowvector fields,
	`AttribSetS' attr, `SS' _csv, `RS' _relax)
{
	`RS' relax, nfields, firstrepeat, insheetmain, nattribs, ngroups, other,
		geopoint, loop, pctr, i, j
	`RC' p
	`RM' order
	`SS' var, badname, list, space
	`SR' attribchars, suffix
	`InsheetCodeS' insheet
	pointer(`GroupS') rowvector groups

	relax = _relax != 0

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
	attribchars = select(attr.vals("char"), !attr.vals("special"))
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
			write_insheet(_csv + "-" + fields[i]->repeat()->long_name() + ".csv",
				insheetable_names(fields, fields[i]->repeat()->long_name()))

			if (_relax) {
				df.put("local formnotdata")
				df.put("")
			}
		}
		// Start of the main .csv file
		else if (fields[i]->repeat()->main() & !insheetmain) {
			write_insheet(_csv + ".csv", insheetable_names(fields, ""))
			insheetmain = 1

			if (_relax) {
				df.put("local formnotdata")
				df.put("")
			}
		}

		// begin group
		groups = fields[i]->begin_groups()
		if (ngroups = length(groups)) {
			for (j = 1; j <= ngroups; j++) {
				df.put("* begin group " + groups[j]->name())
			}
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
			for (j = 1; j <= length(suffix); j++) {
				df.write(adorn_quotes(suffix[j], "list") + " ")
			}
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
			else {
				badname = "1"
			}

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
		write_char(df, var, attr.get("name")->char,
			fields[i]->name(), "", loop)
		write_char(df, var, attr.get("bad_name")->char,
			"", badname, loop)

		// Group
		if (fields[i]->group()->inside()) {
			write_char(df, var, attr.get("group")->char,
				fields[i]->group()->st_list(), "", loop)
		}
		write_char(df, var, attr.get("long_name")->char,
			fields[i]->long_name(), "", loop)

		// Repeat
		if (fields[i]->repeat()->inside()) {
			write_char(df, var, attr.get("repeat")->char,
				fields[i]->repeat()->long_name(), "", loop)
		}

		// Type
		write_char(df, var, attr.get("type")->char,
			fields[i]->type(), "", loop)
		if (prematch(fields[i]->type(), "select_one ") |
			prematch(fields[i]->type(), "select_multiple ")) {
			list = substr(fields[i]->type(),
				strpos(fields[i]->type(), " ") + 1, .)
			if (postmatch(list, " or_other"))
				list = substr(list, 1, strpos(list, " ") - 1)
			write_char(df, var, attr.get("list_name")->char,
				list, "", loop)
		}
		else if (geopoint) {
			write_char(df, var, attr.get("geopoint")->char,
				"", "\`suffix'", loop)
		}
		write_char(df, var, attr.get("or_other")->char,
			(other ? "1" : "0"), "", loop)
		if (other)
			df.put(`"local isother = "\`suffix'" != """')
		write_char(df, var, attr.get("is_other")->char,
			(other ? "" : "0"), other * "\`isother'", loop)

		// Label
		if (fields[i]->label() != "") {
			space = postmatch(fields[i]->label(), " ") ? "" : " "
			if (other) {
				df.put(sprintf("local labend " +
					`""\`=cond("\`suffix'" == "", "", "%s(Other)")'""', space))
			}
			write_char(df, var, attr.get("label")->char,
				fields[i]->label(),
				loop * (geopoint ? space + "(\`suffix')" : "\`labend'"), loop)
		}

		// Other attributes
		for (j = 1; j <= nattribs; j++) {
			write_char(df, var, attribchars[j],
				fields[i]->attrib(j), "", loop)
		}

		if (relax)
			df.put("}")

		// End the variables loop.
		if (loop)
			df.put("}")

		df.put("")

		// end group
		groups = fields[i]->end_groups()
		if (ngroups = length(groups)) {
			for (j = 1; j <= ngroups; j++) {
				df.put("* end group " + groups[j]->name())
			}
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

void `SurveyController'::write_rename_for_split(`DoFileWriterS' df,
	pointer(`RepeatS') rowvector repeats)
{
	`RS' n, i

	df.put("* Rename any variable names that are difficult for -split-.")
	n = length(repeats)
	if (n == 1)
		df.put("// rename ...")
	else {
		for (i = 1; i <= n; i++) {
			df.put(sprintf(`"%sif "\`repeat'" == %s%s {"',
				(i > 1) * "else ", adorn_quotes(repeats[i]->long_name()),
				repeats[i]->main() * " /* main fields (not a repeat group) */"))
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
void `SurveyController'::write_clean_before_final_save(`DoFileWriterS' df, `AttribSetS' attr)
{
	// Implement -dropattrib()- and -keepattrib()-.
	write_drop_attrib()
	write_compress()
}

void `SurveyController'::write_merge_repeat(`DoFileWriterS' df, pointer(`RepeatS') scalar repeat,
	`AttribSetS' attr, `BooleanS' finalsave)
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
		write_clean_before_final_save(df, attr)

	df.put("save, replace")
	df.put("")
}

void `SurveyController'::write_merge_repeats(`DoFileWriterS' df,
	pointer(`RepeatS') rowvector repeats, `AttribSetS' attr, `SS' _csv)
{
	`RS' nrepeats, pctr, i
	`RC' order, p
	// "dtaq" for ".dta (with) quotes"
	`SS' repeatcsv, dtaq

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

		repeatcsv = _csv + repeats[i]->inside() * "-" + repeats[i]->long_name()
		dtaq = adorn_quotes(repeatcsv + (strpos(repeatcsv, ".") ? ".dta" : ""),
			"list")
		df.put(sprintf("use %s, clear", dtaq))
		df.put("")

		df.put("* Rename any variable names that " +
			"are difficult for -merge- or -reshape-.")
		df.put("// rename ...")
		df.put("")

		if (length(repeats[i]->children()))
			write_merge_repeat(df, repeats[i], attr, repeats[i]->main())
		if (repeats[i]->inside()) {
			write_reshape_repeat(repeats[i])

			df.put(sprintf("use %s, clear", dtaq))
			df.put("")
			write_clean_before_final_save(df, attr)
			df.put("save, replace")
			df.put("")
		}
	}
}

end
