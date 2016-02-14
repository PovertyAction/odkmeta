vers 11.2

matamac
matainclude DoEndBaseWriter DoFileWriter

mata:

class `DoEndController' extends `DoEndBaseWriter' {
	public:
		virtual void write(), put()
		void init(), close()

	private:
		`BooleanS' relax
		`DoFileWriterS' df
}

void `DoEndController'::init(`SS' filename, `BooleanS' relax)
{
	df.open(filename)
	this.relax = relax
}

void `DoEndController'::write(`SS' s)
	df.write(s)

void `DoEndController'::put(|`SS' s)
	df.put(s)

void `DoEndController'::close()
	df.close()

end
