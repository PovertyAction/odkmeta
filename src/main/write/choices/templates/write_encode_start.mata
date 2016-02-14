args(`SS' strlists)
* Encode fields whose list contains a noninteger name.
local lists <%= strlists %>
tempvar temp
ds, has(char <%= listnamechar %>)
foreach var in `r(varlist)' {
	local list : char `var'[<%= listnamechar %>]
	if `:list list in lists' & !`:char `var'[<%= isotherchar %>]' {
		capture confirm numeric variable `var'
		if !_rc {
			tostring `var', replace format(<%= `RealFormat' %>)
			if !`:list list in sysmisslabs' ///
				replace `var' = "" if `var' == "."
		}
		generate `temp' = `var'

