		replace `var' = `temp'
		drop `temp'
		encode `var', gen(`temp') label(`list') noextend
		move `temp' `var'
		foreach char in `:char `var'[]' {
			mata: st_global("`temp'[`char']", st_global("`var'[`char']"))
		}
		drop `var'
		rename `temp' `var'
	}
}

