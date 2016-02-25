* Attach value labels.
ds, not(vallab)
if "`r(varlist)'" != "" ///
	ds `r(varlist)', has(char <%= char_name("list_name") %>)
foreach var in `r(varlist)' {
	if !`:char `var'[<%= char_name("is_other") %>]' {
		capture confirm string variable `var', exact
		if !_rc {
			replace `var' = ".o" if `var' == "other"
			destring `var', replace
		}

		local list : char `var'[<%= char_name("list_name") %>]
		if !`:list list in labs' {
			display as err "list `list' not found in choices sheet"
			exit 9
		}
		label values `var' `list'
	}
}

