pr add_class_decl
	vers 11.2

	syntax anything(name=fn id=filename)

	gettoken fn rest : fn
	if `:length loc rest' {
		di as err "invalid filename"
		ex 198
	}

	tempfile decl
	findfile `"`fn'"'
	mata: add_class_decl(st_global("r(fn)"), st_local("decl"))
	do `decl'
end

vers 11.2

findfile io_aux.mata
include `"`r(fn)'"'

mata:
void add_class_decl(`SS' _infile, `SS' _outfile)
{
	`SC' lines

	lines =
		"findfile type_definitions.do" \
		`"include `"\`r(fn)'"'"' \
		"mata:" \
		parse_class_decl(read_file(_infile)) \
		"end"
	write_file(_outfile, lines)
}
end
