vers 11.2

matamac
matainclude ChoicesOptions ODKMetaWriter SurveyOptions

mata:

// Functional layer between -odkmeta- and `ODKMetaWriter'
void odkmeta(
	// Main
	`LclNameS' filename,
	`LclNameS' csv,
	`LclNameS' survey_command_line,
	`LclNameS' choices_command_line,
	// Fields
	`LclNameS' dropattrib,
	`LclNameS' keepattrib,
	`LclNameS' relax,
	`LclNameS' shortnames,
	// Lists
	`LclNameS' other,
	`LclNameS' oneline,
	// Non-option values
	`LclNameS' command_line
) {
	`ChoicesOptionsS' choices
	`ODKMetaWriterS' writer
	`SurveyOptionsS' survey

	survey.init(st_local(survey_command_line))
	choices.init(st_local(choices_command_line))
	writer.init(
		// Main
		st_local(filename),
		st_local(csv),
		survey,
		choices,
		// Fields
		st_local(dropattrib),
		st_local(keepattrib),
		st_local(relax) != "",
		st_local(shortnames) != "",
		// Lists
		st_local(other),
		st_local(oneline) != "",
		// Non-option values
		st_local(command_line)
	)
	writer.write_all()
}

end
