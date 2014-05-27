* Purpose: Change an -odkmeta- do-file so that it attempts to name variables
* using their short names.
pr shortnames
	vers 9

	syntax anything(name=fn id="filename")

	gettoken fn rest : fn
	if `:length loc rest' {
		di as err "invalid filename"
		ex 198
	}

	conf f `"`fn'"'

	mata: shortnames(st_local("fn"))
end

vers 9

loc RS	real scalar
loc SS	string scalar
loc SC	string colvector

mata:
void function shortnames(`SS' _fn)
{
	`RS' fh, row, rows, i
	`SS' findline
	`SC' lines, newlines
	transmorphic t

	// Read the file.
	fh = fopen(_fn, "r")
	fseek(fh, 0, 1)
	i = ftell(fh)
	fseek(fh, 0, -1)
	t = tokeninit("", (char(13) + char(10), char(10), char(13)), "")
	tokenset(t, fread(fh, i))
	fclose(fh)
	lines = tokengetall(t)'

	// Find the line.
	findline = char(9) + `"use "\`dta'", clear"'
	assert(sum(lines :== findline) == 1)
	row = select(1::rows(lines), lines :== findline)
	assert(row != rows(lines))

	// Add the new code.
	newlines =
		char(13) + char(10) \
		char(9) + "foreach var of varlist _all {" \
		2 * char(9) + `"if "\`:char \`var'[Odk_group]'" != "" {"' \
		3 * char(9) + `"local name = "\`:char \`var'[Odk_name]'" + ///"' \
		4 * char(9) + `"cond(\`:char \`var'[Odk_is_other]', "_other", "") + ///"' \
		4 * char(9) + `""\`:char \`var'[Odk_geopoint]'""' \
		3 * char(9) + `"local newvar = strtoname("\`name'")"' \
		3 * char(9) + "capture rename \`var' \`newvar'" \
		2 * char(9) + "}" \
		char(9) + "}"
	newlines = newlines +
		(((1::rows(newlines)) :!= rows(newlines)) :* (char(13) + char(10)))
	lines = lines[|1 \ row|] \ newlines \ lines[|row + 1 \ .|]

	// Write the new file.
	unlink(_fn)
	fh = fopen(_fn, "w")
	rows = rows(lines)
	for (i = 1; i <= rows; i++) {
		fwrite(fh, lines[i])
	}
	fclose(fh)
}
end
