* -odkmeta- cscript

* -version- intentionally omitted for -cscript-.

* 1 to run the cscript on the stable ado-file; 0 not to.
local stable 0
* 1 to complete test 124; 0 not to.
local test124 0
* 1 to complete live-project testing; 0 not to.
local project 0
* 1 to execute profile.do after completion; 0 not to.
local profile 1


/* -------------------------------------------------------------------------- */
					/* initialize			*/

* Check the parameters.
assert inlist(`stable',  0, 1)
assert inlist(`test124', 0, 1)
assert inlist(`project', 0, 1)
assert inlist(`profile', 0, 1)

* Check that -renvars- is installed.
which renvars

* Set the working directory to odkmeta directory.
c odkmeta
cd cscript

cap log close odkmeta
log using odkmeta, name(odkmeta) s replace
di c(username)
di "`:environment computername'"

clear
clear matrix
clear mata
if c(maxvar) < 5450 ///
	set maxvar 5450
set varabbrev off
set type float
vers 11.2: set seed 889305539
set more off

cd ..
if `stable' ///
	copy stable/odkmeta.ado odkmeta.ado, replace
else ///
	do write_ado
adopath ++ `"`c(pwd)'"'
adopath ++ `"`c(pwd)'/cscript/ado"'
cd cscript

timer clear 1
timer on 1

* Preserve select globals.
loc FASTCDPATH : copy glo FASTCDPATH

cscript odkmeta adofile odkmeta

* Check that Mata issues no warning messages about the source code.
if c(stata_version) >= 13 {
	matawarn odkmeta.ado
	assert !r(warn)
	cscript
}

* Restore globals.
glo FASTCDPATH : copy loc FASTCDPATH

* Define -shortnames-, a program to change an -odkmeta- do-file so that it
* attempts to name variables using their short names.
* Syntax: shortnames filename
run shortnames
* Define -get_warnings-, a program to return the warning messages of an
* -odkmeta- do-file.
* Syntax: -get_warnings do_file_name-
run get_warnings

cd Tests

* Erase do-files and .dta files not in an Expected directory.
loc dirs : dir . dir *
foreach dir of loc dirs {
	loc dtas : dir "`dir'" file "*.dta"
	foreach dta of loc dtas {
		erase "`dir'/`dta'"
	}

	loc dofiles : dir "`dir'" file "*.do"
	foreach do of loc dofiles {
		erase "`dir'/`do'"
	}
}


/* -------------------------------------------------------------------------- */
					/* example test			*/

* Test 1
cd 1
odkmeta using "ODK to Stata.do", ///
	csv(Audio audit test.csv) survey(survey.csv) choices(choices.csv) replace
run "ODK to Stata"
compall Expected
cd ..


/* -------------------------------------------------------------------------- */
					/* basic				*/

* Test 2
cd 2
conf new f "ODK to Stata.do"
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest2.csv) survey(survey.csv) choices(choices.csv)
get_warnings "ODK to Stata"
assert `"`r(badname_repeats)'"' == ""
assert "`r(badname_vars)'" == ""
assert `"`r(datanotform_repeats)'"' == ""
assert "`r(datanotform_vars)'" == ""
assert `"`r(formnotdata_repeats)'"' == ""
assert "`r(formnotdata_vars)'" == ""
compall Expected
cd ..

* Test 19
cd 19
forv i = 1/2 {
	odkmeta using "ODK to Stata.do", ///
		csv(odkmetatest2.csv) survey(survey.csv) choices(choices.csv) replace
	run "ODK to Stata"
	compall Expected
}
cd ..

* Test 48
cd 48
odkmeta using "ODK to Stata.do", ///
	csv(Audio audit test.csv) survey(survey.csv) choices(choices.csv) replace
run "ODK to Stata"
compall Expected
cd ..

* Test 52
cd 52
#d ;
odkmeta using "ODK to Stata.do",
	csv(Audio audit test.csv)
	survey(survey.csv, type(A) name(B) label(C) disabled(D))
	choices(choices.csv, listname(A) name(B) label(C))
	replace
;
#d cr
run "ODK to Stata"
compall Expected
cd ..

* Test 54
cd 54
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest2.csv) survey(survey.csv) choices(choices.csv) replace
run "ODK to Stata"
compall Expected
cd ..

* Test 71
cd 71
cap erase "ODK to Stata.do"
odkmeta using "ODK to Stata", ///
	csv(odkmetatest2.csv) survey(survey.csv) choices(choices.csv) replace
conf f "ODK to Stata.do"
run "ODK to Stata"
compall Expected
cd ..

* Test 73
cd 73
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest2) survey(survey) choices(choices) replace
run "ODK to Stata"
compall Expected
cd ..

* Test 75
cd 75
odkmeta using "ODK to Stata.do", ///
	csv("odkmetatest2.csv") survey("survey.csv") choices("choices.csv") replace
run "ODK to Stata"
compall Expected
cd ..

* Test 76
cd 76
#d ;
odkmeta using "ODK to Stata.do",
	csv("Audio audit test.csv")
	survey("survey.csv", type(A) name(B) label(C) disabled(D))
	choices("choices.csv", listname(A) name(B) label(C))
	replace
;
#d cr
run "ODK to Stata"
compall Expected
cd ..

/*
* Test 77
cd 77
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest2.csv) survey(survey.csv, type(t\`ype)) ///
	choices(choices.csv) replace
run "ODK to Stata"
compall Expected
cd ..
*/

* Test 89
cd 89
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest2.csv) survey(survey.csv) choices(choices.csv) replace
run "ODK to Stata"
compall Expected
cd ..

