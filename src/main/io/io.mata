vers 11.2

findfile type_definitions.do
include `"`r(fn)'"'

mata:

// Read the .csv file fn, returning it as a string matrix.
// If dropmiss is not specified or nonzero, rows of the .csv file whose values
// are all blank will be dropped.
`SM' read_csv(`SS' fn, |`RS' dropmiss)
{
	`RS' fh, pos, rows, cols, preveol, linecol, i, j
	`RR' eol, eolpos
	`RC' nonmiss
	`SS' csv
	`SR' tokens, line
	`SM' res
	transmorphic t

	// Read fn, storing it in csv.
	// The use of -st_fopen()- means that fn does not need the .csv extension.
	fh = st_fopen(fn, ".csv", "r")
	fseek(fh, 0, 1)
	pos = ftell(fh)
	fseek(fh, 0, -1)
	csv = fread(fh, pos)
	fclose(fh)

	if (!strlen(csv))
		return(J(0, 0, ""))

	// Tokenize csv, storing the result in tokens.
	t = tokeninit("", (",", char(13) + char(10), char(10), char(13)), `""""')
	tokenset(t, csv)
	tokens = tokengetall(t)
	eol = tokens :== char(13) + char(10) :| tokens :== char(10) :|
		tokens :== char(13)
	if (!eol[length(eol)]) {
		tokens = tokens, char(10)
		eol    = eol,    1
	}

	// Parse tokens.
	rows = sum(eol)
	res = J(rows, cols = 1, "")
	eolpos = select(1..cols(tokens), eol)
	// preveol is the position in tokens of the previous EOL character.
	preveol = 0
	for (i = 1; i <= rows; i++) {
		pos = eolpos[i]

		line = J(1, cols, "")
		linecol = 1
		for (j = preveol + 1; j < pos; j++) {
			if (tokens[j] != ",")
				line[linecol] = line[linecol] + tokens[j]
			else {
				// Adjust the number of columns of line.
				if (linecol >= cols)
					line = line, ""
				linecol++
			}
		}

		// Adjust the number of columns of res.
		if (cols < linecol) {
			res = res, J(rows(res), linecol - cols, "")
			cols = linecol
		}
		res[i,] = line

		preveol = pos
	}

	// Implement -dropmiss-: drop missing rows.
	if (dropmiss) {
		nonmiss = J(rows(res), 1, 0)
		for (i = 1; i <= cols; i++) {
			nonmiss = nonmiss :| res[,i] :!= ""
		}
		res = select(res, nonmiss)
	}

	// Clean up strings.
	if (rows(res)) {
		res = strip_quotes(res, "simple")
		res = subinstr(res, `""""', `"""', .)
		res = subinstr(res, char(13) + char(10), " ", .)
		res = subinstr(res, char(13), " ", .)
		res = subinstr(res, char(10), " ", .)
	}

	return(res)
}

/* Load the .csv file _fn into memory, clearing the dataset currently in memory.
-load_csv()- checks that the column headers specified to _opts exist:
_opts is a vector of names of locals that contain column headers.
_opt is the name of the -odkmeta- option associated with the .csv file.
_optvars is the name of a local in which -load_csv()- will save the
corresponding variable names of the column headers specified to _opts. */
void load_csv(`SS' _optvars, `SS' _fn, `SR' _opts, `SS' _opt)
{
	// "nopts" for "number of options"
	`RS' rows, cols, nopts, min, v, i
	`RR' col, optindex
	`SS' var, type
	`SR' vars
	`SM' csv

	csv = read_csv(_fn, 0)
	rows = rows(csv)
	cols = cols(csv)
	if (cols)
		col = 1..cols(csv)

	// Check that the required column headers exist.
	nopts = length(_opts)
	optindex = J(1, nopts, .)
	for (i = 1; i <= nopts; i++) {
		if (rows)
			min = min(select(col, csv[1,] :== st_local(_opts[i])))
		else
			min = .
		if (min != .)
			optindex[i] = min
		else {
			// [ID 35], [ID 37], [ID 39], [ID 40], [ID 53], [ID 188]
			errprintf("column header %s not found\n", st_local(_opts[i]))
			error_parsing(111, _opt, _opts[i] + "()")
			/*NOTREACHED*/
		}
	}

	st_dropvar(.)
	st_addobs(rows(csv) - 1)

	vars = J(1, cols, "")
	for (i = 1; i <= cols; i++) {
		var = insheet_name(csv[1, i])
		v = i
		while (var == "" | anyof(vars, var)) {
			var = sprintf("v%f", v++)
		}
		vars[i] = var

		if (rows == 1)
			type = "str1"
		else
			type = smallest_vartype(csv[|2, i \ ., i|])
		(void) st_addvar(type, var)

		st_global(sprintf("%s[Column_header]", var), csv[1, i])
	}
	if (rows > 1)
		st_sstore(., ., csv[|2, . \ ., .|])

	st_local(_optvars, invtokens(vars[optindex]))
}

// Add a tab to the start of each nonblank line of _infile, saving the result to
// _outfile.
void tab_file(`SS' _infile, `SS' _outfile)
{
	`RS' fhin, fhout
	`SM' line

	fhin = fopen(_infile, "r")
	fhout = fopen(_outfile, "w")
	while ((line = fget(fhin)) != J(0, 0, "")) {
		fput(fhout, tab(line != "") + line)
	}
	fclose(fhin)
	fclose(fhout)
}

// Append the files specified to _infiles, saving the result to _outfile.
void append_files(`SR' _infiles, `SS' _outfile)
{
	`RS' fhout, fhin, n, i
	`SM' line

	fhout = fopen(_outfile, "w")

	n = length(_infiles)
	for (i = 1; i <= n; i++) {
		if (fileexists(_infiles[i])) {
			fhin = fopen(_infiles[i], "r")
			while ((line = fget(fhin)) != J(0, 0, "")) {
				fput(fhout, line)
			}
			fclose(fhin)
		}
	}

	fclose(fhout)
}

end
