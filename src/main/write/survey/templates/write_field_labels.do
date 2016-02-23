* Attach field labels as variable labels and notes.
ds, has(char <%= char_name("long_name") %>)
foreach var in `r(varlist)' {
	* Variable label
	local label : char `var'[<%= char_name("label") %>]
	mata: st_varlabel("`var'", st_local("label"))

	* Notes
	if `:length local label' {
		char `var'[note0] 1
		mata: st_global("`var'[note1]", "Question text: " + ///
			st_global("`var'[<%= char_name("label") %>]"))
		mata: st_local("temp", ///
			" " * (strlen(st_global("`var'[note1]")) + 1))
		#delimit ;
		local fromto
		<% df.indent() %>
			{        "`temp'"
			}        "{c )-}"
			"`temp'" "{c -(}"
			'        "{c 39}"
			"`"      "{c 'g}"
			"$"      "{c S|}"
		<% df.indent(-1) %>
		;
		#delimit cr
		while `:list sizeof fromto' {
			gettoken from fromto : fromto
			gettoken to   fromto : fromto
			mata: st_global("`var'[note1]", ///
				subinstr(st_global("`var'[note1]"), "`from'", "`to'", .))
		}
	}
}

