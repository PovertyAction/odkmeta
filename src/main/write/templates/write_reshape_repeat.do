args(pointer(`RepeatS') scalar repeat)
<% `SS' mergekey %>
<% // Drop KEY and the SET-OF variable, which will be unused. %>
<% if (repeat->child_set_of()->insheet() == `InsheetOK') { %>
	drop KEY <%= repeat->child_set_of()->st_long() %>
<% } %>
<% else { %>
	drop KEY
	foreach var of varlist _all {
		if "`:char `var'[<%= char_name("name") %>]'" == "SET-OF-<%= repeat->name() %>" {
			drop `var'
			continue, break
		}
	}
<% } %>

<% mergekey = "PARENT_KEY" %>
* Add an underscore to variable names that end in a number.
ds <%= mergekey %>, not
foreach var in `r(varlist)' {
	if inrange(substr("`var'", -1, 1), "0", "9") & length("`var'") < <%= strofreal(32 - repeat->level()) %> {
		capture confirm new variable `var'_
		if !_rc ///
			rename `var' `var'_
	}
}

if _N {
	tempvar j
	sort <%= mergekey %>, stable
	by <%= mergekey %>: generate `j' = _n
	ds <%= mergekey %> `j', not
	reshape wide `r(varlist)', i(<%= mergekey %>) j(`j')

	* Restore variable labels.
	foreach var of varlist _all {
		mata: st_varlabel("`var'", st_global("`var'[<%= char_name("label") %>]"))
	}
}
else {
	ds <%= mergekey %>, not
	foreach var in `r(varlist)' {
		ren `var' `var'1
	}

	drop <%= mergekey %>
	gen <%= mergekey %> = ""
}

rename PARENT_KEY KEY

local pos : list posof <%= adorn_quotes(repeat->long_name()) %> in repeats
local child : word `pos' of `childfiles'
save `child'

