	survey = read_csv(_survey)
	if (rows(survey) < 2)
		_error("no fields in survey sheet")

	charpre = "Odk_"
	attr = get_attribs(survey, _type, _name, _label, _disabled,
		_dropattrib, _keepattrib, charpre)

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

	pragma unset fields
	pragma unset groups
	pragma unset repeats
	get_fields(fields, groups, repeats, survey, attr)
