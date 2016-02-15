vers 11.2

matamac
matainclude SurveyOptions ChoicesOptions DoStartWriter DoEndWriter ///
	ChoicesWriter

mata:

class `ODKMetaDoWriter' {
	public:
		void new(), init(), write()

	private:
		static `LclNameS' ANY_REPEAT, OTHER_LISTS, LIST_NAME_CHAR, IS_OTHER_CHAR

		// Main
		`SS' filename
		`SS' csv
		pointer(`SurveyOptionsS') scalar survey
		pointer(`ChoicesOptionsS') scalar choices
		// Fields
		`SS' dropattrib
		`SS' keepattrib
		`BooleanS' relax
		// Lists
		`SS' other
		`BooleanS' oneline
		// Non-option values
		`SS' command_line

		// tempfiles
		`SS' startdo, enddo, chardo, cleando1, cleando2, vallabdo, encodedo,
			encodetab, fulldo

		void define_tempfiles()
		void write_start(), write_survey(), write_choices(), write_end()
		void tab_file(), append_files(), copy(), append_and_save()
}

void `ODKMetaDoWriter'::new()
{
	if (ANY_REPEAT == "") {
		ANY_REPEAT = "anyrepeat"
		OTHER_LISTS = "otherlists"
		LIST_NAME_CHAR = "listnamechar"
		IS_OTHER_CHAR = "isotherchar"
	}
}

void `ODKMetaDoWriter'::init(
	// Main
	`SS' filename,
	`SS' csv,
	`SurveyOptionsS' survey,
	`ChoicesOptionsS' choices,
	// Fields
	`SS' dropattrib,
	`SS' keepattrib,
	`BooleanS' relax,
	// Lists
	`SS' other,
	`BooleanS' oneline,
	// Non-option values
	`SS' command_line
) {
	this.filename = filename
	this.csv = csv
	this.survey = &survey
	this.choices = &choices
	this.dropattrib = dropattrib
	this.keepattrib = keepattrib
	this.relax = relax
	this.other = other
	this.oneline = oneline
	this.command_line = command_line
}

void `ODKMetaDoWriter'::define_tempfiles()
{
	startdo   = st_tempfilename()
	enddo     = st_tempfilename()
	chardo    = st_tempfilename()
	cleando1  = st_tempfilename()
	cleando2  = st_tempfilename()
	vallabdo  = st_tempfilename()
	encodedo  = st_tempfilename()
	encodetab = st_tempfilename()
	fulldo    = st_tempfilename()
}

void `ODKMetaDoWriter'::write_start()
{
	`DoStartWriterS' writer
	writer.init(startdo, command_line)
	writer.write_start()
	writer.close()
}

void `ODKMetaDoWriter'::write_survey()
{
	::write_survey(
		/* output do-files */ chardo, cleando1, cleando2,
		/* output locals */
			ANY_REPEAT, OTHER_LISTS, LIST_NAME_CHAR, IS_OTHER_CHAR,
		survey->filename(), csv,
		/* column headers */
			survey->type(), survey->name(), survey->label(), survey->disabled(),
		dropattrib, keepattrib, relax
	)
}

void `ODKMetaDoWriter'::write_choices()
{
	`ChoicesWriterS' writer
	writer.init(
		// Output do-files
		vallabdo,
		encodedo,
		// -choices()- options
		*choices,
		// Characteristic names
		st_local(LIST_NAME_CHAR),
		st_local(IS_OTHER_CHAR),
		// Select/other values
		tokens(st_local(OTHER_LISTS)),
		other,
		// Other options
		oneline
	)
	writer.write_all()
}

void `ODKMetaDoWriter'::write_end()
{
	`DoEndWriterS' writer
	writer.init(enddo, relax)
	writer.write_end()
	writer.close()
}

// Add a tab to the start of each nonblank line of _infile, saving the result to
// _outfile.
void `ODKMetaDoWriter'::tab_file(`SS' _infile, `SS' _outfile)
{
	`RS' fhin, fhout
	`SM' line

	fhin = fopen(_infile, "r")
	fhout = fopen(_outfile, "w")
	while ((line = fget(fhin)) != J(0, 0, "")) {
		fput(fhout, tab(line != "") + line)
	}
	fclose(fhin)
	fclose(fhout)
}

// Append the files specified to _infiles, saving the result to _outfile.
void `ODKMetaDoWriter'::append_files(`SR' _infiles, `SS' _outfile)
{
	`RS' fhout, fhin, n, i
	`SM' line

	fhout = fopen(_outfile, "w")

	n = length(_infiles)
	for (i = 1; i <= n; i++) {
		if (fileexists(_infiles[i])) {
			fhin = fopen(_infiles[i], "r")
			while ((line = fget(fhin)) != J(0, 0, "")) {
				fput(fhout, line)
			}
			fclose(fhin)
		}
	}

	fclose(fhout)
}

void `ODKMetaDoWriter'::copy(`SS' from, `SS' to)
	stata(sprintf(`"qui copy `"%s"' `"%s"', replace"', from, to))

void `ODKMetaDoWriter'::append_and_save()
{
	// Append the do-file sections and export.
	if (strtoreal(st_local(ANY_REPEAT)) && fileexists(encodedo)) {
		tab_file(encodedo, encodetab)
		copy(encodetab, encodedo)
	}
	append_files((startdo, vallabdo, chardo, cleando1, encodedo, cleando2,
		enddo), fulldo)
	copy(fulldo, filename)
}

void `ODKMetaDoWriter'::write()
{
	define_tempfiles()
	write_start()
	write_survey()
	write_choices()
	write_end()
	append_and_save()
}

end
