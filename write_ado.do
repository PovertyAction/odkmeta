vers 11.2

* Set the working directory to the odkmeta directory.
c odkmeta

clear all

adopath ++ `"`c(pwd)'"'

include io.mata

loc boolean		`RS'
loc True		1
loc False		0

mata:

`SS' eol()
	return((c("os") == "Windows") * char(13) + char(10))

`SM' read_file(`SS' fn)
{
	`RS' fh
	`SC' lines
	`SM' line

	fh = fopen(fn, "r")
	lines = J(0, 1, "")
	while ((line = fget(fh)) != J(0, 0, ""))
		lines = lines \ line
	fclose(fh)

	return(lines)
}

void fput_clone(`RS' fh, `SS' s)
	fput(fh, s)

void fwrite_clone(`RS' fh, `SS' s)
	fwrite(fh, s)

void write_file(`SS' fn, `SC' lines, |`boolean' write)
{
	`RS' fh, n, i
	pointer(void function) writer

	if (fileexists(fn))
		unlink(fn)
	fh = fopen(fn, "w")

	if (args() < 3)
		write = `False'
	writer = write ? &fwrite_clone() : &fput_clone()

	n = length(lines)
	for (i = 1; i <= n; i++)
		(*writer)(fh, lines[i])

	fclose(fh)
}

`SS' clean_file(`SS' fn, `boolean' drop_before_mata, `boolean' drop_end)
{
	`RS' n
	`RC' todrop
	`SS' temp
	`SC' lines

	lines = strrtrim(read_file(fn))

	// Drop -mata:- and all lines preceding it.
	if (drop_before_mata) {
		todrop = lines :== "mata:"
		if (sum(todrop) != 1) {
			errprintf("%s\n", fn)
			_error("did not find exactly one -mata:-")
		}

		n = select(1::length(lines), todrop)
		todrop[1::n] = J(n, 1, 1)
		lines = select(lines, !todrop)
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

infiles = (
	clean_file("odkmeta.do",			`False', `False'),
	clean_file("type_definitions.do",	`False', `True'),
	clean_file("string.mata",			`True', `True'),
	clean_file("io.mata",				`True', `False')
)
outfile = "odkmeta.ado"
if (fileexists(outfile))
	unlink(outfile)
append_files(infiles, outfile)

end