* Test 90
cd 90
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest2.csv) survey(survey.csv) choices(choices.csv) replace
run "ODK to Stata"
compall Expected
cd ..

* Test 96
cd 96
odkmeta using "ODK to Stata.do", ///
	csv(Audio audit test.csv) survey(survey.csv) choices(choices.csv) replace
run "ODK to Stata"
compall Expected
cd ..

* Test 108
cd 108
odkmeta using import, ///
	csv("survey data") survey("survey survey") choices("survey choices") replace
run import
compall Expected
cd ..

* Test 109
cd 109
odkmeta using import, ///
	csv(survey data) survey(survey survey) choices(survey choices) replace
run import
compall Expected
cd ..

* Test 157
cd 157
odkmeta using import, csv(data) survey(survey) choices(choices) replace
run import
compall Expected
cd ..

* Test 199
cd 199
odkmeta using "ODK to Stata.do", ///
	csv(Audio audit test.csv) survey(survey.csv) choices(choices.csv) replace
run "ODK to Stata"
compall Expected
cd ..

* Test 208
cd 208
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest2.csv) survey(survey.csv) choices(choices.csv)
run "ODK to Stata"
compall Expected
cd ..


/* -------------------------------------------------------------------------- */
					/* .csv file			*/

* Test 3
cd 3
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest3.csv) survey(survey.csv) choices(choices.csv) replace
run "ODK to Stata"
compall Expected
cd ..

* Test 4
cd 4
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest3.csv) survey(survey.csv) choices(choices.csv) replace
run "ODK to Stata"
compall Expected
cd ..

* Test 5
cd 5
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest5.csv) survey(survey.csv) choices(choices.csv) replace
run "ODK to Stata"
compall Expected
cd ..

* Test 6
cd 6
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest5.csv) survey(survey.csv) choices(choices.csv) replace
run "ODK to Stata"
compall Expected
cd ..

* Test 7
cd 7
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest5.csv) survey(survey.csv) choices(choices.csv) replace
run "ODK to Stata"
compall Expected
cd ..

* Test 8
cd 8
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest8.csv) survey(survey.csv) choices(choices.csv) replace
run "ODK to Stata"
compall Expected
cd ..

* Test 9
cd 9
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest9.csv) survey(survey.csv) choices(choices.csv) replace
run "ODK to Stata"
compall Expected
cd ..

* Test 10
cd 10
odkmeta using "ODK to Stata.do", ///
	csv("odkmetatest10 data.csv") survey("odk survey.csv") choices("odk choices.csv") replace
run "ODK to Stata"
compall Expected
cd ..

* Test 27
cd 27
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest27.csv) survey(survey.csv) choices(choices.csv) replace
get_warnings "ODK to Stata"
assert `"`r(badname_repeats)'"' == `""""'
assert "`r(badname_vars)'" == "v3"
assert `"`r(datanotform_repeats)'"' == ""
assert "`r(datanotform_vars)'" == ""
assert `"`r(formnotdata_repeats)'"' == ""
assert "`r(formnotdata_vars)'" == ""
compall Expected
cd ..

* Test 28
cd 28
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest28.csv) survey(survey.csv) choices(choices.csv) replace
get_warnings "ODK to Stata"
assert `"`r(badname_repeats)'"' == `""" "" "" """'
assert "`r(badname_vars)'" == "v3 v6 v9 v12"
assert `"`r(datanotform_repeats)'"' == ""
assert "`r(datanotform_vars)'" == ""
assert `"`r(formnotdata_repeats)'"' == ""
assert "`r(formnotdata_vars)'" == ""
compall Expected
cd ..

* Test 29
cd 29
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest29.csv) survey(survey.csv) choices(choices.csv) replace
run "ODK to Stata"
compall Expected
cd ..

* Test 80
cd 80
odkmeta using "ODK to Stata.do", ///
	csv(data.csv) survey(survey.csv) choices(choices.csv) replace
get_warnings "ODK to Stata"
assert `"`r(badname_repeats)'"' == `""" """'
assert "`r(badname_vars)'" == "v2 v3"
assert `"`r(datanotform_repeats)'"' == `""" """'
assert "`r(datanotform_vars)'" == "_uuid _submission_time"
assert `"`r(formnotdata_repeats)'"' == ""
assert "`r(formnotdata_vars)'" == ""
compall Expected
cd ..

* Test 84
cd 84
odkmeta using import, ///
	csv(odkmetatest84.csv) survey(survey.csv) choices(choices.csv) replace
get_warnings import
assert `"`r(badname_repeats)'"' == `""""'
assert "`r(badname_vars)'" == "v3"
assert `"`r(datanotform_repeats)'"' == ""
assert "`r(datanotform_vars)'" == ""
assert `"`r(formnotdata_repeats)'"' == ""
assert "`r(formnotdata_vars)'" == ""
compall Expected
cd ..

* Test 85
cd 85
odkmeta using import, ///
	csv(odkmetatest2.csv) survey(survey.csv) choices(choices.csv) replace
tempfile new
filefilter import.do `new', from(fields)
assert !r(occurrences)
get_warnings import
assert `"`r(badname_repeats)'"' == ""
assert "`r(badname_vars)'" == ""
assert `"`r(datanotform_repeats)'"' == ""
assert "`r(datanotform_vars)'" == ""
assert `"`r(formnotdata_repeats)'"' == ""
assert "`r(formnotdata_vars)'" == ""
compall Expected
cd ..

* Test 86
cd 86
odkmeta using import, ///
	csv(odkmetatest86.csv) survey(survey.csv) choices(choices.csv) replace
