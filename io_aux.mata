* Define file I/O functions that are not used in -odkmeta- but are used in
* auxiliary source code.

vers 11.2

findfile type_definitions.do
include `"`r(fn)'"'

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

// Parse a class declaration from source code, including only the -class- block
// and excluding method definitions.
`SC' parse_class_decl(`SC' lines)
{
	`RS' first, last, n
	`RC' linenum, test

	n = length(lines)
	if (!n)
		_error("no code")

	linenum = 1::n

	test = regexm(lines, "^class ")
	if (sum(test) != 1)
		_error("exactly one -class- not found")
	first = select(linenum, test)

	test = lines :== "}"
	if (!any(test))
		_error("close brace not found")
	last = min(select(linenum, test))

	if (first > last)
		_error("close brace before -class-")

	return(lines[|first \ last|])
}

end
