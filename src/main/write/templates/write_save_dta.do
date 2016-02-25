args(`SS' repeat)
<% `SS' dta
dta = csv + (repeat != "") * "-" + repeat + (strpos(csv, ".") ? ".dta" : "") %>
local dta `"<%= adorn_quotes(dta) %>"'
save `dta', <%= fields.has_repeat() ? "orphans " : "" %>replace
local dtas : list dtas | dta
<% if (relax) { %>
	local allformnotdata `"`allformnotdata' "`formnotdata'""'
<% } %>