get_warnings import
assert `"`r(badname_repeats)'"' == `""" "" "" "" "" "" """'
assert "`r(badname_vars)'" == "v2 v3 v4 v5 v6 v7 v8"
assert `"`r(datanotform_repeats)'"' == ""
assert "`r(datanotform_vars)'" == ""
assert `"`r(formnotdata_repeats)'"' == ""
assert "`r(formnotdata_vars)'" == ""
compall Expected
cd ..

* Test 91
cd 91
odkmeta using import, ///
	csv(odkmetatest91.csv) survey(survey.csv) choices(choices.csv) replace
run import
compall Expected
cd ..

* Test 103
cd 103
odkmeta using import, csv(data) survey(survey) choices(choices) replace
tempfile temp
filefilter import.do `temp', ///
	from("* Rename any variable names that are difficult for -split-.") ///
	to("renvars thirtytwocharactersagainonfruits \BS fruits32")
copy `temp' import.do, replace
get_warnings import
assert `"`r(badname_repeats)'"' == `""" "" "" """'
assert "`r(badname_vars)'" == "v7 v9 v13 v17"
assert `"`r(datanotform_repeats)'"' == ""
assert "`r(datanotform_vars)'" == ""
assert `"`r(formnotdata_repeats)'"' == ""
assert "`r(formnotdata_vars)'" == ""
compall Expected
cd ..

* Test 104
cd 104
odkmeta using import, csv(odkmetatest104) ///
	survey(survey) choices(choices) replace
get_warnings import
assert `"`r(badname_repeats)'"' == `""" "" """'
assert "`r(badname_vars)'" == "v3 v11 v12"
assert `"`r(datanotform_repeats)'"' == ""
assert "`r(datanotform_vars)'" == ""
assert `"`r(formnotdata_repeats)'"' == ""
assert "`r(formnotdata_vars)'" == ""
compall Expected
cd ..

* Test 148
cd 148
odkmeta using import, ///
	csv(Audio.audit.test.csv) survey(survey) choices(choices) replace
run import
compall Expected
cd ..


/* -------------------------------------------------------------------------- */
					/* field types			*/

* Test 50
cd 50
odkmeta using import, ///
	csv(odkmetatest50.csv) survey(survey.csv) choices(choices.csv) replace
run import
compall Expected
cd ..

* Test 102
cd 102
odkmeta using import, ///
	csv(odkmetatest102.csv) survey(survey.csv) choices(choices.csv) replace
run import
compall Expected
cd ..

* Test 141
cd 141
odkmeta using "import.do", ///
	csv("data.csv") ///
	survey("survey.csv") choices("choices.csv") replace
tempfile temp
filefilter import.do `temp', ///
	from("local datetimemask MDYhms") to("local datetimemask DMYhms")
assert r(occurrences) == 1
copy `temp' import.do, replace
run import
compall Expected
cd ..

* Test 145
cd 145
odkmeta using "import.do", csv(data) survey(survey) choices(choices)
tempfile temp
filefilter import.do `temp', ///
	from("local datetimemask MDYhms") to("local datetimemask DMYhms") replace
assert r(occurrences) == 1
copy `temp' import.do, replace
filefilter import.do `temp', ///
	from("local timemask hms") to("local timemask hm") replace
assert r(occurrences) == 1
copy `temp' import.do, replace
filefilter import.do `temp', ///
	from("local datemask MDY") to("local datemask DMY") replace
assert r(occurrences) == 1
copy `temp' import.do, replace
run import
compall Expected
cd ..


/* -------------------------------------------------------------------------- */
					/* attributes			*/

* Test 11
cd 11
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest2.csv) choices(choices.csv) replace ///
	survey(survey.csv, type(Type))
run "ODK to Stata"
compall Expected
cd ..

* Test 24
cd 24
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest24.csv) survey(survey.csv) choices(choices.csv) replace
run "ODK to Stata"
compall Expected
cd ..

* Test 25
cd 25
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest25.csv) survey(survey.csv) choices(choices.csv) replace
run "ODK to Stata"
compall Expected
cd ..

* Test 101
cd 101
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest101.csv) survey(survey.csv) choices(choices.csv) replace
run "ODK to Stata"
compall Expected
cd ..


/* -------------------------------------------------------------------------- */
					/* lists				*/

* Test 12
cd 12
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest12.csv) survey(survey.csv) choices(choices.csv) replace
run "ODK to Stata"
compall Expected
cd ..

* Test 20
cd 20
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest20.csv) survey(survey.csv) choices(choices.csv) replace
run "ODK to Stata"
compall Expected
cd ..

* Test 21
cd 21
odkmeta using import, ///
	csv(odkmetatest21.csv) survey(survey.csv) choices(choices.csv) replace
run import
compall Expected
cd ..

* Test 22
cd 22
odkmeta using import, ///
	csv(odkmetatest22.csv) survey(survey.csv) choices(choices.csv) replace
run import
compall Expected
cd ..

* Test 23
cd 23
odkmeta using import, ///
	csv(odkmetatest23.csv) survey(survey.csv) choices(choices.csv) replace
run import
compall Expected
cd ..

* Test 36
cd 36
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest36.csv) survey(survey.csv) choices(choices.csv) replace
get_warnings "ODK to Stata"
assert `"`r(badname_repeats)'"' == ""
assert "`r(badname_vars)'" == ""
assert `"`r(datanotform_repeats)'"' == `""" """'
assert "`r(datanotform_vars)'" == "_uuid _submission_time"
assert `"`r(formnotdata_repeats)'"' == ""
assert "`r(formnotdata_vars)'" == ""
compall Expected
cd ..

