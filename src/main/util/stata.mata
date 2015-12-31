vers 11.2

matamac

mata:

void pause_on()
	stata("pause on")

void pause_off()
	stata("pause off")

void pause()
	stata("pause")

// Returns the smallest Stata storage type necessary to store a string
// colvector.
`SS' smallest_vartype(`SC' s)
{
	`RS' max
	`SS' strpound

	max = max(strlen(s))
	strpound = sprintf("str%f", min((max((max, 1)), c("maxstrvarlen"))))
	if (c("stata_version") < 13)
		return(strpound)
	else
		return(max <= c("maxstrvarlen") ? strpound : "strL")
	/*NOTREACHED*/
}

/* Accepted styles: macro = local = global, char, list, label.
  o If no style is specified, all elements of s are enclosed in double quotes.
  o If style equals "macro", "local", or "global" (for strings specified to
	-local- and -global-, not other uses of locals and globals), elements are
	enclosed if they contain leading or trailing white space, start with a
	double quote, or start with one of the operators "=" and ":".
  o If style equals "char" (for strings specified to -char define-, not other
	uses of characteristics), elements are enclosed if they contain leading or
	trailing white space or start with a double quote.
  o If style equals "list" (for macro lists, for example, those specified to
	-foreach-), elements are enclosed if they contain white space or a double
	quote or if they are blank.
  o If style equals "label" (for value label text specified to -label define-),
	elements are enclosed if they contain characters other than A-Z, a-z, 0-9,
	and "_".

If style is "macro", "local", "global", or "char", and loop is specified as
nonzero, elements are enclosed if they contain multiple, consecutive internal
white space characters: such white space is stripped in loops. See
<http://www.stata.com/statalist/archive/2013-08/msg00888.html>.

Enclosed elements are enclosed in compound double quotes when they contain a
double quote.

It is assumed that s can be enclosed in double quotes. See -help specialexp-. */
`SM' adorn_quotes(`SM' s, |`SS' style, `RS' loop)
{
	`RS' n, i
	// "q" suffix for "quotes": "dq" for "double quote."
	`RM' dq, q
	`SR' namechars
	`SM' badchars, first, first2, last

	dq = strpos(s, `"""') :!= 0
	if (style == "") {
		q = J(rows(s), cols(s), 1)
	}
	else if (style == "list") {
		q = s :== "" :| strpos(s, " ") :| strpos(s, tab()) :| dq
	}
	else if (style == "label") {
		// The list of characters allowed in a Stata name
		namechars = tokens(c("ALPHA")), tokens(c("alpha")), strofreal(0..9), "_"
		// badchars is s with namechars removed
		badchars = s
		n = length(namechars)
		for (i = 1; i <= n; i++) {
			badchars = subinstr(badchars, namechars[i], "", .)
		}
		q = strlen(badchars) :!= 0
	}
	else if (anyof(("macro", "local", "global", "char"), style)) {
		// char
		first  = substr(s, 1, 1)
		first2 = substr(s, 1, 2)
		last   = substr(s, -1, 1)
		q = first :== " " :| first :== tab() :| first :== `"""' :|
			first2 :== "`" + `"""' :| last :== " " :| last :== tab()

		// Implement -loop-.
		if (args() >= 3 & loop) {
			q = q :| strpos(s, "  ") :| strpos(s, tab(2)) :|
				strpos(s, " " + tab()) :| strpos(s, tab() + " ")
		}

		// macro/local/global
		if (anyof(("macro", "local", "global"), style))
			q = q :| first :== "=" :| first :== ":"
	}
	else {
		_error("unknown style " + style)
	}

	return(!q :* s + q :* (dq :* "`" :+ `"""' :+ s :+ `"""' :+ dq :* "'"))
}

// Accepted styles: simple, compound.
// If no style is specified, both simple and compound double quotes are removed.
// If style == "simple", only simple double quotes are removed.
// If style == "compound", only compound double quotes are removed.
`SM' strip_quotes(`SM' s, |`SS' style)
{
	`RS' rows, cols, i, j
	`SM' strip

	if (!anyof(("simple", "compound", ""), style))
		_error("unknown style " + style)

	rows = rows(s)
	cols = cols(s)
	strip = J(rows, cols, "")
	for (i = 1; i <= rows; i++) {
		for (j = 1; j <= cols; j++) {
			if (style != "compound" & substr(s[i, j], 1, 1) == `"""' &
				substr(s[i, j], -1, .) == `"""') {
				strip[i, j] = substr(s[i, j], 2, strlen(s[i, j]) - 2)
			}
			else if (style != "simple" & substr(s[i, j], 1, 2) == "`" + `"""' &
				substr(s[i, j], -2, .) == `"""' + "'") {
				strip[i, j] = substr(s[i, j], 3, strlen(s[i, j]) - 4)
			}
			else {
				strip[i, j] = s[i, j]
			}
		}
	}

	return(strip)
}

/* Returns the Stata name that -insheet- would choose for s: all characters
other than a-z, A-Z, 0-9, and _ are removed, then leading digits of the
resulting string are removed, then the resulting string is truncated to 32
characters. If a digit follows a character other than a-z, A-Z, 0-9, or _ before
any a-z, A-Z, or _ is encountered, -insheet- would not convert s to a Stata
name, and -insheet_name()- returns "". */
`SS' insheet_name(`SS' s)
{
	// "c" suffix for "character": "badc" for "bad character."
	`RS' nondigit, badc, n, i
	`SS' name, c

	name = ""
	nondigit = badc = 0
	n = strlen(s)
	for (i = 1; i <= n; i++) {
		c = substr(s, i, 1)
		if (c >= "A" & c <= "Z" | c >= "a" & c <= "z" | c == "_") {
			nondigit = 1
			name = name + c
		}
		else if (c >= "0" & c <= "9") {
			if (nondigit)
				name = name + c
			else if (badc)
				return("")
		}
		else
			badc = 1
	}

	return(substr(name, 1, 32))
}

end
