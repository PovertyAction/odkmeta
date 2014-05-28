vers 11.2

* Set the working directory to the odkmeta directory.
c odkmeta

clear all

adopath ++ `"`c(pwd)'"'

include io.mata
glo noinclude noinclude
include io_aux.mata
glo noinclude

mata:

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
