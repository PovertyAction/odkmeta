vers 11.2

matamac
matainclude ChoicesOptions ODKMetaDoWriter SurveyOptions

mata:

// Functional layer between -odkmeta- and `ODKMetaDoWriter'
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
	// Lists
	`LclNameS' other,
	`LclNameS' oneline,
	// Non-option values
	`LclNameS' command_line
) {
	`ChoicesOptionsS' choices
	`ODKMetaDoWriterS' writer
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
		// Lists
		st_local(other),
		st_local(oneline) != "",
		// Non-option values
		st_local(command_line)
	)
	writer.write()
}

end
