<% `SS' expression, otherval %>
* Add "other" values to value labels that need them.
local otherlabs <%= invtokens(otherlists) %>
foreach lab of local otherlabs {
	mata: st_vlload("`lab'", `values' = ., `text' = "")
	<% if (other == "max" | other == "min") { %>
		<% expression = other == "max" ? "max(\`values') + 1" : "min(\`values') - 1" %>
		mata: st_local("otherval", strofreal(<%= expression %>, "<%= `RealFormat' %>"))
		<% otherval = "\`otherval'" %>
	<% } %>
	<% else
		otherval = other %>
	local othervals `othervals' <%= otherval %>
	label define `lab' <%= otherval %> other, add
}

