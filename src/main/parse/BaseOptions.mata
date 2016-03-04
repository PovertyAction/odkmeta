vers 11.2

matamac

mata:

class `BaseOptions' {
	protected:
		void init()
		`SS' get()

	private:
		`AsArray' options
}

void `BaseOptions'::init(`SS' parse_command, `SR' names)
{
	`RS' i
	options = asarray_create()
	stata("cap noi " + parse_command)
	if (c("rc") != 0)
		exit(c("rc"))
	for (i = 1; i <= length(names); i++)
		asarray(options, names[i], st_global(sprintf("s(%s)", names[i])))
}

`SS' `BaseOptions'::get(`SS' name)
	return(asarray(options, name))

end
