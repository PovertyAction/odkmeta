args(`SS' repeat)
local setof
foreach var of varlist _all {
	if "`:char `var'[<%= char_name("name") %>]'" == "SET-OF-<%= repeat %>" {
		local setof `var'
		continue, break
	}
}
assert "`setof'" != ""

