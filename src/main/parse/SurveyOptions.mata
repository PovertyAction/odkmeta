vers 11.2

matamac
matainclude BaseOptions

mata:

// Mata wrapper of -parse_survey-
class `SurveyOptions' extends `BaseOptions' {
	public:
		`SS' filename(), type(), name(), label(), disabled()
		void init()
}

void `SurveyOptions'::init(`SS' command_line)
{
	super.init("parse_survey " + command_line,
		("fn", "type", "name", "label", "disabled"))
}

`SS' `SurveyOptions'::filename()
	return(get("fn"))

`SS' `SurveyOptions'::type()
	return(get("type"))

`SS' `SurveyOptions'::name()
	return(get("name"))

`SS' `SurveyOptions'::label()
	return(get("label"))

`SS' `SurveyOptions'::disabled()
	return(get("disabled"))

end
