vers 11.2

matamac

mata:

class `DoFileWriter' {
	public:
		`RS'	debug(), autotab()
		void	set_debug(), set_autotab(), open(), close(), indent(), write(),
				put()

	private:
		// If 1, add debugging information to the do-file as comments; 0
		// otherwise.
		`RS' debug
		// If 1, use naive rules (sufficient for -odkmeta-) to determine the
		// indent setting; 0 otherwise.
		`RS' autotab
		`RS' fh
		// The indent setting of the current line
		`RS' tab
		// Indicates whether the current line is a comment:
		// 0 - not a comment
		// 1 - one-line comment
		// 2 - multiline comment: start or middle (not end) of /* */ block
		`RS' comment
		/* joinline indicates the line number within a line-join block.
		Lines not in a line-join block have linejoin = 1. For example:

		display "Before line-join block"				linejoin = 1
		replace final_result = ///						linejoin = 1
			sqrt(first_side^2 + second_side^2) ///		linejoin = 2
			if type == "rectangle"						linejoin = 3
		display "After line-join block"					linejoin = 1

		*/
		`RS' joinline
		// lastjoin is 1 if the previous line had joinline > 1, i.e., if the
		// previous line should have been an indented line within a line-join
		// block; otherwise it is 0.
		`RS' lastjoin
		// The delimiter for the current line
		`SS' delim
		// The start of the current line
		`SS' linestart
		void new(), new_do_file()

		// Line parsing functions
		// These take the current line as an argument, assuming that it is
		// trimmed of leading and trailing white space.
		`RS'			open_block()
		static `RS'		close_block()
		`SS'			command()
		void			change_delim(), change_comment()
}

void `DoFileWriter'::new_do_file()
{
	tab = comment = lastjoin = 0
	joinline = 1
	delim = "cr"
	linestart = ""
}

void `DoFileWriter'::new()
{
	debug = 0
	autotab = 1
	new_do_file()
}

`RS' `DoFileWriter'::debug()
	return(debug)

void `DoFileWriter'::set_debug(`RS' setting)
	debug = setting != 0

`RS' `DoFileWriter'::autotab()
	return(autotab)

void `DoFileWriter'::set_autotab(`RS' setting)
	autotab = setting != 0

void `DoFileWriter'::open(`SS' fn, |`SS' mode, `RS' new_do)
{
	if (args() < 2)
		mode = "w"
	else if (mode != "w" & mode != "a")
		_error("invalid mode")

	fh = fopen(fn, mode)

	if (new_do)
		new_do_file()
}

void `DoFileWriter'::close()
	fclose(fh)

void `DoFileWriter'::indent(|`RS' tabchange)
{
	if (args())
		tab = tab + (nonmissing(tabchange) ? tabchange : 0)
	else
		tab++
}

// Returns the command (the first word) of a line.
`SS' `DoFileWriter'::command(`SS' line)
{
	`RS' space, tab

	space = strpos(line, " ")
	if (!space)
		space = .
	tab = strpos(line, tab())
	if (!tab)
		tab = .

	return(substr(line, 1, min((space, tab)) - 1))
}

// Returns 1 if a line opens a block and 0 otherwise.
// Specifically, it returns whether line is an open brace or -program-.
`RS' `DoFileWriter'::open_block(`SS' line)
	return(regexm(line, "{$") | regexm(command(line), "^pr(o(g(r(am?)?)?)?)?$"))

// Returns 1 if a line closes a block and 0 otherwise.
// Specifically, it returns whether line is a close brace or -end-.
`RS' `DoFileWriter'::close_block(`SS' line)
	return(regexm(line, "^(}|end)$"))

// If line is a -#delimit- command, -change_delim()- changes delim.
void `DoFileWriter'::change_delim(`SS' line)
{
	`SS' newdelim

	if (regexm(line,
		sprintf("^#[ %s]*(delimit|delimi|delim|deli|del|de|d)(.*)", tab()))) {
		if (anyof((" ", tab(), ";"), substr(regexs(2), 1, 1))) {
			newdelim = strtrim(subinstr(regexs(2), tab(), " ", .))
			if (newdelim != "cr" & newdelim != ";")
				_error("invalid #delimit command")
			delim = newdelim
		}
	}
}

// Changes comment to the comment type of line.
void `DoFileWriter'::change_comment(`SS' line)
{
	if (delim == ";")
		comment = 0
	else {
		if (comment == 2) {
			if (substr(line, -2, 2) == "*/")
				comment = 1
		}
		else {
			if (substr(line, 1, 2) == "/*")
				comment = substr(line, -2, .) == "*/" ? 1 : 2
			else if (substr(line, 1, 1) == "*" | substr(line, 1, 2) == "//")
				comment = 1
			else
				comment = 0
		}
	}
}

void `DoFileWriter'::write(`SS' s)
	linestart = linestart + s

void `DoFileWriter'::put(`SS' line)
{
	// "ws" for "white space"
	`RS' ws
	`SS' trim

	trim = linestart + line
	// Trim leading white space.
	do {
		ws = anyof((" ", tab()), substr(trim, 1, 1))
		if (ws)
			trim = substr(trim, 2, .)
	} while (ws)
	// Trim trailing white space.
	do {
		ws = anyof((" ", tab()), substr(trim, -1, 1))
		if (ws)
			trim = substr(trim, 1, strlen(trim) - 1)
	} while(ws)

	change_comment(trim)

	// Don't bother changing the indent for semicolon-delimited code:
	// leave it to the user.
	if (autotab & delim == "cr") {
		if (joinline == 1) {
			if (lastjoin)
				tab--

			if (!comment & close_block(trim))
				tab--
		}
		else if (joinline == 2)
			tab++
	}

	if (debug) {
		fwrite(fh, tab(trim != "" ? tab : 0))
		fwrite(fh, "/* ")
		fwrite(fh, sprintf("autotab = %f, ", autotab))
		fwrite(fh, sprintf("fh = %f, ", fh))
		fwrite(fh, sprintf("tab = %f, ", tab))
		fwrite(fh, sprintf("comment = %f, ", comment))
		fwrite(fh, sprintf("joinline = %f, ", joinline))
		fwrite(fh, sprintf("lastjoin = %f, ", lastjoin))
		fwrite(fh, sprintf("delim = %s, ", adorn_quotes(delim)))
		fwrite(fh, sprintf("linestart = %s, ", adorn_quotes(linestart)))
		fwrite(fh, sprintf("open_block() = %f, ", open_block(trim)))
		fwrite(fh, sprintf("close_block() = %f", close_block(trim)))
		fput(fh, " */")
	}

	fput(fh, tab(trim != "" ? tab : 0) + trim)

	if (autotab & delim == "cr" & !comment & open_block(trim))
		tab++

	if (joinline == 1 & !comment)
		change_delim(trim)

	// Track our place in the line-join block.
	lastjoin = joinline > 1
	if (delim == "cr" & !comment & regexm(trim, sprintf("[ %s]///$", tab())))
		joinline++
	else
		joinline = 1

	linestart = ""
}

end
