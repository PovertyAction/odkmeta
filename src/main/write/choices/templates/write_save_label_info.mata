* Save label information.
label dir
local labs `r(names)'
foreach lab of local labs {
	quietly label list `lab'
	* "nassoc" for "number of associations"
	local nassoc `nassoc' `r(k)'
}

