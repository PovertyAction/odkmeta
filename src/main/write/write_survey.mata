vers 11.2

matamac
matainclude DoFileWriter AttribSet Field

mata:

// Using `:char evarname[charname]' instead of `evarname[charname]':
// <http://www.stata.com/statalist/archive/2013-08/msg00186.html>.

void write_survey(
	/* output do-files */ `SS' _chardo, `SS' _cleando1, `SS' _cleando2,
	/* output locals */ `SS' _anyrepeat, `SS' _otherlists, `SS' _listnamechar,
		`SS' _isotherchar,
	`SS' _survey, `SS' _csv,
	/* column headers */ `SS' _type, `SS' _name, `SS' _label, `SS' _disabled,
	`SS' _dropattrib, `SS' _keepattrib, `RS' _relax)
{
	`RS' anyselect, anymultiple, anynote, nfields, isselect, anyrepeat, i
	`RR' col
	`SS' charpre, list
	`SR' otherlists
	`SM' survey
	`DoFileWriterS' df
	`AttribSetS' attr
	pointer(`GroupS') rowvector groups
	pointer(`RepeatS') rowvector repeats
	pointer(`FieldS') rowvector fields

	// Get aggregate information about the fields.
	otherlists = J(1, 0, "")
	anyselect = anymultiple = anynote = 0
	nfields = length(fields)
	for (i = 1; i <= nfields; i++) {
		isselect = 0
		if (prematch(fields[i]->type(), "select_one "))
			isselect = anyselect = 1
		else if (prematch(fields[i]->type(), "select_multiple "))
			isselect = anyselect = anymultiple = 1
		else if (fields[i]->type() == "note")
			anynote = 1

		if (isselect) {
			list = substr(fields[i]->type(),
				strpos(fields[i]->type(), " ") + 1, .)
			if (postmatch(list, " or_other")) {
				list = substr(list, 1, strpos(list, " ") - 1)
				if (!anyof(otherlists, list))
					otherlists = otherlists, list
			}
		}
	}

	// Write the characteristics do-file, a section of the final do-file that
	// -insheet-s the .csv files and imports the characteristics.
	df.open(_chardo)

	write_survey_start(df, attr, charpre)
	write_fields(df, fields, attr, _csv, _relax)

	df.close()

	// Write the first cleaning do-file, a section of the final do-file that
	// completes all cleaning before the -encode-ing of string lists. (See
	// -write_choices()-.)
	df.open(_cleando1)

	anyrepeat = length(repeats) > 1
	if (anyrepeat)
		write_dta_loop_start(df, attr)
	if (anymultiple) {
		write_rename_for_split(df, repeats)
		write_split_select_multiple(df, attr)
	}
	if (anynote)
		write_drop_note_vars(df, attr)
	write_dates_times(df, attr)

	df.close()

	// Write the second cleaning do-file, a section of the final do-file that
	// completes all cleaning after the -encode-ing of string lists.
	df.open(_cleando2, "w", 0)

	if (anyselect)
		write_attach_vallabs(df, attr)
	if (length(otherlists))
		write_recode_or_other(df)

	write_field_labels(df, attr)
	write_repeat_locals(df, attr, (anyrepeat ? "\`repeat'" : ""), anyrepeat)

	if (!anyrepeat) {
		write_clean_before_final_save(df, attr)
		write_save_dta(df, _csv, "", anyrepeat, _relax)
	}
	else {
		write_dta_loop_end(df)
		write_merge_repeats(df, repeats, attr, _csv)
	}

	df.close()

	// Store values in the output locals.
	st_local(_anyrepeat,    strofreal(anyrepeat))
	st_local(_otherlists,   invtokens(otherlists))
	st_local(_listnamechar, attr.get("list_name")->char)
	st_local(_isotherchar,  attr.get("is_other")->char)
}

void write_survey_start(`DoFileWriterS' df, `AttribSetS' attr, `SS' charpre)
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

`RS' insheetable_names(pointer(`FieldS') rowvector fields, `SS' repeatname)
{
	`RS' insheetable, n, i

	insheetable = 1
	n = length(fields)
	for (i = 1; i <= n; i++) {
		if (fields[i]->repeat()->long_name() == repeatname)
			insheetable = insheetable & fields[i]->insheet() == `InsheetOK'
	}

	return(insheetable)
}

// csv: The name of the .csv file to -insheet-
// insheetable: 1 if all field names in the .csv file can be -insheet-ed (they
// are all `InsheetOK'); 0 otherwise.
void write_insheet(`DoFileWriterS' df, `SS' csv, `RS' insheetable)
{
	// "qcsv" for "quote csv"
	`SS' qcsv

	qcsv = adorn_quotes(csv, "list")

	if (!insheetable) {
		df.put(sprintf("insheet using %s, comma nonames clear", qcsv))
		df.put("local fields")
		df.put("foreach var of varlist _all {")
		df.put("local field = trim(\`var'[1])")
		/* -parse_survey- already completes these checks for fields in the form.
		Adding them to the do-file protects against fields not in the form whose
		names cannot be -insheet-ed. For example, SubmissionDate is not in the
		form, and it would become problematic if the user could add a separate
		field with the same name to the form and this resulted in duplicate .csv
		column names. */
		df.put(`"assert \`:list sizeof field' == 1"')
		df.put("assert !\`:list field in fields'")
		df.put("local fields : list fields | field")
		df.put("}")
		df.put("")
	}

	df.put(sprintf("insheet using %s, comma names case clear", qcsv))
	if (!insheetable)
		df.put("unab all : _all")
	df.put("")
}

void write_char(`DoFileWriterS' df, `SS' var, `SS' char, `SS' text, `SS' suffix,
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

void write_save_dta(`DoFileWriterS' df, `SS' _csv, `SS' repeat, `RS' anyrepeat,
	_relax)
{
	`SS' dta

	dta = _csv + (repeat != "") * "-" + repeat +
		(strpos(_csv, ".") ? ".dta" : "")
	df.put("local dta `" + `"""' + adorn_quotes(dta) + `"""' + "'")
	df.put(sprintf("save \`dta', %sreplace", anyrepeat * "orphans "))
	df.put("local dtas : list dtas | dta")

	// Define `allformnotdata'.
	if (_relax)
		df.put(`"local allformnotdata `"\`allformnotdata' "\`formnotdata'""'"')

	df.put("")
}

void write_fields(`DoFileWriterS' df, pointer(`FieldS') rowvector fields,
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
				write_save_dta(df, _csv, "", 1, _relax)
				firstrepeat = 0
			}

			df.put("* begin repeat " + fields[i]->repeat()->name())
			df.put("")
			write_insheet(df,
				_csv + "-" + fields[i]->repeat()->long_name() + ".csv",
				insheetable_names(fields, fields[i]->repeat()->long_name()))

			if (_relax) {
				df.put("local formnotdata")
				df.put("")
			}
		}
		// Start of the main .csv file
		else if (fields[i]->repeat()->main() & !insheetmain) {
			write_insheet(df, _csv + ".csv", insheetable_names(fields, ""))
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
			write_save_dta(df, _csv, fields[i]->repeat()->long_name(), 1,
				_relax)
			df.put("* end repeat " + fields[i]->repeat()->name())
			df.put("")
		}
	}
}

void write_dta_loop_start(`DoFileWriterS' df, `AttribSetS' attr)
{
	df.put("foreach dta of local dtas {")
	df.put(`"use "\`dta'", clear"')
	df.put("")
	df.put("unab all : _all")
	df.put("gettoken first : all")
	df.put(sprintf("local repeat : char \`first'[%s]",
		attr.get("repeat")->char))
	df.put("")
}

void write_dta_loop_end(`DoFileWriterS' df)
{
	df.put("save, replace")
	df.put("}")
	df.put("")
}

void write_rename_for_split(`DoFileWriterS' df,
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

void write_split_select_multiple(`DoFileWriterS' df, `AttribSetS' attr)
{
	df.put("* Split select_multiple variables.")
	df.put(sprintf("ds, has(char %s)", attr.get("type")->char))
	df.put("foreach typevar in \`r(varlist)' {")
	df.put(sprintf(`"if strmatch("\`:char \`typevar'[%s]'", "' +
		`""select_multiple *") & ///"', attr.get("type")->char))
	df.put(sprintf("!\`:char \`typevar'[%s]' {"', attr.get("is_other")->char))

	df.put("* Add an underscore to the variable name if it ends in a number.")
	df.put("local var \`typevar'")
	df.put(sprintf("local list : char \`var'[%s]", attr.get("list_name")->char))
	df.put(`"local pos : list posof "\`list'" in labs"')
	df.put("local nparts : word \`pos' of \`nassoc'")
	df.put(sprintf("if \`:list list in otherlabs' & " +
		"!\`:char \`var'[%s]' ///", attr.get("or_other")->char))
	df.put("local --nparts")
	df.put(`"if inrange(substr("\`var'", -1, 1), "0", "9") & ///"')
	df.put(`"length("\`var'") < 32 - strlen("\`nparts'") {"')
	df.put(`"numlist "1/\`nparts'""')
	df.put(`"local splitvars " \`r(numlist)'""')
	df.put(`"local splitvars : subinstr local splitvars " " " \`var'_", all"')
	df.put("capture confirm new variable \`var'_ \`splitvars'")
	df.put("if !_rc {")
	df.put("rename \`var' \`var'_")
	df.put("local var \`var'_")
	df.put("}")
	df.put("}")
	df.put("")

	df.put("capture confirm numeric variable \`var', exact")
	df.put("if !_rc ///")
	df.put(sprintf("tostring \`var', replace format(%s)", `RealFormat'))
	df.put("split \`var'")
	df.put("local parts \`r(varlist)'")
	df.put("local next = \`r(nvars)' + 1")
	df.put("destring \`parts', replace")
	df.put("")

	df.put("forvalues i = \`next'/\`nparts' {")
	df.put("local newvar \`var'\`i'")
	df.put("generate byte \`newvar' = .")
	df.put("local parts : list parts | newvar")
	df.put("}")
	df.put("")

	df.put("local chars : char \`var'[]")
	df.put(sprintf("local label : char \`var'[%s]", attr.get("label")->char))
	df.put("local len : length local label")
	df.put("local i 0")
	df.put("foreach part of local parts {")
	df.put("local ++i")
	df.put("")
	df.put("foreach char of local chars {")
	df.put(`"mata: st_global("\`part'[\`char']", "' +
		`"st_global("\`var'[\`char']"))"')
	df.put("}")
	df.put("")
	df.put("if \`len' {")
	df.put(sprintf(`"mata: st_global("\`part'[%s]", st_local("label") + ///"',
		attr.get("label")->char))
	df.put(`"(substr(st_local("label"), -1, 1) == " " ? "" : " ") + ///"')
	df.put(`""(#\`i'/\`nparts')")"')
	df.put("}")
	df.put("")
	df.put("move \`part' \`var'")
	df.put("}")
	df.put("")

	df.put("drop \`var'")
	df.put("}")
	df.put("}")
	df.put("")
}

void write_drop_note_vars(`DoFileWriterS' df, `AttribSetS' attr)
{
	df.put("* Drop note variables.")
	df.put(sprintf("ds, has(char %s)", attr.get("type")->char))
	df.put("foreach var in \`r(varlist)' {")
	df.put(sprintf(`"if "\`:char \`var'[%s]'" == "note" ///"',
		attr.get("type")->char))
	df.put("drop \`var'")
	df.put("}")
	df.put("")
}

void write_dates_times(`DoFileWriterS' df, `AttribSetS' attr)
{
	df.put("* Date and time variables")

	// Add a type attribute to SubmissionDate.
	df.put("capture confirm variable SubmissionDate, exact")
	df.put("if !_rc {")
	df.put(sprintf("local type : char SubmissionDate[%s]",
		attr.get("type")->char))
	df.put("assert !\`:length local type'")
	df.put(sprintf("char SubmissionDate[%s] datetime", attr.get("type")->char))
	df.put("}")

	df.put("local datetime date today time datetime start end")
	df.put("tempvar temp")
	df.put(sprintf("ds, has(char %s)", attr.get("type")->char))
	df.put("foreach var in \`r(varlist)' {")
	df.put(sprintf("local type : char \`var'[%s]", attr.get("type")->char))
	df.put("if \`:list type in datetime' {")
	df.put("capture confirm numeric variable \`var'")
	df.put("if !_rc {")
	df.put("tostring \`var', replace")
	df.put(`"replace \`var' = "" if \`var' == ".""')
	df.put("}")
	df.put("")

	// date fields
	df.put(`"if inlist("\`type'", "date", "today") {"')
	df.put("local fcn    date")
	df.put("local mask   " + `DateMask')
	df.put("local format %tdMon_dd,_CCYY")
	df.put("}")
	// time fields
	df.put(`"else if "\`type'" == "time" {"')
	df.put("local fcn    clock")
	df.put("local mask   " + `TimeMask')
	df.put("local format %tchh:MM:SS_AM")
	df.put("}")
	// datetime fields
	df.put(`"else if inlist("\`type'", "datetime", "start", "end") {"')
	df.put("local fcn    clock")
	df.put("local mask   " + `DatetimeMask')
	df.put("local format %tcMon_dd,_CCYY_hh:MM:SS_AM")
	df.put("}")
	// -generate-
	df.put(`"generate double \`temp' = \`fcn'(\`var', "\`\`mask''")"')
	df.put("format \`temp' \`format'")
	df.put("count if missing(\`temp') & !missing(\`var')")
	df.put("if r(N) {")
	df.put(`"display as err "{p}""')
	df.put(`"display as err "\`type' variable \`var'""')
	df.put(`"if "\`repeat'" != "" ///"')
	df.put(`"display as err "in repeat group \`repeat'""')
	df.put("display as err " +
		`""could not be converted using the mask \`\`mask''""')
	df.put(`"display as err "{p_end}""')
	df.put("exit 9")
	df.put("}")
	df.put("")

	df.put("move \`temp' \`var'")
	df.put("foreach char in \`:char \`var'[]' {")
	df.put(`"mata: st_global("\`temp'[\`char']", "' +
		`"st_global("\`var'[\`char']"))"')
	df.put("}")
	df.put("drop \`var'")
	df.put("rename \`temp' \`var'")
	df.put("}")
	df.put("}")

	// Remove the type attribute from SubmissionDate.
	df.put("capture confirm variable SubmissionDate, exact")
	df.put("if !_rc ///")
	df.put(sprintf("char SubmissionDate[%s]", attr.get("type")->char))
	df.put("")
}

void write_attach_vallabs(`DoFileWriterS' df, `AttribSetS' attr)
{
	df.put("* Attach value labels.")
	df.put("ds, not(vallab)")
	df.put(`"if "\`r(varlist)'" != "" ///"')
	df.put(sprintf("ds \`r(varlist)', has(char %s)",
		attr.get("list_name")->char))
	df.put("foreach var in \`r(varlist)' {")
	df.put(sprintf("if !\`:char \`var'[%s]' {", attr.get("is_other")->char))
	df.put("capture confirm string variable \`var', exact")
	df.put("if !_rc {")
	df.put(`"replace \`var' = ".o" if \`var' == "other""')
	df.put("destring \`var', replace")
	df.put("}")
	df.put("")

	df.put(sprintf("local list : char \`var'[%s]", attr.get("list_name")->char))
	df.put("if !\`:list list in labs' {")
	df.put(`"display as err "list \`list' not found in choices sheet""')
	df.put("exit 9")
	df.put("}")
	df.put("label values \`var' \`list'")
	df.put("}")
	df.put("}")
	df.put("")
}

void write_recode_or_other(`DoFileWriterS' df)
{
	df.put("* select or_other variables")
	df.put("forvalues i = 1/\`:list sizeof otherlabs' {")
	df.put("local lab      : word \`i' of \`otherlabs'")
	df.put("local otherval : word \`i' of \`othervals'")
	df.put("")
	df.put("ds, has(vallab \`lab')")
	df.put(`"if "\`r(varlist)'" != "" ///"')
	df.put("recode \`r(varlist)' (.o=\`otherval')")
	df.put("}")
	df.put("")
}

void write_field_labels(`DoFileWriterS' df, `AttribSetS' attr)
{
	`SS' notepre

	notepre = "Question text: "

	df.put("* Attach field labels as variable labels and notes.")
	df.put(sprintf("ds, has(char %s)", attr.get("long_name")->char))
	df.put("foreach var in \`r(varlist)' {")
	df.put("* Variable label")
	df.put(sprintf("local label : char \`var'[%s]", attr.get("label")->char))
	df.put(`"mata: st_varlabel("\`var'", st_local("label"))"')
	df.put("")

	df.put("* Notes")
	df.put("if \`:length local label' {")
	df.put("char \`var'[note0] 1")
	df.put(sprintf(`"mata: st_global("\`var'[note1]", %s + ///"',
		adorn_quotes(notepre)))
	df.put(sprintf(`"st_global("\`var'[%s]"))"', attr.get("label")->char))
	df.put(`"mata: st_local("temp", ///"')
	df.put(`"" " * (strlen(st_global("\`var'[note1]")) + 1))"')
	df.put("#delimit ;")
	df.put("local fromto")
	df.indent()
	df.put(sprintf(`"{%s"\`temp'""', tab(3)))
	df.put(sprintf(`"}%s"{c )-}""', tab(3)))
	df.put(sprintf(`""\`temp'"%s"{c -(}""', tab()))
	df.put(sprintf(`"'%s"{c 39}""', tab(3)))
	df.put(sprintf(`"""' + "`" + `""%s"{c 'g}""', tab(3)))
	df.put(sprintf(`""$"%s"{c S|}""', tab(3)))
	df.indent(-1)
	df.put(";")
	df.put("#delimit cr")
	df.put("while \`:list sizeof fromto' {")
	df.put("gettoken from fromto : fromto")
	df.put("gettoken to   fromto : fromto")
	df.put(`"mata: st_global("\`var'[note1]", ///"')
	df.put(`"subinstr(st_global("\`var'[note1]"), "\`from'", "\`to'", .))"')
	df.put("}")
	df.put("}")
	df.put("}")
	df.put("")
}

void write_compress(`DoFileWriterS' df)
{
	df.put("compress")
	df.put("")
}

void write_repeat_locals(`DoFileWriterS' df, `AttribSetS' attr, `SS' repeat,
	`RS' anyrepeat)
{
	// Define `repeats'.
	df.put("local repeats " +
		adorn_quotes("\`repeats' " + adorn_quotes(repeat)))
	// Define `childfiles.
	if (anyrepeat) {
		df.put("tempfile child")
		df.put("local childfiles : list childfiles | child")
	}
	df.put("")

	// Define `allbadnames'.
	df.put("local badnames")
	df.put(sprintf("ds, has(char %s)", attr.get("bad_name")->char))
	df.put("foreach var in \`r(varlist)' {")
	df.put(sprintf(`"if \`:char \`var'[%s]' & ///"',
		attr.get("bad_name")->char))
	// Exclude SET-OF variables in the parent repeat groups, since they will be
	// dropped.
	df.put(sprintf(`"("\`:char \`var'[%s]'" != "begin repeat" | ///"',
		attr.get("type")->char))
	df.put(`"("\`repeat'" != "" & ///"')
	df.put(sprintf(`""\`:char \`var'[%s]'" == "SET-OF-\`repeat'")) {"',
		attr.get("name")->char))
	df.put("local badnames : list badnames | var")
	df.put("}")
	df.put("}")
	df.put(`"local allbadnames `"\`allbadnames' "\`badnames'""'"')
	df.put("")

	// Define `alldatanotform'.
	df.put(sprintf("ds, not(char %s)", attr.get("name")->char))
	df.put("local datanotform \`r(varlist)'")
	df.put("local exclude SubmissionDate KEY PARENT_KEY metainstanceID")
	df.put("local datanotform : list datanotform - exclude")
	df.put(`"local alldatanotform `"\`alldatanotform' "\`datanotform'""'"')
	df.put("")
}

// Implement -dropattrib()- and -keepattrib()-.
void write_drop_attrib(`DoFileWriterS' df, `AttribSetS' attr)
{
	`RS' n, i
	`SR' drop

	drop = select(attr.vals("char"), !attr.vals("keep"))
	if (n = length(drop)) {
		drop = sort(drop', 1)'
		df.put("foreach var of varlist _all {")
		if (n <= 3) {
			for (i = 1; i <= n; i++) {
				df.put(sprintf("char \`var'[%s]", drop[i]))
			}
		}
		else {
			df.write("foreach char in ")
			for (i = 1; i <= n; i++) {
				df.write(drop[i] + " ")
			}
			df.put("{")
			df.put(sprintf("char \`var'[\`char']"))
			df.put("}")
		}
		df.put("}")
		df.put("")
	}
}

// -write_clean_before_final_save()- writes code to complete final cleaning of
// an end-user dataset immediately before it is saved.
// It is destructive, dropping characteristics for instance, so
// it is usually best to limit any code between this clean and -save-.
void write_clean_before_final_save(`DoFileWriterS' df, `AttribSetS' attr)
{
	write_drop_attrib(df, attr)
	write_compress(df)
}

void write_search_set_of(`DoFileWriterS' df, `AttribSetS' attr, `SS' repeat)
{
	df.put("local setof")
	df.put("foreach var of varlist _all {")
	df.put(sprintf(`"if "\`:char \`var'[%s]'" == "SET-OF-%s" {"',
		attr.get("name")->char, repeat))
	df.put("local setof \`var'")
	df.put("continue, break")
	df.put("}")
	df.put("}")
	df.put(`"assert "\`setof'" != """')
	df.put("")
}

void write_merge_repeat(`DoFileWriterS' df, pointer(`RepeatS') scalar repeat,
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
		df.put("tempvar merge")
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
		write_search_set_of(df, attr, loopname)
		setof = "\`setof'"
	}

	// Prepare merge.

	// Variable order
	df.put("unab before : _all")
	// Check that there is no unexpected variable list overlap.
	df.put(sprintf(`"local pos : list posof %s in repeats"',
		adorn_quotes(loopname)))
	df.put("local child : word \`pos' of \`childfiles'")
	df.put("describe using \`child', varlist")
	df.put("local childvars \`r(varlist)'")
	df.put("local overlap : list before & childvars")
	df.put("local KEY KEY")
	df.put("local overlap : list overlap - KEY")
	df.put("quietly if \`:list sizeof overlap' {")
	df.put("gettoken first : overlap")
	df.put(sprintf("noisily display as err " +
		`""error merging %s and repeat group %s""',
		(repeat->main() ? "the main fields" :
		"repeat group " + repeat->long_name()), loopname))
	df.put("noisily display as err " +
		`""variable \`first' exists in both datasets""')
	df.put("noisily display as err " +
		`""rename it in one or both, then try again""')
	df.put("exit 9")
	df.put("}")
	df.put("")

	// Sort order
	df.put("tempvar order")
	df.put("generate \`order' = _n")

	// Merge.
	df.put("if !_N ///")
	df.put("tostring KEY, replace")
	if (!multiple)
		df.put("tempvar merge")
	df.put("merge KEY using \`child', sort _merge(\`merge')")
	df.put("tabulate \`merge'")
	df.put("assert \`merge' != 2")

	// Clean up.
	// Sort order
	// This sort may be unnecessary: -merge- may complete it automatically.
	// However, this is not assured in the documentation, and the -reshape-
	// requires it. (Otherwise, _j could be incorrect.)
	df.put("sort \`order'")
	df.put("drop \`order' \`merge'")
	df.put("")
	// Variable order
	df.put("unab after : _all")
	df.put("local new : list after - before")
	df.put("foreach var of local new {")
	df.put("move \`var' " + setof)
	df.put("}")
	df.put("drop " + setof)

	// End the children loop.
	if (multiple)
		df.put("}")
	df.put("")

	if (finalsave)
		write_clean_before_final_save(df, attr)

	df.put("save, replace")
	df.put("")
}

void write_reshape_repeat(`DoFileWriterS' df, pointer(`RepeatS') scalar repeat,
	`AttribSetS' attr)
{
	`SS' mergekey

	// Drop KEY and the SET-OF variable, which will be unused.
	if (repeat->child_set_of()->insheet() == `InsheetOK')
		df.put("drop KEY " + repeat->child_set_of()->st_long())
	else {
		df.put("drop KEY")
		df.put("foreach var of varlist _all {")
		df.put(sprintf(`"if "\`:char \`var'[%s]'" == "SET-OF-%s" {"',
			attr.get("name")->char, repeat->name()))
		df.put("drop \`var'")
		df.put("continue, break")
		df.put("}")
		df.put("}")
	}
	df.put("")

	mergekey = "PARENT_KEY"

	// Rename variables that end in a number.
	df.put("* Add an underscore to variable names that end in a number.")
	df.put(sprintf("ds %s, not", mergekey))
	df.put("foreach var in \`r(varlist)' {")
	df.put(sprintf(`"if inrange(substr("\`var'", -1, 1), "0", "9") & "' +
		`"length("\`var'") < %f {"',
		32 - repeat->level()))
	df.put("capture confirm new variable \`var'_")
	df.put("if !_rc ///")
	df.put("rename \`var' \`var'_")
	df.put("}")
	df.put("}")
	df.put("")

	// Positive number of observations
	df.put("if _N {")

	// Reshape.
	df.put("tempvar j")
	df.put(sprintf("sort %s, stable", mergekey))
	df.put(sprintf("by %s: generate \`j' = _n", mergekey))
	df.put(sprintf("ds %s \`j', not", mergekey))
	df.put(sprintf("reshape wide \`r(varlist)', i(%s) j(\`j')", mergekey))
	df.put("")

	// Restore variable labels.
	df.put("* Restore variable labels.")
	df.put("foreach var of varlist _all {")
	df.put(sprintf(`"mata: st_varlabel("\`var'", st_global("\`var'[%s]"))"',
		attr.get("label")->char))
	df.put("}")

	// Zero observations
	df.put("}")
	df.put("else {")
	df.put(sprintf("ds %s, not", mergekey))
	df.put("foreach var in \`r(varlist)' {")
	df.put("ren \`var' \`var'1")
	df.put("}")
	df.put("")
	df.put("drop " + mergekey)
	df.put(sprintf(`"gen %s = """', mergekey))
	df.put("}")
	df.put("")

	df.put("rename PARENT_KEY KEY")
	df.put("")

	// Save.
	df.put(sprintf(`"local pos : list posof %s in repeats"',
		adorn_quotes(repeat->long_name())))
	df.put("local child : word \`pos' of \`childfiles'")
	df.put("save \`child'")
	df.put("")
}

void write_merge_repeats(`DoFileWriterS' df,
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
			write_reshape_repeat(df, repeats[i], attr)

			df.put(sprintf("use %s, clear", dtaq))
			df.put("")
			write_clean_before_final_save(df, attr)
			df.put("save, replace")
			df.put("")
		}
	}
}

end
