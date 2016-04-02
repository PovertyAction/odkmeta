foreach var of varlist _all {
    if "`:char `var'[<%= char_name("group") %>]'" != "" & "`:char `var'[<%= char_name("type") %>]'" != "begin repeat" {
        local name = "`:char `var'[<%= char_name("name") %>]'" + ///
            cond(`:char `var'[<%= char_name("is_other") %>]', "_other", "") + ///
            "`:char `var'[<%= char_name("geopoint") %>]'"
		local newvar = strtoname("`name'")
        capture rename `var' `newvar'
    }
}