* Test 41
cd 41
odkmeta using "import online.do", ///
	csv(odkmetatest36.csv) survey(survey.csv) choices(choices.csv) replace ///
	oneline
run "import online"
compall Expected
tempfile new
filefilter "import online.do" `new', from(;)
assert r(occurrences) == 4
filefilter "import online.do" `new', from(#delimit) replace
assert r(occurrences) == 4
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest36.csv) survey(survey.csv) choices(choices.csv) replace
filefilter "ODK to Stata.do" `new', from(;) replace
assert r(occurrences) > 4
filefilter "ODK to Stata.do" `new', from(#delimit) replace
assert r(occurrences) > 4
cd ..

* Test 47
cd 47
odkmeta using import, ///
	csv(odkmetatest47.csv) survey(survey.csv) choices(choices.csv) replace
run import
compall Expected
cd ..

* Test 56
cd 56
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest56.csv) survey(survey.csv) choices(choices.csv) replace
run "ODK to Stata"
compall Expected
cd ..

* Test 57
cd 57
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest56.csv) survey(survey.csv) choices(choices.csv) replace ///
	other(max)
run "ODK to Stata"
compall Expected
cd ..

* Test 58
cd 58
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest56.csv) survey(survey.csv) choices(choices.csv) replace ///
	other(min)
run "ODK to Stata"
compall Expected
cd ..

* Test 59
cd 59
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest56.csv) survey(survey.csv) choices(choices.csv) replace ///
	other(99)
run "ODK to Stata"
compall Expected
cd ..

* Test 60
cd 60
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest56.csv) survey(survey.csv) choices(choices.csv) replace ///
	other(.o)
run "ODK to Stata"
compall Expected
cd ..

* Test 72
cd 72
odkmeta using import, ///
	csv(odkmetatest72.csv) survey(survey.csv) choices(choices.csv) replace
run import
compall Expected
cd ..

* Test 83
cd 83
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest36.csv) survey(survey.csv) choices(choices.csv) replace
run "ODK to Stata"
compall Expected
cd ..

* Test 87
cd 87
odkmeta using import, ///
	csv(odkmetatest87.csv) survey(survey.csv) choices(choices.csv) replace
run import
compall Expected
cd ..

* Test 92
cd 92
odkmeta using import, csv(data) survey(survey) choices(choices) replace
run import
compall Expected
cd ..

* Test 93
cd 93
odkmeta using import, csv(data) survey(survey) choices(choices) replace
run import
compall Expected
cd ..

* Test 94
cd 94
odkmeta using import, csv(data) survey(survey) choices(choices) replace
run import
compall Expected
cd ..

* Test 106
cd 106
odkmeta using import, csv(data) survey(survey) choices(choices) replace
run import
compall Expected
cd ..

* Test 107
cd 107
odkmeta using import, csv(data) survey(survey) choices(choices) replace
run import
compall Expected
cd ..

* Test 137
cd 137
odkmeta using import, csv(data) survey(survey) choices(choices) replace
run import
compall Expected
cd ..

* Test 138
cd 138
odkmeta using import, ///
	csv(odkmetatest36.csv) survey(survey.csv) choices(choices.csv) replace
run import
compall Expected
cd ..

* Test 139
cd 139
odkmeta using import, ///
	csv(Audio audit test.csv) survey(survey.csv) choices(choices.csv) replace
run import
compall Expected
cd ..

* Test 140
cd 140
odkmeta using import, ///
	csv(Audio audit test.csv) survey(survey.csv) choices(choices.csv) replace
run import
compall Expected
cd ..

* Test 142
cd 142
odkmeta using "import.do", ///
	csv("data.csv") ///
	survey("survey.csv") choices("choices.csv") replace
run import
compall Expected
cd ..

* Test 143
cd 143
odkmeta using "import.do", ///
	csv("data.csv") ///
	survey("survey.csv") choices("choices.csv") replace
run import
compall Expected
cd ..

* Test 144
cd 144
odkmeta using "import.do", ///
	csv("data.csv") ///
	survey("survey.csv") choices("choices.csv") replace
run import
compall Expected
cd ..

* Test 197
cd 197
odkmeta using "import.do", ///
	csv("data.csv") ///
	survey("survey.csv") choices("choices.csv") replace
run import
compall Expected
cd ..


/* -------------------------------------------------------------------------- */
					/* -specialexp()-		*/

* Test 191
cd 191
odkmeta using import, ///
	csv(odkmetatest21.csv) survey(survey.csv) choices(choices.csv) replace
run import
compall Expected
cd ..

* Test 192
cd 192
odkmeta using import, ///
	csv(odkmetatest21.csv) survey(survey.csv) choices(choices.csv) replace
run import
compall Expected
cd ..

* Test 193
cd 193
odkmeta using import, ///
	csv(odkmetatest21.csv) survey(survey.csv) choices(choices.csv) replace
run import
compall Expected
cd ..

* Test 194
cd 194
odkmeta using import, ///
	csv(odkmetatest21.csv) survey(survey.csv) choices(choices.csv) replace
run import
compall Expected
cd ..

* Test 195
cd 195
odkmeta using import, ///
	csv(odkmetatest21.csv) survey(survey.csv) choices(choices.csv) replace
run import
compall Expected
cd ..

* Test 196
cd 196
odkmeta using import, ///
	csv(odkmetatest12.csv) survey(survey.csv) choices(choices.csv) replace
run import
compall Expected
cd ..


/* -------------------------------------------------------------------------- */
					/* groups and repeats	*/

* Test 98
cd 98
odkmeta using import, ///
	csv(odkmetatest84.csv) survey(survey.csv) choices(choices.csv) replace
