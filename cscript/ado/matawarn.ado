pr matawarn, rclass
	vers 10.1

	syntax anything(name=fn id=filename), [View]

	gettoken fn rest : fn
	if `:length loc rest' {
		di as err "invalid filename"
		ex 198
	}
	qui findfile `"`fn'"'
	loc fn "`r(fn)'"

	if !c(noisily) {
		di as err "quietly not allowed"
		ex 198
	}

	loc log _matawarn
	cap log close `log'
	tempfile res
	qui log using `res', name(`log') s

	clear programs
	clear mata
	do `"`fn'"'

	qui log close `log'

	preserve

	qui infix str line 1-244 using `res', clear

	qui cou if regexm(line, "^{txt}note: ")
	if r(N) {
		if "`view'" == "" ///
			di as txt _n "Warning(s) were issued."
		else {
			qui copy `res' matawarn_results.smcl, replace
			view matawarn_results.smcl
		}

		ret sca warn = 1
	}
	else {
		di as txt _n "No warnings were issued."
		ret sca warn = 0
	}
end
