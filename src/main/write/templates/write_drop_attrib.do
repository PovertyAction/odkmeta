<% `RS' i
`SR' drop

drop = select(fields.attributes()->vals("char"),
	!fields.attributes()->vals("keep"))
if (length(drop) == 0)
	return
drop = sort(drop', 1)' %>
foreach var of varlist _all {
	<% if (length(drop) <= 3) { %>
		<% for (i = 1; i <= length(drop); i++) { %>
			char `var'[<%= drop[i] %>]
		<% } %>
	<% } %>
	<% else { %>
		foreach char in <%= invtokens(drop) %> {
			char `var'[`char']
		}
	<% } %>
}

