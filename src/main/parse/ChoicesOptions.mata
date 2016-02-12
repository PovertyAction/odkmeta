vers 11.2

matamac
matainclude BaseOptions

mata:

// Mata wrapper of -parse_choices-
class `ChoicesOptions' extends `BaseOptions' {
	public:
		`SS' filename(), list_name(), name(), label()
		void init()
}

void `ChoicesOptions'::init(`SS' command_line)
{
	super.init("parse_choices " + command_line,
		("fn", "listname", "name", "label"))
}

`SS' `ChoicesOptions'::filename()
	return(get("fn"))

`SS' `ChoicesOptions'::list_name()
	return(get("listname"))

`SS' `ChoicesOptions'::name()
	return(get("name"))

`SS' `ChoicesOptions'::label()
	return(get("label"))

end