get_warnings import
assert `"`r(badname_repeats)'"' == `""""'
assert "`r(badname_vars)'" == "v3"
assert `"`r(datanotform_repeats)'"' == ""
assert "`r(datanotform_vars)'" == ""
assert `"`r(formnotdata_repeats)'"' == ""
assert "`r(formnotdata_vars)'" == ""
compall Expected
cd ..

* Test 110
cd 110
odkmeta using import, csv(data) survey(survey) choices(choices) replace
run import
compall Expected
cd ..

* Test 111
cd 111
odkmeta using import, ///
	csv(odkmetatest111) survey(survey) choices(choices) replace
run import
compall Expected
cd ..

* Test 112
cd 112
odkmeta using import, ///
	csv(odkmetatest112) survey(survey) choices(choices) replace
run import
compall Expected
cd ..

* Test 113
cd 113
odkmeta using import, ///
	csv(odkmetatest113) survey(survey) choices(choices) replace
run import
compall Expected
cd ..

* Test 114
cd 114
odkmeta using import, ///
	csv(odkmetatest114) survey(survey) choices(choices) replace
run import
compall Expected
cd ..

* Test 115
cd 115
odkmeta using import, ///
	csv(odkmetatest115) survey(survey) choices(choices) replace
run import
compall Expected
cd ..

* Test 116
cd 116
odkmeta using import, csv(data) survey(survey) choices(choices) replace
run import
* Check the dataset.
compall Expected
* Check the do-file.
infix str line 1-244 using import.do, clear
gen ln = _n
su ln if line == "* begin group G1"
assert r(N) == 1
assert line[r(min) + 1] == "* begin group G2"
su ln if line == "* end group G2"
assert r(N) == 1
assert line[r(min) + 1] == "* end group G1"
cd ..

* Test 117
cd 117
odkmeta using import, ///
	csv(odkmetatest117) survey(survey) choices(choices) replace
run import
compall Expected
cd ..

* Test 124
cd 124
* Do-file only
if `test124' {
forv i = 1/25 {
	drop _all
	set obs `=ceil(10 * runiform())'
	gen order = _n
	gen type = "text"
	gen name = "field" + strofreal(order)

	foreach collec in repeat group {
		forv j = 1/`=floor(301 * runiform())' {
			preserve

			drop _all
			* "+ 2" for "begin group/repeat" and "end group/repeat"
			set obs `=ceil(3 * runiform()) + 2'
			gen collecorder = _n

			gen type = ""
			gen name = ""
			replace type = "begin `collec'" in 1
			replace name = "`collec'`j'" in 1
			replace type = "end `collec'" in L

			replace type = "integer" if mi(type)
			replace name = "`collec'`j'_field" + strofreal(_n) if mi(name)

			tempfile temp
			sa `temp'

			restore

			sca neworder = (_N + 1) * runiform()
			assert order != neworder
			assert !mi(order)
			append using `temp'
			replace order = neworder if mi(order)
			sort order collecorder
			drop collecorder
			replace order = _n
		}
	}

	gen repeatlevel = sum(type == "begin repeat") - sum(type == "end repeat")
	replace repeatlevel = repeatlevel + 1 if type == "end repeat"
	gen label = strofreal(repeatlevel) if repeatlevel
	drop repeatlevel

	outsheet using survey`i'.csv, c replace
	odkmeta using import, csv(124) survey(survey`i') choices(choices) replace
}
}
cd ..

* Test 146
cd 146
odkmeta using import, ///
	csv(odkmetatest113) survey(survey) choices(choices) replace
tempfile temp
filefilter import.do `temp', ///
	from("* Merge repeat groups.") ///
	to("ex")
assert r(occurrences) == 1
copy `temp' import.do, replace
run import
compall Expected
cd ..

* Test 147
cd 147
odkmeta using import, ///
	csv(odkmetatest115) survey(survey) choices(choices) replace
tempfile temp
filefilter import.do `temp', ///
	from("* Merge repeat groups.") ///
	to("ex")
assert r(occurrences) == 1
copy `temp' import.do, replace
run import
compall Expected
cd ..

* Test 162
cd 162
odkmeta using import, ///
	csv(odkmetatest162) survey(survey) choices(choices)
get_warnings import
assert `"`r(badname_repeats)'"' == ""
assert "`r(badname_vars)'" == ""
assert `"`r(datanotform_repeats)'"' == ""
assert "`r(datanotform_vars)'" == ""
assert `"`r(formnotdata_repeats)'"' == ""
assert "`r(formnotdata_vars)'" == ""
compall Expected
cd ..

* Test 163
cd 163
odkmeta using import, ///
	csv(odkmetatest163) survey(survey) choices(choices)
get_warnings import
assert `"`r(badname_repeats)'"' == `"lindseyrepeat"'
assert "`r(badname_vars)'" == "v4"
assert `"`r(datanotform_repeats)'"' == ""
assert "`r(datanotform_vars)'" == ""
assert `"`r(formnotdata_repeats)'"' == ""
assert "`r(formnotdata_vars)'" == ""
compall Expected
cd ..

* Test 164
cd 164
odkmeta using import, ///
	csv(odkmetatest111) survey(survey) choices(choices) replace
run import
compall Expected
cd ..

* Test 165
cd 165
odkmeta using import, ///
	csv(odkmetatest165) survey(survey) choices(choices) replace
run import
compall Expected
cd ..

* Test 166
cd 166
odkmeta using import, ///
	csv(odkmetatest166) survey(survey) choices(choices) replace
run import
compall Expected
cd ..

* Test 167
cd 167
odkmeta using import, ///
	csv(odkmetatest167) survey(survey) choices(choices)
