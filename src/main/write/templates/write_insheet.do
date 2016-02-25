args(
	// The name of the .csv file to -insheet-
	`SS' csv,
	// `True' if all field names in the .csv file can be -insheet-ed (they are
	// all `InsheetOK'); `False' otherwise.
	`BooleanS' insheetable
)
<% // "qcsv" for "quote csv"
`SS' qcsv
qcsv = adorn_quotes(csv, "list")

if (!insheetable) { %>
	insheet using <%= qcsv %>, comma nonames clear
	local fields
	foreach var of varlist _all {
		local field = trim(`var'[1])
		<% /* -parse_survey- already completes these checks for fields in the form.
		Adding them to the do-file protects against fields not in the form whose
		names cannot be -insheet-ed. For example, SubmissionDate is not in the
		form, and it would become problematic if the user could add a separate
		field with the same name to the form and this resulted in duplicate .csv
		column names. */ %>
		assert `:list sizeof field' == 1
		assert !`:list field in fields'
		local fields : list fields | field
	}

<% } %>
insheet using <%= qcsv %>, comma names case clear
<% if (!insheetable) { %>
	unab all : _all
<% } %>

