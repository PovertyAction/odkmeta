vers 11.2

matamac
matainclude DoStartBaseWriter DoFileWriter

mata:

class `DoStartController' extends `DoStartBaseWriter' {
	public:
		virtual void write(), put()
		void init(), close()

	private:
		`SS' command_line
		`DoFileWriterS' df
		`SS' current_date()
}

void `DoStartController'::init(`SS' filename, `SS' command_line)
{
	df.open(filename)
	this.command_line = command_line
}

void `DoStartController'::write(`SS' s)
	df.write(s)

void `DoStartController'::put(|`SS' s)
	df.put(s)

void `DoStartController'::close()
	df.close()

`SS' `DoStartController'::current_date()
	return(strofreal(date(c("current_date"), "DMY"), "%tdMonth_dd,_CCYY"))

end