get_warnings import
assert `"`r(badname_repeats)'"' == `"lindseyrepeat"'
assert "`r(badname_vars)'" == "v4"
assert `"`r(datanotform_repeats)'"' == ""
assert "`r(datanotform_vars)'" == ""
assert `"`r(formnotdata_repeats)'"' == ""
assert "`r(formnotdata_vars)'" == ""
compall Expected
cd ..

* Test 184
cd 184
odkmeta using import, ///
	csv(odkmetatest111) survey(survey) choices(choices) replace
get_warnings import
assert `"`r(badname_repeats)'"' == ""
assert "`r(badname_vars)'" == ""
assert `"`r(datanotform_repeats)'"' == "roster"
assert "`r(datanotform_vars)'" == "DATA_NOT_FORM"
assert `"`r(formnotdata_repeats)'"' == ""
assert "`r(formnotdata_vars)'" == ""
compall Expected
cd ..

* Test 203
cd 203
odkmeta using import, ///
	csv(odkmetatest203) survey(survey) choices(choices) replace
get_warnings import
assert `"`r(badname_repeats)'"' == `""" """'
assert "`r(badname_vars)'" == "v3 v6"
assert `"`r(datanotform_repeats)'"' == ""
assert "`r(datanotform_vars)'" == ""
assert `"`r(formnotdata_repeats)'"' == ""
assert "`r(formnotdata_vars)'" == ""
compall Expected
cd ..

* Test 209
cd 209
odkmeta using import, csv(odkmetatest209) survey(survey) choices(choices) replace
get_warnings import
assert `"`r(badname_repeats)'"' == ""
assert "`r(badname_vars)'" == ""
assert `"`r(datanotform_repeats)'"' == ""
assert "`r(datanotform_vars)'" == ""
assert `"`r(formnotdata_repeats)'"' == ""
assert "`r(formnotdata_vars)'" == ""
compall Expected
cd ..


/* -------------------------------------------------------------------------- */
					/* -dropattrib()-, -keepattrib()-	*/

* Test 171
cd 171
odkmeta using import, ///
	csv(Audio audit test.csv) survey(survey.csv) choices(choices.csv) ///
	dropattrib(type "constraint message" constraint_message) replace
run import
compall Expected
cd ..

* Test 172
cd 172
odkmeta using import, ///
	csv(Audio audit test.csv) survey(survey.csv) choices(choices.csv) ///
	dropattrib(_all) replace
run import
compall Expected
cd ..

* Test 173
cd 173
odkmeta using import, ///
	csv(Audio audit test.csv) survey(survey.csv) choices(choices.csv) ///
	dropattrib(_all type) replace
run import
compall Expected
cd ..

* Test 174
cd 174
odkmeta using import, ///
	csv(Audio audit test.csv) survey(survey.csv) choices(choices.csv) ///
	keepattrib(type "constraint message" constraint_message) replace
run import
compall Expected
cd ..

* Test 175
cd 175
odkmeta using import, ///
	csv(Audio audit test.csv) survey(survey.csv) choices(choices.csv) ///
	keepattrib(_all) replace
run import
compall Expected
cd ..

* Test 176
cd 176
odkmeta using import, ///
	csv(Audio audit test.csv) survey(survey.csv) choices(choices.csv) ///
	keepattrib(_all type) replace
run import
compall Expected
cd ..

* Test 178
cd 178
odkmeta using import, ///
	csv(odkmetatest111) survey(survey) choices(choices) replace ///
	dropattrib(type)
run import
compall Expected
cd ..

* Test 179
cd 179
odkmeta using import, ///
	csv(odkmetatest111) survey(survey) choices(choices) replace ///
	dropattrib(_all)
run import
compall Expected
cd ..

* Test 180
cd 180
odkmeta using import, ///
	csv(odkmetatest111) survey(survey) choices(choices) replace ///
	keepattrib(type)
run import
compall Expected
cd ..

* Test 181
cd 181
odkmeta using import, ///
	csv(odkmetatest111) survey(survey) choices(choices) replace ///
	keepattrib(_all)
run import
compall Expected
cd ..


/* -------------------------------------------------------------------------- */
					/* -relax-				*/

* Test 74
cd 74
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest2) survey(survey) choices(choices) replace
rcof `"noi do "ODK to Stata""' == 111
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest2) survey(survey) choices(choices) replace ///
	relax
get_warnings "ODK to Stata"
assert `"`r(badname_repeats)'"' == ""
assert "`r(badname_vars)'" == ""
assert `"`r(datanotform_repeats)'"' == ""
assert "`r(datanotform_vars)'" == ""
assert `"`r(formnotdata_repeats)'"' == `""""'
assert "`r(formnotdata_vars)'" == "DoesntExist"
compall Expected
cd ..

* Test 81
cd 81
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest28.csv) survey(survey.csv) choices(choices.csv) replace ///
	relax
get_warnings "ODK to Stata"
assert `"`r(badname_repeats)'"' == `""" "" "" """'
assert "`r(badname_vars)'" == "v3 v6 v9 v12"
assert `"`r(datanotform_repeats)'"' == ""
assert "`r(datanotform_vars)'" == ""
assert `"`r(formnotdata_repeats)'"' == `""""'
assert "`r(formnotdata_vars)'" == "DoesntExist"
compall Expected
cd ..

* Test 122
cd 122
odkmeta using import, ///
	csv(odkmetatest111) survey(survey) choices(choices) replace ///
	relax
