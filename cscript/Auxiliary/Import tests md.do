* Purpose: Import Tests.md as a Stata dataset.

vers 13.1

infix str line 1-`c(maxstrvarlen)' using Tests.md, clear

replace line = strtrim(line)
assert !strpos(line, char(9))

gen order = _n
su order if line == "<table>"
assert r(N) == 1
drop in 1/`r(min)'
drop order

assert line == "</table>" in L
drop in L

assert mod(_N, 6) == 0
assert (line == "<tr>")  + (mod(_n, 6) == 1) != 1
assert (line == "</tr>") + (mod(_n, 6) == 0) != 1
drop if inlist(line, "<tr>", "</tr>")

assert regexm(line, "^<th>.*</th>$") + inrange(_n, 1, 4) != 1
drop in 1/4
assert !strpos(line, "th>")

assert regexm(line, "^<td>.*</td>$")
replace line = regexs(1) if regexm(line, "^<td>(.*)</td>$")

gen j = ""
gen mod4 = mod(_n, 4)
assert mod4[_N] == 0
replace j = "id"			if mod4 == 1
replace j = "checkedby"		if mod4 == 2
replace j = "area"			if mod4 == 3
replace j = "desc"			if mod4 == 0
drop mod4

gen i = ceil(_n / 4)
reshape wide line, i(i) j(j) str
drop i
ren line* *
compress

destring id, replace
conf numeric var id

order id checkedby area desc
