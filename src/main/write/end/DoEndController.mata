vers 11.2

matamac
matainclude DoEndBaseWriter DoFileWriter

mata:

class `DoEndController' extends `DoEndBaseWriter' {
	public:
		virtual void write(), put()
		void init(), write_all()

	private:
		`SS' filename
		`BooleanS' relax
		`DoFileWriterS' df
}

void `DoEndController'::init(`SS' filename, `BooleanS' relax)
{
	this.filename = filename
	this.relax = relax
}

void `DoEndController'::write(`SS' s)
	df.write(s)

void `DoEndController'::put(|`SS' s)
	df.put(s)

void `DoEndController'::write_all()
{
	df.open(filename)
	write_end()
	df.close()
}

end