get_warnings import
assert `"`r(badname_repeats)'"' == ""
assert "`r(badname_vars)'" == ""
assert `"`r(datanotform_repeats)'"' == ""
assert "`r(datanotform_vars)'" == ""
assert `"`r(formnotdata_repeats)'"' == `""" roster roster"'
assert "`r(formnotdata_vars)'" == "DoesntExist1 DoesntExist2 DoesntExist3"
compall Expected
cd ..

* Test 170
cd 170
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest28.csv) survey(survey.csv) choices(choices.csv) replace ///
	relax
get_warnings "ODK to Stata"
assert `"`r(badname_repeats)'"' == `""" "" "" """'
assert "`r(badname_vars)'" == "v3 v6 v9 v12"
assert `"`r(datanotform_repeats)'"' == `""""'
assert "`r(datanotform_vars)'" == "_submission_time"
assert `"`r(formnotdata_repeats)'"' == `""""'
assert "`r(formnotdata_vars)'" == "DoesntExist"
compall Expected
cd ..

* Test 182
cd 182
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest28.csv) survey(survey.csv) choices(choices.csv) replace ///
	relax dropattrib(_all)
get_warnings "ODK to Stata"
assert `"`r(badname_repeats)'"' == `""" "" "" """'
assert "`r(badname_vars)'" == "v3 v6 v9 v12"
assert `"`r(datanotform_repeats)'"' == `""""'
assert "`r(datanotform_vars)'" == "_submission_time"
assert `"`r(formnotdata_repeats)'"' == `""""'
assert "`r(formnotdata_vars)'" == "DoesntExist"
compall Expected
cd ..

* Test 183
cd 183
odkmeta using import, ///
	csv(odkmetatest111) survey(survey) choices(choices) replace ///
	relax
get_warnings import
assert `"`r(badname_repeats)'"' == ""
assert "`r(badname_vars)'" == ""
assert `"`r(datanotform_repeats)'"' == ""
assert "`r(datanotform_vars)'" == ""
assert `"`r(formnotdata_repeats)'"' == "roster"
assert "`r(formnotdata_vars)'" == "DoesntExist"
compall Expected
cd ..


/* -------------------------------------------------------------------------- */
					/* live-project testing		*/

if `project' {
	loc curdir "`c(pwd)'"
	c odkmeta_development
	cd cscript
	do "Project tests"
	cd "`curdir'"
}


/* -------------------------------------------------------------------------- */
					/* help file examples	*/

loc curdir "`c(pwd)'"
cd ../../help/example

cap erase import.do
odkmeta using import.do, csv("ODKexample.csv") survey("survey.csv") choices("choices.csv")
run import
compall Expected

odkmeta using import.do, csv("ODKexample.csv") ///
	survey("survey_fieldname.csv", name(fieldname)) choices("choices.csv") ///
	replace
run import

odkmeta using import.do, csv("ODKexample.csv") ///
	survey("survey_fieldname.csv", name(fieldname)) ///
	choices("choices_valuename.csv", name(valuename)) replace
run import

odkmeta using import.do, ///
	csv("ODKexample.csv") survey("survey.csv") choices("choices.csv") ///
	dropattrib(hint) replace
run import

odkmeta using import.do, ///
	csv("ODKexample.csv") survey("survey.csv") choices("choices.csv") ///
	dropattrib(_all) replace
run import

odkmeta using import.do, ///
	csv("ODKexample.csv") survey("survey.csv") choices("choices.csv") ///
	other(99) replace
run import

cd "`curdir'"


/* -------------------------------------------------------------------------- */
					/* user mistakes		*/

* Tests 33, 38
foreach i of numlist 33 38 {
	cd `i'
	#d ;
	rcof `"
		noi odkmeta using "ODK to Stata.do",
			csv(odkmetatest2.csv) survey(survey.csv) choices(choices.csv)
			replace
		"' == 198
	;
	#d cr
	cd ..
}

* Test 34
cd 34
#d ;
rcof `"
	noi odkmeta using "ODK to Stata.do",
		csv(odkmetatest36.csv) survey(survey.csv) choices(choices.csv) replace
	"' == 198
;
#d cr
cd ..

* Test 35
cd 35
#d ;
rcof `"
	noi odkmeta using "ODK to Stata.do",
		csv(odkmetatest36.csv) survey(survey.csv) choices(choices.csv) replace
	"' == 111
;
#d cr
cd ..

* Tests 37, 39, 40
foreach i of numlist 37 39 40 {
	cd `i'
	#d ;
	rcof `"
		noi odkmeta using "ODK to Stata.do",
			csv(odkmetatest2.csv) survey(survey.csv) choices(choices.csv)
		"' == 111
	;
	#d cr
	cd ..
}

* Test 53
cd 53
#d ;
rcof `"
	noi odkmeta using "ODK to Stata.do",
		csv(Audio audit test.csv)
		survey(survey.csv, type(Type))
		choices(choices.csv) replace
	"' == 111
;
#d cr
cd ..

* Test 55
cd 55
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest2.csv) survey(survey.csv) choices(choices.csv) replace
rcof `"noi do "ODK to Stata""' == 612
cd ..

* Tests 61, 62, 63, 64, 65, 66, 67, 68
forv i = 61/68 {
	cd `i'
	#d ;
	rcof `"
		noi odkmeta using "ODK to Stata.do",
			csv(odkmetatest36.csv) survey(survey.csv) choices(choices.csv)
			replace
		"' == 198
	;
	#d cr
	cd ..
}

* Test 82
cd 82
odkmeta using "ODK to Stata.do", ///
	csv(odkmetatest36.csv) survey(survey.csv) choices(choices.csv) replace
