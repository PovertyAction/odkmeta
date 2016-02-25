* select or_other variables
forvalues i = 1/`:list sizeof otherlabs' {
	local lab      : word `i' of `otherlabs'
	local otherval : word `i' of `othervals'

	ds, has(vallab `lab')
	if "`r(varlist)'" != "" ///
		recode `r(varlist)' (.o=`otherval')
}

