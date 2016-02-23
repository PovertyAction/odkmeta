args(`SS' strlists)
* Encode fields whose list contains a noninteger name.
local lists <%= strlists %>
tempvar temp
ds, has(char <%= char_name("list_name") %>)
foreach var in `r(varlist)' {
	local list : char `var'[<%= char_name("list_name") %>]
	if `:list list in lists' & !`:char `var'[<%= char_name("is_other") %>]' {
		capture confirm numeric variable `var'
		if !_rc {
			tostring `var', replace format(<%= `RealFormat' %>)
			if !`:list list in sysmisslabs' ///
				replace `var' = "" if `var' == "."
		}
		generate `temp' = `var'