rcof `"run "ODK to Stata""' == 9
loc dtas : dir . file "*.dta"
assert !`:list sizeof dtas'
cd ..

* Test 119
cd 119
rcof ///
	"noi odkmeta using import, csv(data) survey(survey) choices(choices)" ///
	== 198
cd ..

* Test 120
cd 120
rcof ///
	"noi odkmeta using import, csv(data) survey(survey) choices(choices)" ///
	== 198
cd ..

* Test 149
cd 149
rcof ///
	"noi odkmeta using import, csv(data) survey(survey) choices(choices)" ///
	== 198
cd ..

* Test 150
cd 150
rcof ///
	"noi odkmeta using import, csv(data) survey(survey) choices(choices)" ///
	== 198
cd ..

* Test 151
cd 151
rcof ///
	"noi odkmeta using import, csv(data) survey(survey) choices(choices)" ///
	== 198
cd ..

* Test 152
cd 152
rcof ///
	"noi odkmeta using import, csv(data) survey(survey) choices(choices)" ///
	== 198
cd ..

* Test 153
cd 153
rcof ///
	"noi odkmeta using import, csv(data) survey(survey) choices(choices)" ///
	== 198
cd ..

* Test 154
cd 154
rcof ///
	"noi odkmeta using import, csv(data) survey(survey) choices(choices)" ///
	== 198
cd ..

* Test 155
cd 155
rcof ///
	"noi odkmeta using import, csv(data) survey(survey) choices(choices)" ///
	== 198
cd ..

* Test 156
cd 156
rcof ///
	"noi odkmeta using import, csv(data) survey(survey) choices(choices)" ///
	== 198
cd ..

* Test 158
cd 158
rcof ///
	"noi odkmeta using import, csv(data) survey(survey) choices(choices)" ///
	== 198
cd ..

* Test 159
cd 159
rcof ///
	"noi odkmeta using import, csv(data) survey(survey) choices(choices)" ///
	== 198
cd ..

* Test 160
cd 160
rcof ///
	"noi odkmeta using import, csv(data) survey(survey) choices(choices)" ///
	== 198
cd ..

* Test 161
cd 161
rcof ///
	"noi odkmeta using import, csv(data) survey(survey) choices(choices)" ///
	== 198
cd ..

* Test 177
cd 177
#d ;
rcof "noi odkmeta using import,
	csv(data) survey(survey) choices(choices)
	dropattrib(name) keepattrib(type)"
	== 198
;
#d cr
cd ..

* Test 185
cd 185
mkdir temp
loc dest temp/lspecialexp.mlib
copy "`c(sysdir_plus)'l/lspecialexp.mlib" "`dest'"
erase "`c(sysdir_plus)'l/lspecialexp.mlib"
mata: mata mlib index
cap findfile lspecialexp.mlib
assert _rc
cap mata: mata which specialexp()
assert _rc
rcof ///
	"noi odkmeta using import, csv(Audio audit test) survey(survey) choices(choices)" ///
	== 198
copy "`dest'" "`c(sysdir_plus)'l/lspecialexp.mlib"
erase "`dest'"
rmdir temp
mata: mata mlib index
cd ..

* Test 186
cd 186
#d ;
rcof
	"noi odkmeta using import,
	csv(odkmetatest56) survey(survey) choices(choices)
	other(junk)"
	== 198
;
#d cr
cd ..

* Test 187
cd 187
odkmeta using "ODK to Stata.do", ///
	csv(Audio audit test.csv) survey(survey.csv) choices(choices.csv)
#d ;
rcof
	`"noi odkmeta using "ODK to Stata.do",
	csv(Audio audit test.csv) survey(survey.csv) choices(choices.csv)"'
	== 602
;
#d cr
cd ..

* Test 188
cd 188
#d ;
rcof
	"noi odkmeta using import,
	csv(Audio audit test) survey(survey, type(DoesntExist)) choices(choices)"
	== 111
;
#d cr
cd ..

* Test 189
cd 189
#d ;
rcof
	"noi odkmeta using import,
	csv(Audio audit test) survey(survey) choices(choices)"
	== 198
;
#d cr
cd ..

* Test 190
cd 190
odkmeta using import, csv(odkmetatest111) survey(survey) choices(choices)
rcof "noi run import" == 9
cd ..

* Test 198
cd 198
rcof "noi odkmeta, csv(data) survey(survey) choices(choices)" == 100
cd ..

* Test 200
cd 200
rcof ///
	"noi odkmeta using import, csv(data) survey(survey) choices(choices)" == ///
	198
cd ..

* Test 201
cd 201
rcof ///
	"noi odkmeta using import, csv(data) survey(survey) choices(choices)" == ///
	198
cd ..

* Test 202
cd 202
rcof ///
	"noi odkmeta using import, csv(data) survey(survey) choices(choices)" == ///
	198
cd ..

* Test 204
cd 204
rcof ///
	"noi odkmeta using import, csv(data) survey(survey) choices(choices)" == ///
	198
cd ..

* Test 205
cd 205
rcof ///
	"noi odkmeta using import, csv(data) survey(survey) choices(choices)" == ///
	198
cd ..

* Test 206
cd 206
rcof ///
	"noi odkmeta using import, csv(data) survey(survey) choices(choices)" == ///
	198
cd ..

* Test 207
cd 207
rcof ///
	"noi odkmeta using import, csv(data) survey(survey) choices(choices)" == ///
	198
cd ..


/* -------------------------------------------------------------------------- */
					/* finish up			*/

timer off 1
timer list 1

if `profile' {
	cap conf f C:\ado\profile.do
	if !_rc ///
		run C:\ado\profile
}

timer list 1

log close odkmeta
