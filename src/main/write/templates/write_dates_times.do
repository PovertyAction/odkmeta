* Date and time variables
<% // Add a type attribute to SubmissionDate. %>
capture confirm variable SubmissionDate, exact
if !_rc {
	local type : char SubmissionDate[<%= char_name("type") %>]
	assert !`:length local type'
	char SubmissionDate[<%= char_name("type") %>] datetime
}
local datetime date today time datetime start end
tempvar temp
ds, has(char <%= char_name("type") %>)
foreach var in `r(varlist)' {
	local type : char `var'[<%= char_name("type") %>]
	if `:list type in datetime' {
		capture confirm numeric variable `var'
		if !_rc {
			tostring `var', replace
			replace `var' = "" if `var' == "."
		}

		if inlist("`type'", "date", "today") {
			local fcn    date
			local mask   <%= `DateMask' %>
			local format %tdMon_dd,_CCYY
		}
		else if "`type'" == "time" {
			local fcn    clock
			local mask   <%= `TimeMask' %>
			local format %tchh:MM:SS_AM
		}
		else if inlist("`type'", "datetime", "start", "end") {
			local fcn    clock
			local mask   <%= `DatetimeMask' %>
			local format %tcMon_dd,_CCYY_hh:MM:SS_AM
		}
		generate double `temp' = `fcn'(`var', "``mask''")
		format `temp' `format'
		count if missing(`temp') & !missing(`var')
		if r(N) {
			display as err "{p}"
			display as err "`type' variable `var'"
			if "`repeat'" != "" ///
				display as err "in repeat group `repeat'"
			display as err "could not be converted using the mask ``mask''"
			display as err "{p_end}"
			exit 9
		}

		move `temp' `var'
		foreach char in `:char `var'[]' {
			mata: st_global("`temp'[`char']", st_global("`var'[`char']"))
		}
		drop `var'
		rename `temp' `var'
	}
}
<% // Remove the type attribute from SubmissionDate. %>
capture confirm variable SubmissionDate, exact
if !_rc ///
	char SubmissionDate[<%= char_name("type") %>]

