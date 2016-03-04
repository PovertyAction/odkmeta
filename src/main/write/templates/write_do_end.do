capture mata: mata drop `values' `text'

set varabbrev `varabbrev'

* Display warning messages.
quietly {
	noisily display

	#delimit ;
	local problems
		<% df.indent() %>
		allbadnames
			<% df.indent() %>
			"The following variables' names differ from their field names,
			which could not be {cmd:insheet}ed:"
		<% df.indent(-1) %>
		alldatanotform
			<% df.indent() %>
			"The following variables appear in the data but not the form:"
		<% df.indent(-1) %>
		<% if (relax) { %>
		allformnotdata
			<% df.indent() %>
			"The following fields appear in the form but not the data:"
		<% df.indent(-1) %>
		<% } %>
	<% df.indent(-1) %>
	;
	#delimit cr
	while `:list sizeof problems' {
		gettoken local problems : problems
		gettoken desc  problems : problems

		local any 0
		foreach vars of local `local' {
			local any = `any' | `:list sizeof vars'
		}
		if `any' {
			noisily display as txt "{p}`desc'{p_end}"
			noisily display "{p2colset 0 34 0 2}"
			noisily display as txt "{p2col:repeat group}variable name{p_end}"
			noisily display as txt "{hline 65}"

			forvalues i = 1/`:list sizeof repeats' {
				local repeat : word `i' of `repeats'
				local vars   : word `i' of ``local''

				foreach var of local vars {
					noisily display as res "{p2col:`repeat'}`var'{p_end}"
				}
			}

			noisily display as txt "{hline 65}"
			noisily display "{p2colreset}"
		}
	}
}
