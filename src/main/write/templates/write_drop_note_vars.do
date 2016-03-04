* Drop note variables.
ds, has(char <%= char_name("type") %>)
foreach var in `r(varlist)' {
	if "`:char `var'[<%= char_name("type") %>]'" == "note" ///
		drop `var'
}

