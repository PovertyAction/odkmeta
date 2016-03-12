foreach var of varlist _all {
    if "`:char `var'[Odk_group]'" != "" {
        local name = "`:char `var'[Odk_name]'" + ///
            cond(`:char `var'[Odk_is_other]', "_other", "") + ///
            "`:char `var'[Odk_geopoint]'"
        local newvar = strtoname("`name'")
        capture rename `var' `newvar'
    }
}
