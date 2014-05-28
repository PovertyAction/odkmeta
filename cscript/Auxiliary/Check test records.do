* Purpose: Compare the list of tests actually completed in the cscript to those
* described in Tests.md.

vers 13.1

* 1 to compare odkmeta.do against Tests.md;
* 0 to compare "Project tests.do" against "Project tests.xlsx" (off GitHub).
loc github 1

set varabbrev off

if `github' ///
	c odkmeta
else ///
	c odkmeta_development
cd cscript

loc do = cond(`github', "odkmeta.do", "Project tests.do")
infix str line 1-`c(maxstrvarlen)' using "`do'", clear

loc ws [ `=char(9)']
gen tests = regexs(1) if regexm(line, "^`ws'*\*`ws'+Tests?`ws'+(.*)$")
assert regexm(tests, "^[0-9]+$") if wordcount(tests) == 1

* Check -cd-.
assert regexm(line, "^`ws'*cd " + tests[_n - 1] + "$") ///
	if wordcount(tests[_n - 1]) == 1

* Check -compall-.
replace tests = tests[_n - 1] if mi(tests)
drop if mi(tests)
assert _N
gen compall = regexm(line, "^`ws'*compall(`ws'|\$)")
gen rcof = regexm(line, "^`ws'*rcof(`ws'|\$)")
gen doonly = line == "* Do-file only"
foreach var of var compall rcof doonly {
	bys tests (`var'): replace `var' = `var'[_N]
}
drop line
duplicates drop
isid tests
assert compall | rcof | doonly
assert (compall | rcof) + doonly == 1

* Split variable tests.
split tests, gen(test) p(,)
drop tests
gen i = _n
reshape long test, i(i)
drop if mi(test)
drop i _j
destring test, replace
assert test > 0 & test == floor(test)
isid test

levelsof test, loc(tests)
loc dirs : dir Tests dir *
assert `:list tests in dirs'
if `github' {
	di `"`:list dirs - tests'"'
	assert `:list dirs === tests'
}

gen expected = .
foreach test of loc tests {
	mata: st_local("expected", strofreal(direxists("Tests/`test'/Expected")))
	replace expected = `expected' if test == `test'
}
assert !mi(expected)
assert compall + expected != 1

tempfile cscript
sa `cscript'

if `github' ///
	do "Auxiliary/Import tests md"
else {
	import excel using "Project tests.xlsx", sh(Tests) first case(low) clear

	ren projecttestid		id
	ren formdescription		desc
	drop oldtestid
}

drop if inlist(checkedby, "NA", "")

keep id
ren id test
merge 1:1 test using `cscript'
assert _merge == 3
drop _merge
