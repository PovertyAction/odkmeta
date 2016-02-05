* Gets the warning messages of an -odkmeta- do-file.
pr get_warnings, rclass
	vers 9

	syntax anything(name=do id=filename)

	gettoken do rest : do
	if `:length loc rest' {
		di as err "invalid filename"
		ex 198
	}

	if !c(noisily) {
		di as err "quietly not allowed"
		ex 198
	}

	* Set parameters.
	loc trace 0
	if c(trace) == "on" {
		loc trace 1
		set trace off
	}
	loc linesize = c(linesize)
	set linesize 80

	* Create the log file.
	qui log query _all
	if "`r(numlogs)'" != "" {
		forv i = 1/`r(numlogs)' {
			loc logs `logs' `r(name`i')'
		}
	}
	loc i 0
	* Using __get_warnings# rather than a tempname so that -get_warnings- does
	* not affect the temporary names in the -odkmeta- do-file.
	loc log __get_warnings`++i'
	while `:list log in logs' {
		loc log __get_warnings`++i'
	}
	tempfile temp
	qui log using `temp', t name(`log')
	run `"`do'"'
	qui log close `log'

	* Restore parameters.
	if `trace' ///
		set trace on
	set linesize `linesize'

	preserve
	qui infix str line 1-244 using `temp', clear

	gen n = _n
	gen dashes = line == "`:di _dup(65) "-"'"

	#d ;
	loc warnings
		badname		"The following variables' names differ from their field names, which could not be\ninsheeted:"
		datanotform	"The following variables appear in the data but not the form:"
		formnotdata "The following fields appear in the form but not the data:"
	;
	#d cr
	assert mod(`:list sizeof warnings', 2) == 0
	while `:list sizeof warnings' {
		gettoken name warnings : warnings
		gettoken text warnings : warnings

		gen warning = 1
		loc npieces = 1 + (strlen("`text'") - ///
			strlen(subinstr("`text'", "\n", "", .))) / 2
		forv i = 1/`npieces' {
			loc pos = strpos("`text'", "\n")
			if !`pos' ///
				loc pos .
			loc piece = substr("`text'", 1, `pos' - 1)
			qui replace warning = warning & line[_n + `i' - 1] == "`piece'"
			loc text = subinstr("`text'", "`piece'", "", 1)
			loc text = subinstr("`text'", "\n", "", 1)
		}

		qui cou if warning
		if r(N) {
			assert r(N) == 1
			assert line[_n + `npieces'] == "" if warning
			assert itrim(line[_n + `npieces' + 1]) == ///
				"repeat group variable name" ///
				if warning
			assert dashes[_n + `npieces' + 2] == 1 if warning

			qui su n if warning
			* "msgn" for "message n"
			loc msgn = r(min)
			qui su n if dashes & n > `msgn' + `npieces' + 2
			loc first = `msgn' + `npieces' + 3
			assert r(N) & r(min) > `first'
			loc repeats
			loc vars
			forv i = `first'/`=r(min) - 1' {
				assert inlist(wordcount(line[`i']), 1, 2)
				if wordcount(line[`i']) == 1 {
					loc repeats "`repeats' """
					loc vars `vars' `=line[`i']'
				}
				else {
					loc repeats "`repeats' `=word(line[`i'], 1)'"
					loc vars `vars' `=word(line[`i'], 2)'
				}
			}
			loc repeats : list retok repeats
			loc vars    : list retok vars

			ret loc `name'_repeats "`repeats'"
			ret loc `name'_vars "`vars'"
		}

		drop warning
	}
end
