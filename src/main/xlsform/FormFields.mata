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

	private:
		`AttribSetS' attr
		pointer(`GroupS') rowvector groups
		pointer(`RepeatS') rowvector repeats
		pointer(`FieldS') rowvector fields

		void define_attr(), get_fields()
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

end
