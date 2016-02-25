* Split select_multiple variables.
ds, has(char <%= char_name("type") %>)
foreach typevar in `r(varlist)' {
	if strmatch("`:char `typevar'[<%= char_name("type") %>]'", "select_multiple *") & ///
		!`:char `typevar'[<%= char_name("is_other") %>]' {
		* Add an underscore to the variable name if it ends in a number.
		local var `typevar'
		local list : char `var'[<%= char_name("list_name") %>]
		local pos : list posof "`list'" in labs
		local nparts : word `pos' of `nassoc'
		if `:list list in otherlabs' & !`:char `var'[<%= char_name("or_other") %>]' ///
			local --nparts
		if inrange(substr("`var'", -1, 1), "0", "9") & ///
			length("`var'") < 32 - strlen("`nparts'") {
			numlist "1/`nparts'"
			local splitvars " `r(numlist)'"
			local splitvars : subinstr local splitvars " " " `var'_", all
			capture confirm new variable `var'_ `splitvars'
			if !_rc {
				rename `var' `var'_
				local var `var'_
			}
		}

		capture confirm numeric variable `var', exact
		if !_rc ///
			tostring `var', replace format(<%= `RealFormat' %>)
		split `var'
		local parts `r(varlist)'
		local next = `r(nvars)' + 1
		destring `parts', replace

		forvalues i = `next'/`nparts' {
			local newvar `var'`i'
			generate byte `newvar' = .
			local parts : list parts | newvar
		}

		local chars : char `var'[]
		local label : char `var'[<%= char_name("label") %>]
		local len : length local label
		local i 0
		foreach part of local parts {
			local ++i

			foreach char of local chars {
				mata: st_global("`part'[`char']", st_global("`var'[`char']"))
			}

			if `len' {
				mata: st_global("`part'[<%= char_name("label") %>]", st_local("label") + ///
					(substr(st_local("label"), -1, 1) == " " ? "" : " ") + ///
					"(#`i'/`nparts')")
			}

			move `part' `var'
		}

		drop `var'
	}
}

