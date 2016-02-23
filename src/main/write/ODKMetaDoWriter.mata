vers 11.2

matamac
matainclude SurveyOptions ChoicesOptions DoStartWriter DoEndWriter ///
	ChoicesWriter FormFields

mata:

class `ODKMetaDoWriter' {
	public:
		void new(), init(), write()

	private:
		static `NameS' CHAR_PREFIX

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

		`FormFieldsS' fields

		// tempfiles
		`SS' startdo, enddo, chardo, cleando1, cleando2, vallabdo, encodedo,
			fulldo

		void define_fields(), define_tempfiles()
		void write_start(), write_survey(), write_choices(), write_end()
		void tab_file(), append_files(), copy(), append_and_save()
}

void `ODKMetaDoWriter'::new()
{
	if (CHAR_PREFIX == "")
		CHAR_PREFIX = "Odk_"
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
	startdo  = st_tempfilename()
	enddo    = st_tempfilename()
	chardo   = st_tempfilename()
	cleando1 = st_tempfilename()
	cleando2 = st_tempfilename()
	vallabdo = st_tempfilename()
	encodedo = st_tempfilename()
	fulldo   = st_tempfilename()
}

void `ODKMetaDoWriter'::define_fields()
{
	fields = `FormFields'()
	fields.init(*survey, dropattrib, keepattrib, CHAR_PREFIX)
}

void `ODKMetaDoWriter'::write_start()
{
	`DoStartWriterS' writer
	writer.init(startdo, command_line)
	writer.write_all()
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
		// Options
		*choices,
		other,
		oneline,
		// Fields
		fields
	)
	writer.write_all()
}

void `ODKMetaDoWriter'::write_end()
{
	`DoEndWriterS' writer
	writer.init(enddo, relax)
	writer.write_all()
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

// Append the do-file sections and export.
void `ODKMetaDoWriter'::append_and_save()
{
	`SS' indented
	if (fields.has_repeat() && fileexists(encodedo)) {
		indented = st_tempfilename()
		tab_file(encodedo, indented)
		copy(indented, encodedo)
	}
	append_files((startdo, vallabdo, chardo, cleando1, encodedo, cleando2,
		enddo), fulldo)
	copy(fulldo, filename)
}

void `ODKMetaDoWriter'::write()
{
	define_fields()
	define_tempfiles()
	write_start()
	write_survey()
	write_choices()
	write_end()
	append_and_save()
}

end
