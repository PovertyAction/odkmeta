<% `SS' repeat
repeat = fields.has_repeat() ? "\`repeat'" : "" %>
local repeats <%= adorn_quotes("\`repeats' " + adorn_quotes(repeat)) %>
<% if (fields.has_repeat()) { %>
	tempfile child
	local childfiles : list childfiles | child
<% } %>

local badnames
ds, has(char <%= char_name("bad_name") %>)
foreach var in `r(varlist)' {
	if `:char `var'[<%= char_name("bad_name") %>]' & ///
		<% /* Exclude SET-OF variables in the parent repeat groups, since they will be
		dropped. */ %>
		("`:char `var'[<%= char_name("type") %>]'" != "begin repeat" | ///
		("`repeat'" != "" & ///
		"`:char `var'[<%= char_name("name") %>]'" == "SET-OF-`repeat'")) {
		local badnames : list badnames | var
	}
}
local allbadnames `"`allbadnames' "`badnames'""'

ds, not(char <%= char_name("name") %>)
local datanotform `r(varlist)'
local exclude SubmissionDate KEY PARENT_KEY metainstanceID
local datanotform : list datanotform - exclude
local alldatanotform `"`alldatanotform' "`datanotform'""'

