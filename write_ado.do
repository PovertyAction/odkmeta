vers 11.2

* Set the working directory to the odkmeta directory.
c odkmeta

clear all

adopath ++ `"`c(pwd)'"'

include io.mata
include io_aux.mata

mata:

`SR' at_comments(`SS' line)
{
	`SS' l

	l = strltrim(subinstr(line, char(9), " ", .))
	if (regexm(l, "^(\*|//)"))
		return(tokens(subinstr(l, regexs(0), "", 1)))
	else
		return(J(1, 0, ""))
	/*NOTREACHED*/
}

`SS' clean_file(`SS' fn, `boolean' drop_before_mata, `boolean' drop_end,
	|`boolean' drop_class_decl)
{
	`RS' n, ndecl, i
	`RC' todrop
	`SS' temp
	`SC' lines, decl, nodecl
	`boolean' found

	if (args() < 4)
		drop_class_decl = `False'
	if (drop_class_decl)
		assert(drop_before_mata)

	lines = strrtrim(read_file(fn))

	// Drop -mata:- and all lines preceding it.
	if (drop_before_mata) {
		if (any(at_comments(lines[1]) :== "@drop")) {
			n = length(lines)
			todrop = J(n, 1, 0)
			for (i = 2; i < n; i++) {
				if (any(at_comments(lines[i]) :== "@drop")) {
					todrop[|i \ i + 1|] = J(2, 1, 1)
					i++
				}
			}
			lines = select(lines, !todrop)
		}

		todrop = lines :== "mata:"
		if (sum(todrop) != 1) {
			errprintf("%s\n", fn)
			_error("did not find exactly one -mata:-")
		}

		n = select(1::length(lines), todrop)
		todrop[1::n] = J(n, 1, 1)
		lines = select(lines, !todrop)
	}

	// Drop the class declaration (error results if there is not exactly one).
	if (drop_class_decl) {
		decl = strrtrim(parse_class_decl(lines))
		ndecl = length(decl)
		n = length(lines)
		assert(n != ndecl)

		i = 0
		found = `False'
		while (++i <= n - ndecl + 1 & !found) {
			if (lines[|i \ i + ndecl - 1|] == decl) {
				if (i == 1)
					nodecl = J(0, 1, "")
				else
					nodecl = lines[|1 \ i - 1|]
				if (i + ndecl <= n)
					nodecl = nodecl \ lines[|i + ndecl \ n|]
				lines = nodecl
				found = `True'
			}
		}
	}

	// Drop -end-.
	if (drop_end) {
		todrop = lines :== "end"
		if (sum(todrop) != 1) {
			errprintf("%s\n", fn)
			_error("did not find exactly one -end-")
		}

		lines = select(lines, !todrop)
	}

	// Drop blank lines at the top of the file.
	todrop = lines :== ""
	n = min(select(1::length(lines), !todrop))
	assert(n != .)
	lines = lines[|n \ .|]

	// Drop blank lines at the bottom of the file.
	todrop = lines :== ""
	n = max(select(1::length(lines), !todrop))
	lines = lines[|1 \ n|]

	lines = "// " + fn \ "" \ lines \ ""

	temp = st_tempfilename()
	write_file(temp, lines)

	return(temp)
}

tempmata = st_tempfilename()
write_file(tempmata, "mata:" \ "")

classes = "Collection", "Group", "Repeat", "Field"
n = length(classes)
tempclasses = st_tempfilename(n)
for (i = 1; i <= n; i++) {
	lines = parse_class_decl(read_file(classes[i] + ".mata"))
	lines = "// `" + classes[i] + "' class declaration" \ lines \ ""
	write_file(tempclasses[i], lines)
}

infiles =
	clean_file("odkmeta.do",			`False', `False'),
	clean_file("type_definitions.do",	`False', `False'),
	tempmata,
	clean_file("string.mata",			`True', `True'),
	clean_file("io.mata",				`True', `True'),
	clean_file("stata.mata",			`True', `True'),
	clean_file("error.mata",			`True', `True'),
	clean_file("DoFileWriter.mata",		`True', `True'),
	clean_file("AttribSet.mata",		`True', `True'),
	tempclasses
for (i = 1; i <= length(classes); i++) {
	infiles = infiles,
		clean_file(classes[i] + ".mata", `True', `True', `True')
}
infiles = infiles,
	clean_file("List.mata",				`True', `True'),
	clean_file("write_do_start.mata",	`True', `True'),
	clean_file("write_do_end.mata",		`True', `True'),
	clean_file("write_survey.mata",		`True', `True'),
	clean_file("write_choices.mata",	`True', `False')
outfile = "odkmeta.ado"
if (fileexists(outfile))
	unlink(outfile)
append_files(infiles, outfile)

end
