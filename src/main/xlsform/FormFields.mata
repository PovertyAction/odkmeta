vers 11.2

matamac
matainclude AttribSet Field SurveyOptions

mata:

class `FormFields' {
	public:
		void init()

		pointer(`GroupS') rowvector groups()
		pointer(`RepeatS') rowvector repeats()
		pointer(`FieldS') rowvector fields()
		pointer(`AttribSetS') scalar attributes()

		`BooleanS' has_repeat(), has_field_of_type()
		`NameR' other_lists()

	private:
		`AttribSetS' attr
		pointer(`GroupS') rowvector groups
		pointer(`RepeatS') rowvector repeats
		pointer(`FieldS') rowvector fields

		void define_attr()
		void check_duplicate_group_names(), check_duplicate_repeat_names()
		void get_fields(), _get_fields(), _get_fields_base()
}

void `FormFields'::define_attr(`SM' survey,
	/* column headers */ `SS' _type, `SS' _name, `SS' _label, `SS' _disabled,
	`SS' _dropattrib, `SS' _keepattrib, `SS' charpre)
{
	`RS' dropall, keepall, cols, n, i, j
	`RR' col
	`SS' char, base
	`SR' dropattrib, keepattrib, headers, opts, notfound, newattribs,
		formattribs, chars
	pointer(`SR') p
	pointer(`AttribPropsS') scalar attrib

	// Parse _dropattrib and _keepattrib.
	dropattrib = uniqrows(tokens(_dropattrib)')'
	if (dropall = anyof(dropattrib, "_all")) {
		dropattrib = select(dropattrib, dropattrib :!= "_all")
		if (dropattrib == J(0, 0, ""))
			dropattrib = J(1, 0, "")
	}
	keepattrib = uniqrows(tokens(_keepattrib)')'
	if (keepall = anyof(keepattrib, "_all")) {
		keepattrib = select(keepattrib, keepattrib :!= "_all")
		if (keepattrib == J(0, 0, ""))
			keepattrib = J(1, 0, "")
	}

	// Issue warning messages for -dropattrib()- and -keepattrib()-.
	headers = survey[1,]
	opts = "keepattrib", "dropattrib"
	p    = &keepattrib,  &dropattrib
	for (i = 1; i <= length(opts); i++) {
		notfound = J(1, 0, "")
		for (j = 1; j <= length(*p[i]); j++) {
			if (!anyof(headers, (*p[i])[j]))
				notfound = notfound, (*p[i])[j]
		}
		if (length(notfound)) {
			printf("{p}{txt}note: option {opt %s()}: attribute%s ",
				opts[i], (length(notfound) > 1) * "s")
			for (j = 1; j <= length(notfound); j++) {
				printf("{res}%s ", adorn_quotes(notfound[j], "list"))
			}
			printf("{txt}not found.{p_end}\n")
		}
	}

	// Initial definitions of attributes in the form:
	// define .header, .form, and .special.
	// type
	attrib = attr.add("type")
	attrib->header = _type
	attrib->form = attrib->special = 1
	// name
	attrib = attr.add("name")
	attrib->header = _name
	attrib->form = attrib->special = 1
	// label
	attrib = attr.add("label")
	attrib->header = _label
	attrib->form = attrib->special = 1
	// disabled
	attrib = attr.add("disabled")
	attrib->header = _disabled
	attrib->form = 1
	attrib->special = 0
	// Other (not special) attributes
	cols = cols(survey)
	for (i = 1; i <= cols; i++) {
		// If survey has duplicate column headers, only the first column for
		// each column header is used.
		if (!anyof((attr.vals("header"), dropattrib), survey[1, i]) & !dropall &
			any(survey[|2, i \ ., i|] :!= "")) {
			attrib = attr.add(sprintf("col%f", i))
			attrib->header = survey[1, i]
			attrib->form = 1
			attrib->special = 0
		}
	}

	// Definitions of attributes not in the form
	newattribs = "bad_name", "group", "long_name", "repeat", "list_name",
		"or_other", "is_other", "geopoint"
	n = length(newattribs)
	for (i = 1; i <= n; i++) {
		attrib = attr.add(newattribs[i])
		attrib->char = charpre + newattribs[i]
		attrib->form = 0
		attrib->special = 1
		attrib->keep = !dropall
	}

	// Finish definitions of attributes in the form:
	// define .col, .char, and .keep.
	col = 1..cols
	formattribs = select(attr.vals("name"), attr.vals("form"))
	n = length(formattribs)
	for (i = 1; i <= n; i++) {
		attrib = attr.get(formattribs[i])

		// .char
		base = strlower(subinstr(strtoname(attrib->header), "`", "_", .)) //"
		while (strpos(base, "__"))
			base = subinstr(base, "__", "_", .)
		while (substr(base, -1, 1) == "_" & strlen(base) > 1)
			base = substr(base, 1, strlen(base) - 1)
		base = charpre + substr(base, 1, 32 - strlen(charpre))
		j = 2
		chars = attr.vals("char")
		char = base
		while (anyof(chars, char)) {
			char = substr(base, 1, 32 - strlen(strofreal(j, `RealFormat'))) +
				strofreal(j, `RealFormat')
			j++
		}
		attrib->char = char

		// .col
		attrib->col = min(select(col, survey[1,] :== attrib->header))

		// .keep
		if (length(dropattrib) | dropall)
			attrib->keep = !(dropall | anyof(dropattrib, attrib->header))
		else if (length(keepattrib) | keepall)
			attrib->keep = keepall | anyof(keepattrib, attrib->header)
		else
			attrib->keep = 1
	}
}

// See the comments for -_get_fields()-.
// Process rows of survey that do not contain groups or repeat groups other than
// SET-OF fields.
void `FormFields'::_get_fields_base(pointer(`FieldS') rowvector fields, `RS' fpos,
	`SM' survey, `AttribSetS' attr,
	pointer(`GroupS') scalar parentgroup,
	pointer(`RepeatS') scalar parentrepeat, `SR' odknames, `SR' stnames)
{
	`RS' rows, geopoint, other, i, j
	`SS' odkname
	`SR' dupname, suffix

	rows = rows(survey)
	for (i = 1; i <= rows; i++) {
		if (!anyof(("end group", "end repeat"),
			survey[i, attr.get("type")->col])) {
			// group
			fields[fpos]->set_group(parentgroup)
			parentgroup->add_field(fields[fpos])

			// repeat
			fields[fpos]->set_repeat(parentrepeat)
			parentrepeat->add_field(fields[fpos])

			// type
			fields[fpos]->set_type(survey[i, attr.get("type")->col])

			// name
			fields[fpos]->set_name((fields[fpos]->type() == "begin repeat") *
				("SET-OF-" + parentgroup->long_name()) +
				survey[i, attr.get("name")->col])
			// The -odkmeta- do-file assumes that KEY and PARENT_KEY do not have
			// duplicate Stata variable names with other fields.
			if (anyof(("KEY", "PARENT_KEY"), fields[fpos]->st_long())) {
				// [ID 160], [ID 161]
				errprintf("the Stata variable name of field %s%s is %s; " +
					"not allowed\n",
					fields[fpos]->long_name(),
					fields[fpos]->repeat()->inside() *
					(" in repeat group " + fields[fpos]->repeat()->name()),
					fields[fpos]->st_long())
				error_parsing(198, "survey")
				/*NOTREACHED*/
			}
			// 234 = 244 - 10, where 10 is the length of the longest variable
			// suffix ("-Longitude"). This check is necessary because -insheet-
			// is used in the do-file to create lists of field long names, and
			// -insheet- truncates strings to 244 characters.
			if (strlen(fields[fpos]->long_name()) > 234) {
				// [ID 157], [ID 158], [ID 159]
				errprintf("the long name of field %s%s exceeds " +
					"the maximum allowed 234 characters\n",
					fields[fpos]->long_name(),
					fields[fpos]->repeat()->inside() *
					(" in repeat group " + fields[fpos]->repeat()->name()))
				error_parsing(198, "survey")
				/*NOTREACHED*/
			}

			// Duplicate name
			geopoint = fields[fpos]->type() == "geopoint"
			other = regexm(fields[fpos]->type(),
				"^select_(one|multiple) .* or_other$")
			if (fields[fpos]->st_long() != "") {
				// Fields associated with a single variable with no suffix
				if (!geopoint & !other) {
					dupname = select(odknames,
						stnames :== fields[fpos]->st_long())
					if (!length(dupname)) {
						odknames = odknames, fields[fpos]->long_name()
						stnames  = stnames,  fields[fpos]->st_long()
					}
				}
				// Fields associated with multiple variables with different
				// suffixes
				else {
					dupname = J(1, 0, "")
					j = 0
					suffix = geopoint ? "-" :+ ("Latitude", "Longitude",
						"Altitude", "Accuracy") : ("", "_other")
					while (++j <= length(suffix) & !length(dupname)) {
						odkname = fields[fpos]->long_name() + suffix[j]
						dupname = select(odknames,
							stnames :== insheet_name(odkname))
						if (length(dupname))
							fields[fpos]->set_dup_var(odkname)
						else {
							odknames = odknames, odkname
							stnames  = stnames,  insheet_name(odkname)
						}
					}
				}
				if (length(dupname))
					fields[fpos]->set_other_dup_name(dupname[1])
			}

			// .label
			fields[fpos]->set_label(survey[i, attr.get("label")->col])

			// .attribs
			fields[fpos]->set_attribs(survey[i,
				select(attr.vals("col"), !attr.vals("special"))])

			fpos++
		}
	}
}

/* fields is a rowvector of pointers to the fields, groups is a rowvector of
pointers to the fields' groups, and repeats is a rowvector of pointers to the
fields' repeat groups.

fpos (for "fields position") is the index of the first element of fields in
which no field has been saved. gpos (for "groups" position) is the index of the
first element of groups in which no group has been saved. rpos (for "repeats
position") is the index of the first element of repeats in which no repeat has
been saved.

survey is the survey sheet of the form with no column headers.
attr is the field attributes.

parentgroup is a pointer to the group in which the fields of survey are nested.
parentrepeat is a pointer to the repeat group in which the fields of survey are
nested.

odknames and stnames (for "Stata names") are parallel lists that contain,
respectively, the ODK and Stata long names of the fields of parentrepeat. A
field whose Stata name is already in stnames has a duplicate Stata name. */
void `FormFields'::_get_fields(pointer(`FieldS') rowvector fields,
	pointer(`GroupS') rowvector groups, pointer(`RepeatS') rowvector repeats,
	`RS' fpos, `RS' gpos, `RS' rpos, `SM' survey, `AttribSetS' attr,
	pointer(`GroupS') scalar parentgroup,
	pointer(`RepeatS') scalar parentrepeat, `SR' odknames, `SR' stnames)
{
	`RS' rows, firstbeginrow, group, endrow
	`RC' begingroup, beginrepeat, begin, row
	`SS' name, longname
	`SR' repeatodk, repeatstata
	pointer(`RepeatS') scalar newrepeat

	rows = rows(survey)
	if (!rows)
		return

	begingroup  = survey[,attr.get("type")->col] :== "begin group"
	beginrepeat = survey[,attr.get("type")->col] :== "begin repeat"
	begin = begingroup :| beginrepeat

	if (!any(begin)) {
		_get_fields_base(fields, fpos, survey, attr, parentgroup, parentrepeat,
			odknames, stnames)
		return
	}

	row = 1::rows
	firstbeginrow = min(select(row, begin))
	// The first row is not "begin group/repeat".
	if (firstbeginrow > 1) {
		// Process the fields before the next group or repeat group.
		_get_fields(fields, groups, repeats,
			fpos, gpos, rpos, survey[|1, . \ firstbeginrow - 1, .|], attr,
			parentgroup, parentrepeat, odknames, stnames)

		// Process the remaining fields.
		_get_fields(fields, groups, repeats,
			fpos, gpos, rpos, survey[|firstbeginrow, . \ ., .|], attr,
			parentgroup, parentrepeat, odknames, stnames)
	}
	// The first row is "begin group/repeat".
	else {
		group = begingroup[firstbeginrow]
		if (group) {
			endrow = min(select(row, runningsum(begingroup -
				(survey[,attr.get("type")->col] :== "end group")) :== 0))
		}
		else {
			endrow = min(select(row, runningsum(beginrepeat -
				(survey[,attr.get("type")->col] :== "end repeat")) :== 0))
		}

		name = survey[1, attr.get("name")->col]
		longname = parentgroup->long_name() + name
		if (endrow == 2) {
			if (group) {
				// [ID 152]
				errprintf("group %s contains no fields\n", longname)
			}
			else {
				// [ID 153]
				errprintf("repeat group %s contains no fields\n", name)
			}
			error_parsing(198, "survey")
			/*NOTREACHED*/
		}
		if (endrow == .) {
			if (group) {
				// [ID 154]
				errprintf(`"group %s: "begin group" without "end group"\n"',
					longname)
			}
			else {
				// [ID 155]
				errprintf("repeat group %s: " +
					`""begin repeat" without "end repeat"\n"',
					name)
			}
			error_parsing(198, "survey")
			/*NOTREACHED*/
		}

		if (group) {
			// Add the group to groups.
			groups[gpos]->set_name(name)
			groups[gpos]->set_parent(parentgroup)
			parentgroup->add_child(groups[gpos])
			gpos++

			// Process the fields nested in the group.
			_get_fields(fields, groups, repeats,
				fpos, gpos, rpos, survey[|2, . \ endrow - 1, .|], attr,
				groups[gpos - 1], parentrepeat, odknames, stnames)
		}
		else {
			// Add the repeat group to repeats.
			newrepeat = repeats[rpos++]
			newrepeat->set_name(name)
			newrepeat->set_parent(parentrepeat)
			parentrepeat->add_child(newrepeat)
			newrepeat->set_parent_group(parentgroup)

			// Process the first row as the SET-OF field in the parent repeat
			// group.
			_get_fields_base(fields, fpos, survey[|1, . \ 1, .|], attr,
				parentgroup, parentrepeat, odknames, stnames)
			newrepeat->set_parent_set_of(fields[fpos - 1])

			// Process the fields nested in the repeat group.
			// Passing groups[1] (the main fields) as parentgroup because the
			// fields of a repeat group are treated as if they are not nested in
			// the repeat group's group.
			pragma unset repeatodk
			pragma unset repeatstata
			_get_fields(fields, groups, repeats,
				fpos, gpos, rpos, survey[|2, . \ endrow - 1, .|], attr,
				groups[1], newrepeat, repeatodk, repeatstata)

			/* Process the first row as the SET-OF field in the child repeat
			group (the newly created repeat group).
			This comes after the other fields of the repeat group because the
			SET-OF field is the last field in the .csv file. It only matters for
			determining duplicate Stata names. */
			_get_fields_base(fields, fpos, survey[|1, . \ 1, .|], attr,
				groups[1], newrepeat, repeatodk, repeatstata)
			newrepeat->set_child_set_of(fields[fpos - 1])
		}

		// Process fields outside the group or repeat group.
		if (endrow < rows) {
			_get_fields(fields, groups, repeats,
				fpos, gpos, rpos, survey[|endrow + 1, . \ ., .|], attr,
				parentgroup, parentrepeat, odknames, stnames)
		}
	}
}

void `FormFields'::check_duplicate_group_names(pointer(`GroupS') rowvector groups)
{
	`RS' n, i, j
	`SS' name

	n = length(groups)
	for (i = 1; i <= n - 1; i++) {
		for (j = i + 1; j <= n; j++) {
			if (groups[i]->long_name() == groups[j]->long_name()) {
				// [ID 150], [ID 151]
				name = groups[i]->long_name()
				// Remove the trailing hyphen.
				name = substr(name, 1, strlen(name) - 1)
				errprintf("group name %s used more than once\n", name)
				error_parsing(198, "survey")
				/*NOTREACHED*/
			}
		}
	}
}

void `FormFields'::check_duplicate_repeat_names(pointer(`RepeatS') rowvector repeats)
{
	`RS' n, i, j

	n = length(repeats)
	for (i = 1; i <= n - 1; i++) {
		for (j = i + 1; j <= n; j++) {
			if (repeats[i]->name() == repeats[j]->name()) {
				// [ID 119], [ID 120], [ID 149]
				errprintf("repeat group name %s used more than once\n",
					repeats[i]->name())
				error_parsing(198, "survey")
				/*NOTREACHED*/
			}
		}
	}
}

// See the comments for -_get_fields()-.
void `FormFields'::get_fields(pointer(`FieldS') rowvector fields,
	pointer(`GroupS') rowvector groups, pointer(`RepeatS') rowvector repeats,
	`SM' survey, `AttribSetS' attr)
{
	`RS' n, i
	`RC' begingroup, beginrepeat

	begingroup  = survey[,attr.get("type")->col] :== "begin group"
	beginrepeat = survey[,attr.get("type")->col] :== "begin repeat"

	// Initialize fields.
	n = sum(!begingroup :&
		survey[,attr.get("type")->col] :!= "end group" :&
		survey[,attr.get("type")->col] :!= "end repeat") +
		/* Double-count "begin repeat", since the associated SET-OF variable
		appears in two .csv files. */
		sum(beginrepeat)
	fields = J(1, n, NULL)
	for (i = 1; i <= n; i++) {
		fields[i] = &(`Field'())
	}

	// Initialize groups.
	// "+ 1" since the main fields are also represented as a group.
	n = sum(begingroup) + 1
	groups = J(1, n, NULL)
	for (i = 1; i <= n; i++) {
		groups[i] = &(`Group'())
	}

	// Initialize repeats.
	// "+ 1" since the main fields are also represented as a repeat group.
	n = sum(beginrepeat) + 1
	repeats = J(1, n, NULL)
	for (i = 1; i <= n; i++) {
		repeats[i] = &(`Repeat'())
	}

	// groups[1] is the group representing the main fields.
	// repeats[1] is the repeat group representing the main fields.
	_get_fields(fields, groups, repeats, 1, 2, 2, survey, attr,
		groups[1], repeats[1], J(1, 0, ""), J(1, 0, ""))

	check_duplicate_group_names(groups)
	check_duplicate_repeat_names(repeats)
}

void `FormFields'::init(`SurveyOptionsS' options, `SS' dropattrib,
	`SS' keepattrib, `NameS' charpre)
{
	`RR' col
	`SM' survey

	survey = read_csv(options.filename())
	if (rows(survey) < 2)
		_error("no fields in survey sheet")

	define_attr(survey, options.type(), options.name(), options.label(),
		options.disabled(), dropattrib, keepattrib, charpre)

	// Drop the column headers.
	survey = survey[|2, . \ ., .|]

	// Trim white space for the type, name, and disabled attributes.
	col = attr.get("type")->col, attr.get("name")->col,
		attr.get("disabled")->col
	col = select(col, col :!= .)
	survey[,col] = strtrim(stritrim(survey[,col]))

	// Exclude disabled fields.
	if (attr.get("disabled")->col != .)
		survey = select(survey, survey[,attr.get("disabled")->col] :!= "yes")
	else
		attr.drop("disabled")

	if (!rows(survey)) {
		// [ID 156], [ID 189]
		errprintf("no enabled fields in survey sheet\n")
		error_parsing(198, "survey")
		/*NOTREACHED*/
	}

	survey[,attr.get("type")->col] = stdtype(survey[,attr.get("type")->col])

	get_fields(fields, groups, repeats, survey, attr)
}

pointer(`GroupS') rowvector `FormFields'::groups()
	return(groups)

pointer(`RepeatS') rowvector `FormFields'::repeats()
	return(repeats)

pointer(`FieldS') rowvector `FormFields'::fields()
	return(fields)

pointer(`AttribSetS') scalar `FormFields'::attributes()
	return(&attr)

`BooleanS' `FormFields'::has_repeat()
	return(length(repeats) > 1)

`BooleanS' `FormFields'::has_field_of_type(`SS' type)
{
	`RS' i
	if (strpos(type, " "))
		_error("invalid type")
	for (i = 1; i <= length(fields); i++)
		if (regexm(fields[i]->type(), sprintf("^%s( |$)", type)))
			return(`True')
	return(`False')
}

`NameR' `FormFields'::other_lists()
{
	`RS' i
	`NameS' list
	`NameR' lists

	lists = J(1, 0, "")
	for (i = 1; i <= length(fields); i++) {
		if (regexm(fields[i]->type(), "^select_(one|multiple) (.+) or_other$")) {
			list = regexs(2)
			if (!anyof(lists, list))
				lists = lists, list
		}
	}

	return(lists)
}

end
