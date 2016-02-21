vers 11.2

matamac
matainclude DoStartBaseWriter DoFileWriter

mata:

class `DoStartController' extends `DoStartBaseWriter' {
	public:
		virtual void write(), put()
		void init(), write_all()

	private:
		`SS' filename, command_line
		`DoFileWriterS' df

		`SS' current_date()
}

void `DoStartController'::init(`SS' filename, `SS' command_line)
{
	this.filename = filename
	this.command_line = command_line
}

void `DoStartController'::write(`SS' s)
	df.write(s)

void `DoStartController'::put(|`SS' s)
	df.put(s)

`SS' `DoStartController'::current_date()
	return(strofreal(date(c("current_date"), "DMY"), "%tdMonth_dd,_CCYY"))

void `DoStartController'::write_all()
{
	df.open(filename)
	write_start()
	df.close()
}

end
