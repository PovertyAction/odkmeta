*! version 1.0.0 Matthew White 19dec2013
pr odkmeta
	vers 11

	cap mata: mata which specialexp()
	if _rc {
		* [ID 185]
		di as err "SSC package specialexp required"
		di as err "to install, type {cmd:ssc install specialexp}"
		ex 198
	}

	#d ;
	syntax using/, csv(str)
		/* survey options */
		Survey(str asis) [DROPattrib(str asis) KEEPattrib(str asis) RELax]
		/* choices options */
		CHOices(str asis) [OTHer(str) ONEline]
		/* other options */
		[replace]
	;
	#d cr
	/* Abbreviations:
	-csv-: no known -CSV*- option.
	-Survey()- from -streg-'s -predict, Surv-; multiple -S*- options.
	-survey(, Type())- from -ds, has(Type)-.
	-survey(, Disabled())- from -cluster subcommand, Dissimilarity-; multiple
		-D*- options.
	-DROPattrib()- from -drop-.
	-KEEPattrib()- from -keep- and -cluster subcommand, KEEPcenters-.
	-RELax- from -sem, RELiability()-; multiple -REL*- options.
	-CHOices()- from -nlogittree, CHOice()-.
	-choices(, LIstname())- would be -Listname()- (from -list-) except for
		-choices(, label)-; instead from -return LIst-.
	-OTHer()- would be -Other()- (-cluster subcommand, Other()-) except for
		-oneline-; instead from -query OTHer-.
	-ONEline- would be -Oneline- (-matlist-) except for -other()-; instead from
		-xtregar, rhotype(ONEstep).
	*/

	* Parse -csv()-.
	loc stcsv st_local("csv")
	mata: if (postmatch(`stcsv', ".csv")) ///
		st_local("csv", substr(`stcsv', 1, strlen(`stcsv') - 4));;

	* Check -dropattrib()- and -keepattrib()-.
	if `:list sizeof dropattrib' & `:list sizeof keepattrib' {
		* [ID 177]
		di as err "options dropattrib() and keepattrib() are mutually exclusive"
		ex 198
	}

	* Parse -other()-.
	if "`other'" == "" ///
		loc other max
	else if !inlist("`other'", "min", "max") {
		cap conf integer n `other'
		if _rc & !(strlen("`other'") == 2 & inrange("`other'", ".a", ".z")) {
			* [ID 186]
			di as err "option other() invalid"
			ex 198
		}
	}

	* Add the .do extension to `using' if necessary.
	mata: if (pathsuffix(st_local("using")) == "") ///
		st_local("using", st_local("using") + ".do");;

	* Check -using- and option -replace-.
	cap conf new f `"`using'"'
	if ("`replace'" == "" & _rc) | ///
		("`replace'" != "" & !inlist(_rc, 0, 602)) {
		* [ID 187]
		conf new f `"`using'"'
	}

	preserve

	* -Parse -survey()-.
	/* -parse_survey- completes checking that involves single rows of the survey
	sheet; the rest is done in -write_survey()-. Unlike -write_survey()-,
	-parse_survey- displays the problematic row, and in general, where possible
	it is better to implement a check in -parse_survey- rather than
	-write_survey()-. However, all complex checks that involve Mata are best put
	in -write_survey()-. */
	parse_survey `survey'
	// "s" prefix for "-survey()-": "sfn" for "-survey()- filename."
	loc sfn			"`s(fn)'"
	loc type		"`s(type)'"
	loc sname		"`s(name)'"
	loc slabel		"`s(label)'"
	loc disabled	"`s(disabled)'"

	* Parse -choices()-.
	parse_choices `choices'
	// "c" prefix for "-choices()-": "cfn" for "-choices()- filename."
	loc cfn			"`s(fn)'"
	loc listname	"`s(listname)'"
	loc cname		"`s(name)'"
	loc clabel		"`s(label)'"

	tempfile startdo enddo chardo cleando1 cleando2 vallabdo encodedo ///
		encodetab fulldo

	* Do-file start and end
	mata: write_do_start(st_local("0"), "`startdo'")
	mata: write_do_end("`enddo'", "`relax'" != "")

	* -survey()-
	#d ;
	mata: write_survey(
		/* output do-files */ "`chardo'", "`cleando1'", "`cleando2'",
		/* output locals */ "anyrepeat", "otherlists",
		`"`sfn'"', st_local("csv"),
		/* column headers */ st_local("type"), st_local("sname"),
			st_local("slabel"), st_local("disabled"),
		st_local("dropattrib"), st_local("keepattrib"), "`relax'" != "")
	;
	#d cr

	* -choices()-
	#d ;
	mata: write_choices("`vallabdo'", "`encodedo'",
		`"`cfn'"',
		st_local("listname"), st_local("cname"), st_local("clabel"),
		"`otherlists'", "`other'",
		"`oneline'" != "")
	;
	#d cr

	* Append the do-file sections and export.
	if `anyrepeat' {
		cap conf f `encodedo'
		if !_rc {
			mata: tab_file("`encodedo'", "`encodetab'")
			copy `encodetab' `encodedo', replace
		}
	}
	mata: append_files(("`startdo'", "`vallabdo'", "`chardo'", "`cleando1'", ///
		"`encodedo'", "`cleando2'", "`enddo'"), "`fulldo'")
	qui copy `fulldo' `"`using'"', `replace'
end


/* -------------------------------------------------------------------------- */
					/* error message programs	*/

pr error_parsing
	syntax anything(name=rc id="return code"), opt(name) [SUBopt(str)]

	mata: error_parsing(`rc', "`opt'", "`subopt'")
	/*NOTREACHED*/
end

pr error_overlap
	syntax anything(name=overlap id=overlap), ///
		opts(namelist min=2 max=2) [SUBopts]

	mata: error_overlap(strip_quotes(st_local("overlap")), tokens("`opts'"), ///
		"`subopts'" != "")
end

					/* error message programs	*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* parse user input		*/

pr check_col
	syntax varname(str) if/, opt(passthru) [SUBopt(name) LIstvars(varlist)]

	tempvar touse
	gen `touse' = `if'
	qui cou if `touse'
	if r(N) {
		* Determine the first problematic row.
		tempvar order
		gen `order' = _n
		* Add an extra observation so the row number is correct.
		qui set obs `=_N + 1'
		qui replace `touse' = 0 in L
		qui replace `order' = 0 in L
		sort `order'
		qui replace `order' = _n
		qui su `order' if `touse'
		loc first = r(min)

		if "`listvars'" != "" ///
			li `listvars' in `first', ab(32)

		* [ID 61], [ID 62], [ID 63], [ID 64], [ID 65], [ID 66], [ID 67], [ID 68]
		mata: errprintf("invalid %s attribute '%s'\n", ///
			st_global("`varlist'[Column_header]"), ///
			st_sdata(`first', "`varlist'"))
		error_parsing 198, ///
			`opt' `=cond("`subopt'" != "", "sub(`subopt'())", "")'
		/*NOTREACHED*/
	}
end

pr parse_survey, sclass
	cap noi syntax anything(name=fn id=filename equalok everything), ///
		[Type(str) name(str) LAbel(str) Disabled(str)]
	loc opt opt(survey)
	if _rc {
		error_parsing `=_rc', `opt'
		/*NOTREACHED*/
	}

	* Check column names.
	loc opts type name label disabled
	forv i = 1/`:list sizeof opts' {
		gettoken opt1 opts : opts

		if `"``opt1''"' == "" ///
			loc `opt1' `opt1'

		foreach opt2 of loc opts {
			if `"``opt1''"' == `"``opt2''"' {
				error_overlap `"``opt1''"', opts(`opt1' `opt2') sub
				error_parsing 198, `opt'
				/*NOTREACHED*/
			}
		}
	}

	mata: st_local("fn", strip_quotes(st_local("fn")))
	mata: load_csv("optvars", st_local("fn"), ("type", "name", "label"), ///
		"survey")
	gettoken typevar optvars : optvars
	gettoken namevar optvars : optvars

	if !_N {
		* [ID 35]
		di as err "no fields in survey sheet"
		error_parsing 198, `opt'
		/*NOTREACHED*/
	}

	unab all : _all
	loc listvars listvars(`all')

	tempvar nonmiss
	egen `nonmiss' = rownonmiss(_all), str
	tempvar stdtype
	loc matastd stdtype(st_sdata(., "`typevar'"))
	mata: st_sstore(., st_addvar(smallest_vartype(`matastd'), "`stdtype'"), ///
		`matastd')

	* Check the word count of `typevar'.
	tempvar select
	gen `select' = inlist(word(`stdtype', 1), "select_one", "select_multiple")
	check_col `typevar' if `select' & wordcount(`stdtype') != ///
		2 + (word(`stdtype', wordcount(`stdtype')) == "or_other"), ///
		`opt' sub(type) `listvars'

	* Check that the list names specified to select variables are Stata names.
	check_col `typevar' if `select' & ///
		(word(`stdtype', 2) != strtoname(word(`stdtype', 2)) | ///
		strpos(word(`stdtype', 2), "`")), ///
		`opt' sub(type) `listvars'

	* Check the word count of `namevar'.
	check_col `namevar' if wordcount(`namevar') != 1 & ///
		!regexm(`stdtype', "^end (group|repeat)$") & `nonmiss', ///
		`opt' sub(name) `listvars'

	sret loc fn			"`fn'"
	sret loc type		"`type'"
	sret loc name		"`name'"
	sret loc label		"`label'"
	sret loc disabled	"`disabled'"
end

pr parse_choices, sclass
	cap noi syntax anything(name=fn id=filename equalok everything), ///
		[LIstname(str) name(str) LAbel(str)]
	loc opt opt(choices)
	if _rc {
		error_parsing `=_rc', `opt'
		/*NOTREACHED*/
	}

	* Check column names.
	if "`listname'" == "" ///
		loc listname list_name
	loc opts listname name label
	forv i = 1/`:list sizeof opts' {
		gettoken opt1 opts : opts

		if `"``opt1''"' == "" ///
			loc `opt1' `opt1'

		foreach opt2 of loc opts {
			if `"``opt1''"' == `"``opt2''"' {
				error_overlap `"``opt1''"', opts(`opt1' `opt2') sub
				error_parsing 198, `opt'
				/*NOTREACHED*/
			}
		}
	}

	mata: st_local("fn", strip_quotes(st_local("fn")))
	mata: load_csv("optvars", st_local("fn"), ("listname", "name", "label"), ///
		"choices")
	gettoken listnamevar optvars : optvars
	gettoken namevar     optvars : optvars
	gettoken labelvar    optvars : optvars

	unab all : _all
	loc listvars listvars(`all')
	tempvar nonmiss
	egen `nonmiss' = rownonmiss(_all), str

	check_col `listnamevar' ///
		if (strtrim(`listnamevar') != strtoname(strtrim(`listnamevar')) | ///
		strpos(`listnamevar', "`")) & `nonmiss', ///
		`opt' sub(listname) `listvars'

	check_col `namevar' if mi(strtrim(`namevar')) & `nonmiss', ///
		`opt' sub(name) `listvars'

	check_col `labelvar' if mi(`labelvar') & `nonmiss', ///
		`opt' sub(label) `listvars'

	sret loc fn			"`fn'"
	sret loc listname	"`listname'"
	sret loc name		"`name'"
	sret loc label		"`label'"
end

					/* parse user input		*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* type definitions, etc.	*/

* Using `:char evarname[charname]' instead of `evarname[charname]':
* <http://www.stata.com/statalist/archive/2013-08/msg00186.html>.

vers 11

loc RS	real scalar
loc RR	real rowvector
loc RC	real colvector
loc RM	real matrix
loc SS	string scalar
loc SR	string rowvector
loc SC	string colvector
loc SM	string matrix
loc TS	transmorphic scalar
loc TR	transmorphic rowvector
loc TC	transmorphic colvector
loc TM	transmorphic matrix

* Convert real x to string using -strofreal(x, `RealFormat')-.
loc RealFormat	""%24.0g""

* The prefix of characteristic names
loc CharPre		""Odk_""

* Names of locals specified by the user at the start of the do-file
loc DateMask		""datemask""
loc TimeMask		""timemask""
loc DatetimeMask	""datetimemask""

loc InsheetCode		real
loc InsheetCodeS	`InsheetCode' scalar
loc InsheetOK		0
loc InsheetBad		1
loc InsheetDup		2
loc InsheetV		3

loc DoFileWriter	do_file_writer
loc DoFileWriterS	class `DoFileWriter' scalar

loc AttribProps		odk_attrib_props
loc AttribPropsS	struct `AttribProps' scalar

loc Attrib		odk_attrib
loc AttribS		struct `Attrib' scalar
loc AttribR		struct `Attrib' rowvector

loc AttribSet	odk_attrib_set
loc AttribSetS	class `AttribSet' scalar

loc Collection		odk_collection
loc CollectionS		class `Collection' scalar

loc Group	odk_group
loc GroupS	class `Group' scalar

loc Repeat		odk_repeat_group
loc RepeatS		class `Repeat' scalar

loc Field	odk_field
loc FieldS	class `Field' scalar

loc List	odk_list
loc ListS	struct `List' scalar
loc ListR	struct `List' rowvector

mata:

					/* type definitions, etc.	*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* string functions		*/

`SS' tab(|`RS' n)
	return((args() ? n : 1) * char(9))

`RM' prematch(`SM' s, `SM' pre)
	return(substr(s, 1, strlen(pre)) :== pre)

`RM' postmatch(`SM' s, `SM' post)
	return(substr(s, -strlen(post), .) :== post)

// Standardizes a colvector of field types.
`SC' stdtype(`SC' s)
{
	`RC' select
	`SC' std

	std = strtrim(stritrim(s))
	std = regexr(std, "^begin_group$",	"begin group")
	std = regexr(std, "^end_group$",	"end group")
	std = regexr(std, "^begin_repeat$",	"begin repeat")
	std = regexr(std, "^end_repeat$",	"end repeat")
	std = regexr(std, "^select one ",	"select_one ")
	select = regexm(std, "^select_(one|multiple) ")
	std = !select :* std + select :* regexr(std, " or other$", " or_other")

	return(std)
}

					/* string functions		*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* interface with Stata		*/

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

					/* interface with Stata		*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* do-file writer class		*/

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

					/* do-file writer class		*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* attribute classes	*/

// The properties of a single field attribute
struct `AttribProps' {
	// Column header
	`SS' header
	// Stata characteristic name
	`SS' char
	// Column number
	`RS' col
	// Nonzero if the attribute is defined in the form; 0 if not.
	`RS' form
	// Nonzero if the attribute has a special purpose in the do-file; 0 if it is
	// used only to attach characteristics.
	`RS' special
	// Nonzero to store the attribute in the dataset; 0 otherwise.
	`RS' keep
}

// A single field attribute, used solely within class `AttribSet'
// `Attrib' and `AttribProps' are separated so the user can freely change props
// (the elements of `AttribProps') but can modify name only through `AttribSet'.
struct `Attrib' {
	`SS' name
	`AttribPropsS' props
}

// A set of field attributes. Attributes are uniquely identified by their names.
// I initially implemented this as an associative array, but I ran into some
// issues (see <http://www.stata.com/statalist/archive/2013-05/msg00525.html>),
// so I opted for this approach.
class `AttribSet' {
	public:
		`RS'							n()
		`TR'							vals()
		pointer(`AttribPropsS') scalar	add(), get()
		void							drop()

	private:
		`AttribR'		attribs
		static `TS'		val()
}

`RS' `AttribSet'::n()
	return(length(attribs))

// Adds an attribute with a specified name and missing properties to the set,
// returning a pointer to the attribute's properties.
pointer(`AttribPropsS') scalar `AttribSet'::add(`SS' name)
{
	`RS' n, i
	`AttribS' attrib

	n = n()
	for (i = 1; i <= n; i++) {
		if (attribs[i].name == name)
			_error("duplicate attribute name")
	}

	attrib.name = name
	attribs = attribs, attrib
	return(&attribs[length(attribs)].props)
}

void `AttribSet'::drop(`SS' name)
{
	`RS' n, i

	n = n()
	for (i = 1; i <= n; i++) {
		if (attribs[i].name == name) {
			attribs = attribs[select(1..n, (1..n) :!= i)]
			return
		}
	}

	_error(sprintf("attribute '%s' not found", name))
}

// Returns a single attribute's properties.
pointer(`AttribPropsS') scalar `AttribSet'::get(`SS' name)
{
	`RS' n, i

	n = n()
	for (i = 1; i <= n; i++) {
		if (attribs[i].name == name)
			return(&attribs[i].props)
	}

	_error(sprintf("attribute '%s' not found", name))
}

// Takes an attribute and a property name and returns the value of the specified
// property of the attribute.
`TS' `AttribSet'::val(`AttribS' attrib, `SS' val)
{
	if (val == "name")
		return(attrib.name)
	else if (val == "header")
		return(attrib.props.header)
	else if (val == "char")
		return(attrib.props.char)
	else if (val == "col")
		return(attrib.props.col)
	else if (val == "form")
		return(attrib.props.form)
	else if (val == "special")
		return(attrib.props.special)
	else if (val == "keep")
		return(attrib.props.keep)

	_error(sprintf("unknown attribute property '%s'", val))
}

// Returns a single property for all attributes as a rowvector. The sort order
// of the vector is stable.
`TR' `AttribSet'::vals(`SS' val)
{
	`RS' n, i
	`TR' vals

	n = n()
	vals = J(1, n, val(`Attrib'(), val))
	for (i = 1; i <= n; i++) {
		vals[i] = val(attribs[i], val)
	}

	return(vals)
}

					/* attribute classes	*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* collection class		*/

// Parent class of `Group' and `Repeat'
// There are no instances of `Collection', only of `Group' and `Repeat'.
class `Collection' {
	public:
		/* getters and setters */
		`RS'							order()
		`SS'							name()
		pointer(`FieldS') scalar		field()
		pointer(`FieldS') rowvector		fields()
		void							set_name(), add_field()

		`RS'							main(), inside(), level()
		pointer(`FieldS') scalar		first_field(), last_field()

	protected:
		virtual pointer(`TS') scalar		trans_parent()
		virtual pointer(`TS') rowvector		trans_children()

	private:
		static `RS'						ctr
		`RS'							order
		`SS'							name
		pointer(`FieldS') rowvector		fields

		`RS'							_level()
		static `RR'						field_orders()
		pointer(`FieldS') rowvector		all_fields()
		void							new()
}

void `Collection'::new()
{
	if (ctr == .)
		ctr = 0
	order = ++ctr
}

// Returns a pointer to the parent collection stored in the child class.
pointer(`TS') scalar `Collection'::trans_parent()
	_error("`Collection'.trans_parent() invoked")

// Returns pointers to the children collections stored in the child class.
pointer(`TS') rowvector `Collection'::trans_children()
	_error("`Collection'.trans_children() invoked")

// Returns the relative position of the collection within the form.
`RS' `Collection'::order()
	return(order)

`SS' `Collection'::name()
	return(name)

void `Collection'::set_name(`SS' newname)
	name = newname

// Returns pointers to the fields that the collection contains.
pointer(`FieldS') rowvector `Collection'::fields()
	return(fields)

pointer(`FieldS') scalar `Collection'::field(`RS' i)
	return(fields[i])

// Adds newfield to fields.
void `Collection'::add_field(pointer(`FieldS') scalar newfield)
	fields = fields, newfield

// Returns 1 if the `Collection' represents the main fields, not a group or
// repeat group; returns 0 otherwise.
`RS' `Collection'::main()
	return(trans_parent() == NULL)

// Returns 1 if the collection does not represent the main fields; return 0
// otherwise.
`RS' `Collection'::inside()
	return(trans_parent() != NULL)

// Returns the level of a collection within its family tree: for the main
// fields, -_level()- returns 0; for collections among the main fields,
// -_level()- returns 1; for collections within those collections, -_level()-
// returns 2; and so on.
`RS' `Collection'::_level(pointer(`CollectionS') scalar collec)
{
	if (collec->main())
		return(0)
	else
		return(_level(collec->trans_parent()) + 1)
	/*NOTREACHED*/
}

`RS' `Collection'::level()
	return(_level(&this))

// Returns pointers to the collection's fields as well as the fields of the
// collection's descendants.
pointer(`FieldS') rowvector `Collection'::all_fields()
{
	`RS' n, i
	pointer(`FieldS') rowvector allfields
	pointer(`CollectionS') rowvector children

	allfields = fields

	children = trans_children()
	n = length(children)
	for (i = 1; i <= n; i++) {
		allfields = allfields, children[i]->all_fields()
	}

	return(allfields)
}

// Returns a pointer to the first field by field order within the collection.
pointer(`FieldS') scalar `Collection'::first_field(|`RS' include_children)
{
	`RR' orders
	pointer(`FieldS') rowvector f

	if (args() & include_children)
		f = all_fields()
	else
		f = fields

	if (!length(f))
		return(NULL)
	else {
		orders = field_orders(f)
		return(select(f, orders :== min(orders)))
	}
}

// Returns a pointer to the last field by field order within the collection.
pointer(`FieldS') scalar `Collection'::last_field(|`RS' include_children)
{
	`RR' orders
	pointer(`FieldS') rowvector f

	if (args() & include_children)
		f = all_fields()
	else
		f = fields

	if (!length(f))
		return(NULL)
	else {
		orders = field_orders(f)
		return(select(f, orders :== max(orders)))
	}
}

					/* collection class		*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* group class			*/

// Represents ODK groups.
class `Group' extends `Collection' {
	public:
		/* getters and setters */
		pointer(`GroupS') scalar		parent(), child()
		pointer(`GroupS') rowvector		children()
		void							set_parent(), add_child()

		`SS'							long_name(), st_list()

	protected:
		virtual pointer(`TS') scalar		trans_parent()
		virtual pointer(`TS') rowvector		trans_children()

	private:
		pointer(`GroupS') scalar		parent
		pointer(`GroupS') rowvector		children

}

pointer(`TS') scalar `Group'::trans_parent()
	return(parent)

pointer(`GroupS') scalar `Group'::parent()
	return(parent)

void `Group'::set_parent(pointer(`GroupS') scalar newparent)
	parent = newparent

pointer(`TS') rowvector `Group'::trans_children()
	return(children)

pointer(`GroupS') rowvector `Group'::children()
	return(children)

pointer(`GroupS') scalar `Group'::child(`RS' i)
	return(children[i])

// Adds newchild to children.
void `Group'::add_child(pointer(`GroupS') scalar newchild)
	children = children, newchild

// Returns the group's long name.
`SS' `Group'::long_name()
{
	if (main())
		return("")
	else
		return(parent->long_name() + name() + "-")
	/*NOTREACHED*/
}

// Returns the name of the group appended to a string list of the names of the
// groups in which the group is nested.
`SS' `Group'::st_list()
{
	`SS' parentlist

	if (main())
		return("")
	else {
		parentlist = parent->st_list()
		return(parentlist + (parentlist != "") * " " +
			adorn_quotes(name(), "list"))
	}
	/*NOTREACHED*/
}

					/* group class			*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* repeat class			*/

// Represents repeat groups.
class `Repeat' extends `Collection' {
	public:
		pointer(`RepeatS') scalar		parent(), child()
		pointer(`RepeatS') rowvector	children()
		pointer(`FieldS') scalar		parent_set_of(), child_set_of()
		void							set_parent(), add_child(),
										set_parent_set_of(), set_child_set_of()

	protected:
		virtual pointer(`TS') scalar		trans_parent()
		virtual pointer(`TS') rowvector		trans_children()

	private:
		pointer(`RepeatS') scalar		parent
		pointer(`FieldS') scalar		parentsetof, childsetof
		pointer(`RepeatS') rowvector	children
}

pointer(`TS') scalar `Repeat'::trans_parent()
	return(parent)

pointer(`RepeatS') scalar `Repeat'::parent()
	return(parent)

void `Repeat'::set_parent(pointer(`RepeatS') scalar newparent)
	parent = newparent

pointer(`TS') rowvector `Repeat'::trans_children()
	return(children)

pointer(`RepeatS') rowvector `Repeat'::children()
	return(children)

pointer(`RepeatS') scalar `Repeat'::child(`RS' i)
	return(children[i])

// Adds newchild to children.
void `Repeat'::add_child(pointer(`RepeatS') scalar newchild)
	children = children, newchild

// Every repeat group is associated with two SET-OF fields, one in the repeat
// group and one in its parent.
// -parent_set_of()- returns a pointer to the parent's SET-OF field.
pointer(`FieldS') scalar `Repeat'::parent_set_of()
	return(parentsetof)

void `Repeat'::set_parent_set_of(pointer(`FieldS') scalar newsetof)
	parentsetof = newsetof

// Every repeat group is associated with two SET-OF fields, one in the repeat
// group and one in its parent.
// -child_set_of()- returns a pointer to this repeat's SET-OF field (the child
// SET-OF).
pointer(`FieldS') scalar `Repeat'::child_set_of()
	return(childsetof)

void `Repeat'::set_child_set_of(pointer(`FieldS') scalar newsetof)
	childsetof = newsetof

					/* repeat class			*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* field and collection classes		*/

class `Field' {
	public:
		/* getters and setters */
		`RS'							order(), is_dup()
		`SS'							name(), type(), label(), attrib(),
										dup_var(), other_dup_name()
		`SR'							attribs()
		pointer(`GroupS') scalar		group()
		pointer(`RepeatS') scalar		repeat()
		void							set_name(), set_type(), set_label(),
										set_attribs(), set_group(),
										set_repeat(), set_dup(), set_dup_var()

		`RS'							begin_repeat(), end_repeat()
		`SS'							long_name(), st_long()
		`InsheetCodeS'					insheet()
		pointer(`GroupS') rowvector		begin_groups(), end_groups()

	private:
		static `RS'						ctr
		`RS'							order
		`SS'							name, type, label, dupvar, otherdup
		`SR'							attribs
		pointer(`GroupS') scalar		group
		pointer(`RepeatS') scalar		repeat

		pointer(`GroupS') rowvector		_begin_groups(), _end_groups()
		void							new()
}

// Last method of `Collection' to define
// Returns the field orders of a rowvector of fields.
`RR' `Collection'::field_orders(pointer(`FieldS') rowvector f)
{
	`RS' n, i
	`RR' orders

	n = length(f)
	orders = J(1, n, .)
	for (i = 1; i <= n; i++) {
		orders[i] = f[i]->order()
	}

	return(orders)
}

void `Field'::new()
{
	if (ctr == .)
		ctr = 0
	order = ++ctr
}

// Returns the relative position of the field within the form.
`RS' `Field'::order()
	return(order)

`SS' `Field'::name()
	return(name)

void `Field'::set_name(`SS' newname)
	name = newname

`SS' `Field'::type()
	return(type)

void `Field'::set_type(`SS' newtype)
	type = newtype

`SS' `Field'::label()
	return(label)

void `Field'::set_label(`SS' newlabel)
	label = newlabel

`SR' `Field'::attribs()
	return(attribs)

`SS' `Field'::attrib(`RS' i)
	return(attribs[i])

void `Field'::set_attribs(`SR' newattribs)
	attribs = newattribs

// Returns 1 if the Stata name of the field is the same as a previous field's;
// otherwise it returns 0.
`RS' `Field'::is_dup()
	return(otherdup != "")

/* If -is_dup()- == 1 and the field is associated with multiple variables,
returns the ODK long name of the first variable of the field with a duplicate
Stata name. For example, if mygeo is a geopoint field, then field.name() ==
"mygeo", and field.dup_var() could be "mygeo-Latitude". If -is_dup()- == 0 or
the field is associated with a single variable, -dup_var()- returns "". */
`SS' `Field'::dup_var()
	return(dupvar)

// If -is_dup()- == 1, returns the ODK long name of the other field with the
// same Stata name. Otherwise, it returns "".
`SS' `Field'::other_dup_name()
	return(otherdup)

// Sets the name of the other field with the same Stata name and, for fields
// associated with multiple variables, the name of the first variable with a
// duplicate Stata name.
void `Field'::set_dup(`SS' newotherdup, |`SS' newdupvar)
{
	otherdup = newotherdup
	dupvar   = newdupvar
}

// For fields associated with multiple variables, sets the name of the first
// variable with a duplicate Stata name.
void `Field'::set_dup_var(`SS' newdupvar)
	dupvar = newdupvar

// Returns a pointer to the group in which the field is nested.
// If the field is not in a group, it returns NULL.
pointer(`GroupS') scalar `Field'::group()
	return(group)

// Sets the pointer to the group in which the field is nested.
void `Field'::set_group(pointer(`GroupS') scalar newgroup)
	group = newgroup

// Returns a pointer to the repeat group in which the field is nested.
// If the field is not in a repeat group, it returns NULL.
pointer(`RepeatS') scalar `Field'::repeat()
	return(repeat)

// Sets the pointer to the repeat group in which the field is nested.
void `Field'::set_repeat(pointer(`RepeatS') scalar newrepeat)
	repeat = newrepeat

// Returns the long name of the field.
`SS' `Field'::long_name()
	return((type != "begin repeat") * group->long_name() + name)

// Returns the long name of the field as a Stata name.
`SS' `Field'::st_long()
	return(insheet_name(long_name()))

/* Returns an `InsheetCode' scalar representing how -insheet- will import the
field's variables' long names. Return codes:
`InsheetOK'		All the variables' names are OK.
`InsheetBad'	-insheet- will not convert at least one of the variables' names
				to a Stata name.
`InsheetDup' 	At least one of the variables' names is duplicate, either with
				another variable of the same field or with a variable of another
				field.
`InsheetV'		At least one of the variables' names is a v# name and another
				field in the same repeat group is `InsheetBad' or `InsheetDup'.
*/
`InsheetCodeS' `Field'::insheet()
{
	`RS' n, i

	if (st_long() == "")
		return(`InsheetBad')
	if (is_dup())
		return(`InsheetDup')

	// geopoint variables (not fields) have a nonnumeric suffix, so they never
	// match the pattern v#.
	if (regexm(st_long(), "^v[1-9][0-9]*$") & type != "geopoint" &
		group->main()) {
		n = length(repeat->fields())
		for (i = 1; i <= n; i++) {
			if (repeat->field(i)->order != order &
				(repeat->field(i)->st_long() == "" |
				repeat->field(i)->is_dup() != "")) {
				return(`InsheetV')
			}
		}
	}

	return(`InsheetOK')
}

// Returns 1 if the field is the first field in its repeat group; returns 0 if
// not.
`RS' `Field'::begin_repeat()
{
	pointer(`FieldS') scalar first

	if (!repeat->inside())
		return(0)

	first = repeat->first_field()
	if (first == NULL)
		return(0)
	return(order == first->order)
}

// Returns 1 if the field is the last field in its repeat group; returns 0 if
// not.
`RS' `Field'::end_repeat()
{
	pointer(`FieldS') scalar last

	if (!repeat->inside())
		return(0)

	last = repeat->last_field()
	if (last== NULL)
		return(0)
	return(order == last->order())
}

// Returns pointers to the groups for which the field is the first field.
pointer(`GroupS') rowvector `Field'::_begin_groups(pointer(`GroupS') scalar g)
{
	pointer(`FieldS') scalar groupfirst

	if (g == NULL)
		return(J(1, 0, NULL))
	if (g->main())
		return(J(1, 0, NULL))

	groupfirst = g->first_field(1)
	if (groupfirst == NULL)
		return(J(1, 0, NULL))

	if (order == groupfirst->order())
		return(_begin_groups(g->parent()), g)
	else
		return(J(1, 0, NULL))
	/*NOTREACHED*/
}

pointer(`GroupS') rowvector `Field'::begin_groups()
	return(_begin_groups(group))

// Returns pointers to the groups for which the field is the last field.
pointer(`GroupS') rowvector `Field'::_end_groups(pointer(`GroupS') scalar g)
{
	pointer(`FieldS') scalar grouplast

	if (g == NULL)
		return(J(1, 0, NULL))
	if (g->main())
		return(J(1, 0, NULL))

	grouplast = g->last_field(1)
	if (grouplast == NULL)
		return(J(1, 0, NULL))

	if (order == grouplast->order())
		return(g, _end_groups(g->parent()))
	else
		return(J(1, 0, NULL))
	/*NOTREACHED*/
}

pointer(`GroupS') rowvector `Field'::end_groups()
	return(_end_groups(group))

					/* field and collection classes		*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* list structure		*/

struct `List' {
	`SS' listname
	`SC' names, labels
	`RS' vallab, matalab
}

					/* list structure		*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* error message functions	*/

void error_parsing(`RS' rc, `SS' opt, |`SS' subopt)
{
	// [ID 61]
	if (subopt != "")
		errprintf("invalid %s suboption\n", subopt)
	errprintf("invalid %s() option\n", opt)
	exit(rc)
}

void error_overlap(`SS' overlap, `SR' opts, |`RS' subopts)
{
	// No [ID] required.
	errprintf("%s cannot be specified to both options %s() and %s()\n",
		adorn_quotes(overlap, "list"), opts[1], opts[2])
	if (args() < 3 | !subopts)
		exit(198)
}

					/* error message functions	*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* file I/O				*/

// Read the .csv file fn, returning it as a string matrix.
// If dropmiss is not specified or nonzero, rows of the .csv file whose values
// are all blank will be dropped.
`SM' read_csv(`SS' fn, |`RS' dropmiss)
{
	`RS' fh, numeol, cols, last, rows, pos, linecol, i, j
	`RR' eol, eolpos
	// "nonmi" for "nonmissing"
	`RC' nonmi
	`SS' csv
	`SR' tokens, line
	`SM' res
	transmorphic t

	// Read fn, storing it in csv.
	// The use of -st_fopen()- means that fn doesn't need the .csv extension.
	fh = st_fopen(fn, ".csv", "r")
	fseek(fh, 0, 1)
	pos = ftell(fh)
	fseek(fh, 0, -1)
	csv = fread(fh, pos)
	fclose(fh)

	if (!strlen(csv))
		return(J(0, 0, ""))

	// Tokenize csv, storing the result in tokens.
	t = tokeninit("", (",", char(13) + char(10), char(10), char(13)), (`""""'))
	tokenset(t, csv)
	tokens = tokengetall(t)
	eol = tokens :== char(13) + char(10) :| tokens :== char(10) :|
		tokens :== char(13)
	if (!eol[cols(eol)]) {
		tokens = tokens, char(10)
		eol    = eol,    1
	}

	// Parse tokens.
	numeol = sum(eol)
	res = J(numeol, cols = 1, "")
	eolpos = select(1..cols(tokens), eol)
	last = rows = 0
	for (i = 1; i <= numeol; i++) {
		pos = eolpos[i]

		line = J(1, cols, "")
		linecol = 1
		for (j = last + 1; j < pos; j++) {
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
		res[++rows,] = line

		last = pos
	}
	// Adjust the number of rows of res.
	res = res[|1, . \ rows, .|]

	// Implement -dropmiss-.
	if (dropmiss) {
		// Drop missing rows.
		nonmi = J(rows(res), 1, 0)
		for (i = 1; i <= cols; i++) {
			nonmi = nonmi :| res[,i] :!= ""
		}
		res = select(res, nonmi)
	}

	// Clean up strings.
	res = strip_quotes(res, "simple")
	res = subinstr(res, `""""', `"""', .)
	res = subinstr(res, char(13) + char(10), " ", .)
	res = subinstr(res, char(13), " ", .)
	res = subinstr(res, char(10), " ", .)

	return(res)
}

/* Load the .csv file _fn into memory, clearing the dataset currently in memory.
-load_csv()- checks that the column headers specified to _opts exist.
_opt is the name of the -odkmeta- option associated with the .csv file.
_optvars is the name of a local in which -load_csv()- will save the
corresponding variable names of the column headers specified to _opts. */
void load_csv(`SS' _optvars, `SS' _fn, `SR' _opts, `SS' _opt)
{
	// "nopts" for "number of options"
	`RS' rows, cols, nopts, min, len, i
	`RR' col, optindex
	`SS' var, optvars
	`SR' vars
	`SM' csv

	csv = read_csv(_fn, 0)
	rows = rows(csv)
	cols = cols(csv)
	if (cols)
		col = 1..cols(csv)

	// Check that required column headers exist.
	optindex = J(1, 0, .)
	nopts = cols(_opts)
	for (i = 1; i <= nopts; i++) {
		if (rows)
			min = min(select(col, csv[1,] :== st_local(_opts[i])))
		else
			min = .
		if (min != .)
			optindex = optindex, min
		else {
			// [ID 35], [ID 37], [ID 39], [ID 40], [ID 53], [ID 188]
			errprintf("column header %s not found\n", st_local(_opts[i]))
			error_parsing(111, _opt, _opts[i] + "()")
			/*NOTREACHED*/
		}
	}

	st_dropvar(.)
	st_addobs(rows(csv) - 1)

	vars = J(1, 0, "")
	for (i = 1; i <= cols; i++) {
		var = insheet_name(csv[1, i])
		if (var == "" | anyof(vars, var))
			var = sprintf("v%f", i)
		vars = vars, var
		if (rows == 1)
			len = 0
		else
			len = max(strlen(csv[|2, i \ ., i|]))
		len = max((len, 1))
		len = min((len, c("maxstrvarlen")))
		(void) st_addvar(sprintf("str%f", len), var)
		st_global(sprintf("%s[Column_header]", var), csv[1, i])
	}
	if (rows > 1)
		st_sstore(., ., csv[|2, . \ ., .|])

	optvars = ""
	for (i = 1; i <= nopts; i++) {
		optvars = optvars + (optvars != "") * " " + vars[optindex[i]]
	}
	st_local(_optvars, optvars)
}

// Add a tab at the start of each nonblank line of _infile, saving the result to
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

					/* file I/O				*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* do-file start/end	*/

void write_do_start(`SS' _0, `SS' _outfile)
{
	`DoFileWriterS' df

	df.open(_outfile)

	// Notes at the top of the do-file
	df.put(sprintf("* Created on %s at %s by the following -odkmeta- command:",
		strofreal(date(c("current_date"), "DMY"), "%tdMonth_dd,_CCYY"),
		c("current_time")))
	df.put("* odkmeta " + _0)
	df.put("* -odkmeta- version 1.0.0 was used.")
	df.put("")

	// -version-
	df.put("version 9")
	df.put("")

	// User parameters not covered by an option
	df.put("* Change these values as required by your data.")
	df.put("")
	df.put("* The mask of date values in the .csv files. See -help date()-.")
	df.put("* Fields of type date or today have these values.")
	df.put(sprintf("local %s MDY", `DateMask'))
	df.put("* The mask of time values in the .csv files. See -help clock()-.")
	df.put("* Fields of type time have these values.")
	df.put(sprintf("local %s hms", `TimeMask'))
	df.put("* The mask of datetime values in the .csv files. " +
		"See -help clock()-.")
	df.put("* Fields of type datetime, start, or end have these values.")
	df.put(sprintf("local %s MDYhms", `DatetimeMask'))
	df.put("")

	df.put("")
	df.put(sprintf("/* %s */", 74 * "-"))
	df.put("")
	df.put("* Start the import.")
	df.put("* Be cautious about modifying what follows.")
	df.put("")

	// Set system parameters, saving their current values so they can be
	// restored at the end of the do-file.
	df.put("local varabbrev = c(varabbrev)")
	df.put("set varabbrev off")
	df.put("")

	write_temp_mata(df)

	df.close()
}

void write_do_end(`SS' _outfile, `RS' _relax)
{
	`DoFileWriterS' df

	df.open(_outfile, "w")

	write_drop_temp_mata(df)

	df.put("set varabbrev \`varabbrev'")
	df.put("")

	write_final_warnings(df, _relax)

	df.close()
}

void write_temp_mata(`DoFileWriterS' df)
{
	df.put("* Find unused Mata names.")
	df.put("foreach var in values text {")
	df.put(`"mata: st_local("external", invtokens(direxternal("*")'))"')
	df.put("tempname \`var'")
	df.put("while \`:list var in external' {")
	df.put("tempname \`var'")
	df.put("}")
	df.put("}")
	df.put("")
}

void write_drop_temp_mata(`DoFileWriterS' df)
{
	df.put("capture mata: mata drop \`values' \`text'")
	df.put("")
}

void write_final_warnings(`DoFileWriterS' df, `RS' _relax)
{
	df.put("* Display warning messages.")
	df.put("quietly {")
	df.put("noisily display")
	df.put("")
	df.put("#delimit ;")
	df.put("local problems")
	df.indent()
	df.put("allbadnames")
	df.indent()
	df.put(`""The following variables' names differ from their field names,"')
	df.put(`"which could not be {cmd:insheet}ed:""')
	df.indent(-1)
	df.put("alldatanotform")
	df.indent()
	df.put(`""The following variables appear in the data but not the form:""')
	df.indent(-1)
	if (_relax) {
		df.put("allformnotdata")
		df.indent()
		df.put(`""The following fields appear in the form but not the data:""')
		df.indent(-1)
	}
	df.indent(-1)
	df.put(";")
	df.put("#delimit cr")
	df.put("while \`:list sizeof problems' {")
	df.put("gettoken local problems : problems")
	df.put("gettoken desc  problems : problems")
	df.put("")
	df.put("local any 0")
	df.put("foreach vars of local \`local' {")
	df.put("local any = \`any' | \`:list sizeof vars'")
	df.put("}")
	df.put("if \`any' {")
	df.put(`"noisily display as txt "{p}\`desc'{p_end}""')
	df.put(`"noisily display "{p2colset 0 34 0 2}""')
	df.put("noisily display as txt " +
		`""{p2col:repeat group}variable name{p_end}""')
	df.put(`"noisily display as txt "{hline 65}""')
	df.put("")
	df.put("forvalues i = 1/\`:list sizeof repeats' {")
	df.put("local repeat : word \`i' of \`repeats'")
	df.put("local vars   : word \`i' of \`\`local''")
	df.put("")
	df.put("foreach var of local vars {")
	df.put(`"noisily display as res "{p2col:\`repeat'}\`var'{p_end}""')
	df.put("}")
	df.put("}")
	df.put("")
	df.put(`"noisily display as txt "{hline 65}""')
	df.put(`"noisily display "{p2colreset}""')
	df.put("}")
	df.put("}")
	df.put("}")
}

					/* do-file start/end	*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* -survey()-			*/

void write_survey(
	/* output do-files */ `SS' _chardo, `SS' _cleando1, `SS' _cleando2,
	/* output locals */ `SS' _anyrepeat, `SS' _otherlists,
	`SS' _survey, `SS' _csv,
	/* column headers */ `SS' _type, `SS' _name, `SS' _label, `SS' _disabled,
	`SS' _dropattrib, `SS' _keepattrib, `RS' _relax)
{
	`RS' anyrepeat, nfields, anyselect, anymultiple, anynote, isselect, i
	`RR' col
	`SS' list
	`SR' otherlists
	`SM' survey
	`DoFileWriterS' df
	`AttribSetS' attr
	pointer(`GroupS') rowvector groups
	pointer(`RepeatS') rowvector repeats
	pointer(`FieldS') rowvector fields

	// Set default values for the output locals.
	st_local(_anyrepeat,  "0")
	st_local(_otherlists, "")

	survey = read_csv(_survey)
	if (rows(survey) < 2)
		return

	attr = get_attribs(survey, _type, _name, _label, _disabled,
		_dropattrib, _keepattrib)

	// Drop the column headers.
	survey = survey[|2, . \ ., .|]

	// Trim white space for the type, name, and disabled attributes.
	col = attr.get("type")->col, attr.get("name")->col,
		attr.get("disabled")->col
	col = select(col, col :!= .)
	survey[,col] = strtrim(stritrim(survey[,col]))

	// Exclude disabled fields.
	if (attr.get("disabled")->col != .)
		survey = select(survey, survey[,attr.get("disabled")->col] :!= "yes")

	if (!rows(survey)) {
		// [ID 156], [ID 189]
		errprintf("no enabled fields in survey sheet\n")
		error_parsing(198, "survey")
		/*NOTREACHED*/
	}

	survey[,attr.get("type")->col] = stdtype(survey[,attr.get("type")->col])

	pragma unset groups
	pragma unset fields
	pragma unset repeats
	get_fields(fields, groups, repeats, survey, attr)

	// Get aggregate information about the fields.
	otherlists = J(1, 0, "")
	anyselect = anymultiple = anynote = 0
	nfields = length(fields)
	for (i = 1; i <= nfields; i++) {
		isselect = 0
		if (prematch(fields[i]->type(), "select_one "))
			isselect = anyselect = 1
		else if (prematch(fields[i]->type(), "select_multiple "))
			isselect = anyselect = anymultiple = 1
		else if (fields[i]->type() == "note")
			anynote = 1

		if (isselect) {
			list = substr(fields[i]->type(),
				strpos(fields[i]->type(), " ") + 1, .)
			if (postmatch(list, " or_other")) {
				list = substr(list, 1, strpos(list, " ") - 1)
				if (!anyof(otherlists, list))
					otherlists = otherlists, list
			}
		}
	}

	// Write the characteristics do-file, a section of the final do-file that
	// -insheet-s the .csv files and imports the characteristics.
	df.open(_chardo)

	write_survey_start(df, attr)
	write_fields(df, fields, attr, _csv, _relax)

	df.close()

	// Write the first cleaning do-file, a section of the final do-file that
	// completes all cleaning before the -encode-ing of string lists. (See
	// -write_choices()-.)
	df.open(_cleando1)

	anyrepeat = length(repeats) > 1
	if (anyrepeat)
		write_dta_loop_start(df)
	if (anymultiple) {
		write_rename_for_split(df, repeats)
		write_split_select_multiple(df, attr)
	}
	if (anynote)
		write_drop_note_vars(df, attr)
	write_dates_times(df, attr)
	write_field_labels(df, attr)

	df.close()

	// Write the second cleaning do-file, a section of the final do-file that
	// completes all cleaning after the -encode-ing of string lists.
	df.open(_cleando2, "w", 0)

	if (anyselect)
		write_attach_vallabs(df, attr)
	if (length(otherlists))
		write_recode_or_other(df)

	write_compress(df)
	write_repeat_locals(df, attr, (anyrepeat ? "\`repeat'" : ""), anyrepeat)

	if (!anyrepeat) {
		write_drop_attrib(df, attr)
		write_save_dta(df, _csv, "", anyrepeat, _relax)
	}
	else {
		write_dta_loop_end(df)
		write_merge_repeats(df, repeats, attr, _csv)
	}

	df.close()

	// Store values in output locals.
	st_local(_anyrepeat,   strofreal(anyrepeat))
	st_local(_otherlists,  invtokens(otherlists))
}

`AttribSetS' get_attribs(`SM' survey,
	/* column headers */ `SS' _type, `SS' _name, `SS' _label, `SS' _disabled,
	`SS' _dropattrib, `SS' _keepattrib)
{
	`RS' dropall, keepall, cols, max, n, i, j
	`RR' col
	`SS' char, base
	`SR' dropattrib, keepattrib, headers, opts, notfound, newattribs,
		formattribs, chars
	`AttribSetS' attr
	pointer(`SR') p
	pointer(`AttribPropsS') scalar attrib

	// Parse _dropattrib and _keepattrib.
	dropattrib = uniqrows(tokens(_dropattrib)')'
	if (dropall = anyof(dropattrib, "_all")) {
		dropattrib = select(dropattrib, dropattrib :!= "_all")
		if (dropattrib == J(0, 0, ""))
			dropattrib = J(1, 0, "")
	}
	keepattrib = uniqrows(tokens(_keepattrib)')'
	if (keepall = anyof(keepattrib, "_all")) {
		keepattrib = select(keepattrib, keepattrib :!= "_all")
		if (keepattrib == J(0, 0, ""))
			keepattrib = J(1, 0, "")
	}

	// Issue warning messages for -dropattrib()- and -keepattrib()-.
	headers = survey[1,]
	opts = "keepattrib", "dropattrib"
	p    = &keepattrib,  &dropattrib
	for (i = 1; i <= length(opts); i++) {
		notfound = J(1, 0, "")
		for (j = 1; j <= length(*p[i]); j++) {
			if (!anyof(headers, (*p[i])[j]))
				notfound = notfound, (*p[i])[j]
		}
		if (length(notfound)) {
			printf("{p}{txt}note: option {opt %s()}: attribute%s ",
				opts[i], (length(notfound) > 1) * "s")
			for (j = 1; j <= length(notfound); j++) {
				printf("{res}%s ", adorn_quotes(notfound[j], "list"))
			}
			printf("{txt}not found.{p_end}\n")
		}
	}

	// Initial definitions of attributes in the form:
	// define .header, .form, and .special.
	// type
	attrib = attr.add("type")
	attrib->header = _type
	attrib->form = attrib->special = 1
	// name
	attrib = attr.add("name")
	attrib->header = _name
	attrib->form = attrib->special = 1
	// label
	attrib = attr.add("label")
	attrib->header = _label
	attrib->form = attrib->special = 1
	// disabled
	attrib = attr.add("disabled")
	attrib->header = _disabled
	attrib->form = attrib->special = 1
	// Other (not special) attributes
	cols = cols(survey)
	for (i = 1; i <= cols; i++) {
		if (!anyof((attr.vals("header"), dropattrib), survey[1, i]) & !dropall &
			any(survey[|2, i \ ., i|] :!= "")) {
			attrib = attr.add(sprintf("col%f", i))
			attrib->header = survey[1, i]
			attrib->form = 1
			attrib->special = 0
		}
	}

	// Definitions of attributes not in the form
	newattribs = "bad_name", "group", "long_name", "repeat", "list_name",
		"or_other", "is_other", "geopoint"
	n = length(newattribs)
	for (i = 1; i <= n; i++) {
		attrib = attr.add(newattribs[i])
		attrib->char = newattribs[i]
		attrib->form = 0
		attrib->special = 1
		attrib->keep = !dropall
	}

	// Finish definitions of attributes in the form:
	// define .col, .char, and .keep.
	col = 1..cols
	formattribs = select(attr.vals("name"), attr.vals("form"))
	n = length(formattribs)
	for (i = 1; i <= n; i++) {
		attrib = attr.get(formattribs[i])

		// .col
		attrib->col = min(select(col, survey[1,] :== attrib->header))

		// .char
		j = 2
		max = 32 - strlen(`CharPre')
		base = strlower(subinstr(strtoname(attrib->header), "`", "_", .))
		while (strpos(base, "__"))
			base = subinstr(base, "__", "_", .)
		while (substr(base, -1, 1) == "_" & strlen(base) > 1)
			base = substr(base, 1, strlen(base) - 1)
		char = base = substr(base, 1, max)
		chars = attr.vals("char")
		while (anyof(chars, char)) {
			char = substr(base, 1, max - strlen(strofreal(j, `RealFormat'))) +
				strofreal(j, `RealFormat')
			j++
		}
		attrib->char = char

		// .keep
		if (length(dropattrib) | dropall)
			attrib->keep = !(dropall | anyof(dropattrib, attrib->header))
		else if (length(keepattrib) | keepall)
			attrib->keep = keepall | anyof(keepattrib, attrib->header)
		else
			attrib->keep = 1
	}

	return(attr)
}

// See the comments for -_get_fields()-.
// Process rows of survey that do not contain groups or repeat groups other than
// SET-OF fields.
void _get_fields_base(pointer(`FieldS') rowvector fields, `RS' fpos,
	`SM' survey, `AttribSetS' attr,
	pointer(`GroupS') scalar parentgroup,
	pointer(`RepeatS') scalar parentrepeat, `SR' odknames, `SR' stnames)
{
	`RS' rows, geopoint, other, i, j
	`SS' odkname
	`SR' dupname, suffix

	rows = rows(survey)
	for (i = 1; i <= rows; i++) {
		if (!anyof(("end group", "end repeat"),
			survey[i, attr.get("type")->col])) {
			// group
			fields[fpos]->set_group(parentgroup)
			parentgroup->add_field(fields[fpos])

			// repeat
			fields[fpos]->set_repeat(parentrepeat)
			parentrepeat->add_field(fields[fpos])

			// type
			fields[fpos]->set_type(survey[i, attr.get("type")->col])

			// name
			fields[fpos]->set_name((fields[fpos]->type() == "begin repeat") *
				("SET-OF-" + parentgroup->long_name()) +
				survey[i, attr.get("name")->col])
			// The -odkmeta- do-file assumes that KEY and PARENT_KEY do not have
			// duplicate Stata variable names.
			if (anyof(("KEY", "PARENT_KEY"),
				insheet_name(fields[fpos]->long_name()))) {
				// [ID 160], [ID 161]
				errprintf("the Stata variable name of field %s%s is %s; " +
					"not allowed\n",
					fields[fpos]->long_name(),
					fields[fpos]->repeat()->inside() *
					(" in repeat group " + fields[fpos]->repeat()->name()),
					insheet_name(fields[fpos]->long_name()))
				error_parsing(198, "survey")
				/*NOTREACHED*/
			}
			// 234 = 244 - 10, where 10 is the length of the longest variable
			// suffix ("-Longitude"). This check is necessary because -insheet-
			// is used in the do-file to create lists of full field names, and
			// -insheet- truncates strings at 244 characters.
			if (strlen(fields[fpos]->long_name()) > 234) {
				// [ID 157], [ID 158], [ID 159]
				errprintf("the long name of field %s%s exceeds " +
					"the maximum allowed 234 characters\n",
					fields[fpos]->long_name(),
					fields[fpos]->repeat()->inside() *
					(" in repeat group " + fields[fpos]->repeat()->name()))
				error_parsing(198, "survey")
				/*NOTREACHED*/
			}

			// Duplicate name
			geopoint = fields[fpos]->type() == "geopoint"
			other = regexm(fields[fpos]->type(),
				"^select_(one|multiple) .* or_other$")
			if (fields[fpos]->st_long() != "") {
				if (!geopoint & !other) {
					dupname = select(odknames,
						stnames :== fields[fpos]->st_long())
					if (!length(dupname)) {
						odknames = odknames, fields[fpos]->long_name()
						stnames = stnames, fields[fpos]->st_long()
					}
				}
				else {
					dupname = J(1, 0, "")
					suffix = geopoint ? "-" :+ ("Latitude", "Longitude",
						"Altitude", "Accuracy") : ("", "_other")
					j = 0
					while (++j <= length(suffix) & !length(dupname)) {
						odkname = fields[fpos]->long_name() + suffix[j]
						dupname = select(odknames,
							stnames :== insheet_name(odkname))
						if (length(dupname)) {
							fields[fpos]->set_dup_var(
								fields[fpos]->long_name() + suffix[j])
						}
						else {
							odknames = odknames, odkname
							stnames = stnames, insheet_name(odkname)
						}
					}
				}
				if (length(dupname))
					fields[fpos]->set_dup(dupname[1])
			}

			// .label
			fields[fpos]->set_label(survey[i, attr.get("label")->col])

			// .attribs
			fields[fpos]->set_attribs(survey[i,
				select(attr.vals("col"), !attr.vals("special"))])

			fpos++
		}
	}
}

/* fields is a rowvector of pointers to the fields, groups is a rowvector of
pointers to the fields' groups, and repeats is a rowvector of pointers to the
fields' repeat groups. These arguments are replaced.

fpos (for "fields position") is the index of the first element of fields in
which no field has been saved. gpos (for "groups" position) is the index of the
first element of groups in which no group has been saved. rpos (for "repeats
position") is the index of the first element of repeats in which no repeat has
been saved.

survey is the survey sheet of the form with no column headers.
attr is the field attributes.

parentgroup is a pointer to the group in which the fields of survey are nested.
parentrepeat is a pointer to the repeat group in which the fields of survey are
nested.

odknames and stnames (for "Stata names") are parallel lists that contain,
respectively, the ODK and Stata long names of the fields of parentrepeat. A
field whose Stata name is already in stnames has a duplicate Stata name.
*/
void _get_fields(pointer(`FieldS') rowvector fields,
	pointer(`GroupS') rowvector groups, pointer(`RepeatS') rowvector repeats,
	`RS' fpos, `RS' gpos, `RS' rpos, `SM' survey, `AttribSetS' attr,
	pointer(`GroupS') scalar parentgroup,
	pointer(`RepeatS') scalar parentrepeat, `SR' odknames, `SR' stnames)
{
	`RS' rows, firstbeginrow, group, endrow
	`RC' begingroup, beginrepeat, begin, row
	`SS' name, longname
	`SR' repeatodk, repeatstata
	pointer(`RepeatS') scalar newrepeat

	rows = rows(survey)
	if (!rows)
		return

	begingroup  = survey[,attr.get("type")->col] :== "begin group"
	beginrepeat = survey[,attr.get("type")->col] :== "begin repeat"
	begin = begingroup :| beginrepeat

	if (!any(begin)) {
		_get_fields_base(fields, fpos, survey, attr, parentgroup, parentrepeat,
			odknames, stnames)
		return
	}

	// survey is "begin group/repeat" by itself, not followed by a field.
	if (rows == 1)
		return

	row = 1::rows
	firstbeginrow = min(select(row, begin))
	// The first row is not "begin group/repeat".
	if (firstbeginrow > 1) {
		// Process the fields before the next group or repeat group.
		_get_fields(fields, groups, repeats,
			fpos, gpos, rpos, survey[|1, . \ firstbeginrow - 1, .|], attr,
			parentgroup, parentrepeat, odknames, stnames)

		// Process the remaining fields.
		_get_fields(fields, groups, repeats,
			fpos, gpos, rpos, survey[|firstbeginrow, . \ ., .|], attr,
			parentgroup, parentrepeat, odknames, stnames)
	}
	// The first row is "begin group/repeat".
	else {
		group = begingroup[firstbeginrow]
		if (group) {
			endrow = min(select(row, runningsum(begingroup -
				(survey[,attr.get("type")->col] :== "end group")) :== 0))
		}
		else {
			endrow = min(select(row, runningsum(beginrepeat -
				(survey[,attr.get("type")->col] :== "end repeat")) :== 0))
		}

		name = survey[1, attr.get("name")->col]
		longname = parentgroup->long_name() + name
		if (endrow == 2) {
			if (group) {
				// [ID 152]
				errprintf("group %s contains no fields\n", longname)
			}
			else {
				// [ID 153]
				errprintf("repeat group %s contains no fields\n", name)
			}
			error_parsing(198, "survey")
			/*NOTREACHED*/
		}
		if (endrow == .) {
			if (group) {
				// [ID 154]
				errprintf(`"group %s: "begin group" without "end group"\n"',
					longname)
			}
			else {
				// [ID 155]
				errprintf("repeat group %s: " +
					`""begin repeat" without "end repeat"\n"',
					name)
			}
			error_parsing(198, "survey")
			/*NOTREACHED*/
		}

		if (group) {
			// Add the group to groups.
			groups[gpos]->set_name(name)
			groups[gpos]->set_parent(parentgroup)
			parentgroup->add_child(groups[gpos])
			gpos++

			// Process the fields nested in the group.
			_get_fields(fields, groups, repeats,
				fpos, gpos, rpos, survey[|2, . \ endrow - 1, .|], attr,
				groups[gpos - 1], parentrepeat, odknames, stnames)
		}
		else {
			// Add the repeat group to repeats.
			newrepeat = repeats[rpos++]
			newrepeat->set_name(longname)
			newrepeat->set_parent(parentrepeat)
			parentrepeat->add_child(newrepeat)

			// Process the first row as the SET-OF field in the parent
			// repeat group.
			_get_fields_base(fields, fpos, survey[|1, . \ 1, .|], attr,
				parentgroup, parentrepeat, odknames, stnames)
			newrepeat->set_parent_set_of(fields[fpos - 1])

			// Process the fields nested in the repeat group.
			// Passing groups[1] (the main fields) as parentgroup because
			// the fields of a repeat group are treated as if they are not
			// nested in the repeat group's group.
			pragma unset repeatodk
			pragma unset repeatstata
			_get_fields(fields, groups, repeats,
				fpos, gpos, rpos, survey[|2, . \ endrow - 1, .|], attr,
				groups[1], newrepeat, repeatodk, repeatstata)

			/* Process the first row as the SET-OF field in the child repeat
			group (the newly created repeat group).
			This comes after the other fields of the repeat group because
			the SET-OF field is the last field in the .csv file. It only
			matters for determining duplicate Stata names. */
			_get_fields_base(fields, fpos, survey[|1, . \ 1, .|], attr,
				groups[1], newrepeat, repeatodk, repeatstata)
			newrepeat->set_child_set_of(fields[fpos - 1])
		}

		// Process fields outside the group or repeat group.
		if (endrow < rows) {
			_get_fields(fields, groups, repeats,
				fpos, gpos, rpos, survey[|endrow + 1, . \ ., .|], attr,
				parentgroup, parentrepeat, odknames, stnames)
		}
	}
}

void check_duplicate_group_names(pointer(`GroupS') rowvector groups)
{
	`RS' n, i, j
	`SS' name

	n = length(groups)
	for (i = 1; i <= n - 1; i++) {
		for (j = i + 1; j <= n; j++) {
			if (groups[i]->long_name() == groups[j]->long_name()) {
				// [ID 150], [ID 151]
				name = groups[i]->long_name()
				// Remove the trailing hyphen.
				name = substr(name, 1, strlen(name) - 1)
				errprintf("group name %s used more than once\n", name)
				error_parsing(198, "survey")
				/*NOTREACHED*/
			}
		}
	}
}

void check_duplicate_repeat_names(pointer(`RepeatS') rowvector repeats)
{
	`RS' n, i, j

	n = length(repeats)
	for (i = 1; i <= n - 1; i++) {
		for (j = i + 1; j <= n; j++) {
			if (repeats[i]->name() == repeats[j]->name()) {
				// [ID 119], [ID 120], [ID 149]
				errprintf("repeat group name %s used more than once\n",
					repeats[i]->name())
				error_parsing(198, "survey")
				/*NOTREACHED*/
			}
		}
	}
}

// See the comments for -_get_fields()-.
// -get_fields()- and not -write_survey()- should do all the validation of
// fields, groups, and repeats.
void get_fields(pointer(`FieldS') rowvector fields,
	pointer(`GroupS') rowvector groups, pointer(`RepeatS') rowvector repeats,
	`SM' survey, `AttribSetS' attr)
{
	`RS' n, i
	`RC' begingroup, beginrepeat

	begingroup  = survey[,attr.get("type")->col] :== "begin group"
	beginrepeat = survey[,attr.get("type")->col] :== "begin repeat"

	// Initialize fields.
	n = sum(!begingroup :&
		survey[,attr.get("type")->col] :!= "end group" :&
		survey[,attr.get("type")->col] :!= "end repeat") +
		/* Double-count "begin repeat", since the associated SET-OF variable
		appears in two .csv files. */
		sum(beginrepeat)
	fields = J(1, n, NULL)
	for (i = 1; i <= n; i++) {
		fields[i] = &(`Field'())
	}

	// Initialize groups.
	// "+ 1" since the main fields are also represented as a group.
	n = sum(begingroup) + 1
	groups = J(1, n, NULL)
	for (i = 1; i <= n; i++) {
		groups[i] = &(`Group'())
	}

	// Initialize repeats.
	// "+ 1" since the main fields are also represented as a repeat group.
	n = sum(beginrepeat) + 1
	repeats = J(1, n, NULL)
	for (i = 1; i <= n; i++) {
		repeats[i] = &(`Repeat'())
	}

	// groups[1] is the group representing the main fields.
	// repeats[1] is the repeat group representing the main fields.
	_get_fields(fields, groups, repeats, 1, 2, 2, survey, attr,
		groups[1], repeats[1], J(1, 0, ""), J(1, 0, ""))

	check_duplicate_group_names(groups)
	check_duplicate_repeat_names(repeats)
}

void write_survey_start(`DoFileWriterS' df, `AttribSetS' attr)
{
	`RS' ndiffs, i
	`RR' form
	`RC' diff
	`SR' headers, chars

	form = attr.vals("form")
	headers = select(attr.vals("header"), form)
	chars   = select(attr.vals("char"),   form)

	diff = headers :!= chars
	ndiffs = sum(diff)
	headers = select(headers, diff)
	chars   = select(chars,   diff)
	df.put(sprintf("%s Import ODK attributes as characteristics.",
		(ndiffs <= 3 ? "*" : "/*")))
	for (i = 1; i <= ndiffs; i++) {
		df.put(sprintf("%s- %s will be imported to the characteristic %s%s.%s",
			(ndiffs <= 3 ? "* " : ""), headers[i], `CharPre', chars[i],
			(ndiffs > 3 & i == ndiffs ? " */" : "")))
	}
	df.put("")
}

`RS' insheetable_names(pointer(`FieldS') rowvector fields, `SS' repeatname)
{
	`RS' insheetable, n, i

	insheetable = 1
	n = length(fields)
	for (i = 1; i <= n; i++) {
		if (fields[i]->repeat()->name() == repeatname)
			insheetable = insheetable & fields[i]->insheet() == `InsheetOK'
	}

	return(insheetable)
}

// csv: The name of the .csv file to -insheet-
// insheetable: 1 if all field names in the .csv file can be -insheet-ed (they
// are all `InsheetOK'); 0 otherwise.
void write_insheet(`DoFileWriterS' df, `SS' csv, `RS' insheetable)
{
	// "qcsv" for "quote csv"
	`SS' qcsv

	qcsv = adorn_quotes(csv, "list")

	if (!insheetable) {
		df.put(sprintf("insheet using %s, comma nonames clear", qcsv))
		df.put("local fields")
		df.put("foreach var of varlist _all {")
		df.put("local field = trim(\`var'[1])")
		/* -parse_survey- already completes these checks for fields in the form.
		Adding them to the do-file protects against fields not in the form whose
		names cannot be -insheet-ed. For example, SubmissionDate is not in the
		form, and it would become problematic if the user could add a separate
		field with the same name to the form and this resulted in duplicate .csv
		column names. */
		df.put(`"assert wordcount("\`field'") == 1"')
		df.put("assert !\`:list field in fields'")
		df.put("local fields : list fields | field")
		df.put("}")
		df.put("")
	}

	df.put(sprintf("insheet using %s, comma names case clear", qcsv))
	if (!insheetable)
		df.put("unab all : _all")
	df.put("")
}

void write_char(`DoFileWriterS' df, `SS' var, `SS' char, `SS' text, `SS' suffix,
	`RS' loop)
{
	`RS' autotab, nstrs
	`SS' exp

	if (text != "" | suffix != "") {
		pragma unset nstrs
		exp = specialexp(text, nstrs)
		if (nstrs == 1) {
			// Turning off autotab because text could contain an unenclosed
			// trailing open brace that `DoFileWriter'::put() would mistake as
			// an open block.
			autotab = df.autotab()
			df.set_autotab(0)
			df.put(sprintf("char %s[%s] %s", var, char,
				adorn_quotes(strip_quotes(exp) + suffix, "char", loop)))
			df.set_autotab(autotab)
		}
		else {
			df.put(sprintf(`"mata: st_global("%s[%s]", %s%s)"', var, char,
				exp, (suffix != "") * (" + " + adorn_quotes(suffix))))
		}
	}
}

void write_save_dta(`DoFileWriterS' df, `SS' _csv, `SS' repeat, `RS' anyrepeat,
	_relax)
{
	`SS' dta

	dta = _csv + (repeat != "") * "-" + repeat +
		(strpos(_csv, ".") ? ".dta" : "")
	df.put("local dta `" + `"""' + adorn_quotes(dta) + `"""' + "'")
	df.put(`"save \`dta', replace"' + anyrepeat * " orphans")
	df.put("local dtas : list dtas | dta")

	// Define `allformnotdata'.
	if (_relax)
		df.put(`"local allformnotdata `"\`allformnotdata' "\`formnotdata'""'"')
	df.put("")
}

void write_fields(`DoFileWriterS' df, pointer(`FieldS') rowvector fields,
	`AttribSetS' attr, `SS' _csv, `RS' _relax)
{
	`RS' relax, nfields, nattribs, firstrepeat, insheetmain, ngroups, geopoint,
		other, loop, pctr, i, j
	`RC' p
	`RM' order
	`SS' var, badname, list, space
	`SR' attribchars, suffix
	`InsheetCodeS' insheet
	pointer(`GroupS') rowvector groups

	relax = _relax != 0

	// Write fields according to repeat()->order() .order().
	if (nfields = length(fields)) {
		order = J(nfields, 2, .)
		for (i = 1; i <= nfields; i++) {
			order[i, 1] = fields[i]->repeat()->order()
			order[i, 2] = fields[i]->order()
		}
		p = order(order, (1, 2))
	}

	firstrepeat = 1
	insheetmain = 0
	attribchars = select(attr.vals("char"), !attr.vals("special"))
	nattribs = length(attribchars)
	for (pctr = 1; pctr <= nfields; pctr++) {
		i = p[pctr]

		// begin repeat
		if (fields[i]->begin_repeat()) {
			// Save the main .csv file.
			if (firstrepeat) {
				write_save_dta(df, _csv, "", 1, _relax)
				firstrepeat = 0
			}

			df.put("* begin repeat " + fields[i]->repeat()->name())
			df.put("")
			write_insheet(df, _csv + "-" + fields[i]->repeat()->name() + ".csv",
				insheetable_names(fields, fields[i]->repeat()->name()))

			if (_relax) {
				df.put("local formnotdata")
				df.put("")
			}
		}
		// Start of the main .csv file
		else if (fields[i]->repeat()->main() & !insheetmain) {
			write_insheet(df, _csv + ".csv", insheetable_names(fields, ""))
			insheetmain = 1

			if (_relax) {
				df.put("local formnotdata")
				df.put("")
			}
		}

		// begin group
		groups = fields[i]->begin_groups()
		if (ngroups = length(groups)) {
			for (j = 1; j <= ngroups; j++) {
				df.put("* begin group " + groups[j]->name())
			}
			df.put("")
		}

		// Field start
		df.put("* " + fields[i]->name())

		// Start the variables loop.
		other = regexm(fields[i]->type(), "^select_(one|multiple) .* or_other$")
		geopoint = fields[i]->type() == "geopoint"
		// select or_other variables
		if (other)
			suffix = "", "_other"
		// geopoint variables
		else if (geopoint)
			suffix = "Latitude", "Longitude", "Altitude", "Accuracy"
		else
			suffix = ""
		if (loop = geopoint | other) {
			df.write("foreach suffix in ")
			for (j = 1; j <= length(suffix); j++) {
				df.write(adorn_quotes(suffix[j], "list") + " ")
			}
			df.put("{")
		}

		// Stata name
		insheet = fields[i]->insheet()
		if (insheet == `InsheetOK') {
			if (strlen(fields[i]->st_long()) + max(strlen(suffix)) <= 32)
				var = fields[i]->st_long() + loop * "\`suffix'"
			else {
				df.put(sprintf(`"local varsuf = substr("\`suffix'", 1, %f)"',
					32 - strlen(fields[i]->st_long())))
				var = fields[i]->st_long() + "\`varsuf'"
			}

			badname = "0"
		}
		else {
			if (insheet == `InsheetDup') {
				if (fields[i]->dup_var() == "") {
					df.put("* Duplicate variable name with " +
						fields[i]->other_dup_name())
				}
				else {
					df.put(sprintf("* %s: duplicate variable name with %s.",
						fields[i]->dup_var(), fields[i]->other_dup_name()))
				}
			}
			else if (insheet == `InsheetV')
				df.put("* Variable name is v#.")
			// This could lead to incorrect results if there are duplicate field
			// names. -write_do_start()- checks that this is not the case.
			df.put(sprintf("local pos : list posof %s in fields",
				adorn_quotes(fields[i]->long_name() + geopoint * "-" +
				loop * "\`suffix'")))
			df.put("local var : word \`pos' of \`all'")

			// If insheet == `InsheetV', there's only a chance that the variable
			// name differs from the field name. In a loop, some but not all
			// variables could be problematic.
			if (insheet == `InsheetV' | loop) {
				df.write(`"local isbadname = "\`var'" != "')
				if (strlen(fields[i]->st_long()) < 32 & loop) {
					df.put(sprintf(`"substr("%s", 1, 32)"',
						fields[i]->st_long() + loop * "\`suffix'"))
				}
				else {
					df.put(adorn_quotes(fields[i]->st_long()))
				}
				badname = "\`isbadname'"
			}
			else {
				badname = "1"
			}

			var = "\`var'"
		}

		// Implement -relax-.
		if (relax) {
			df.put(sprintf("capture confirm variable %s, exact", var))
			df.put("if _rc ///")
			df.put("local formnotdata \`formnotdata' " + var)
			df.put("else {")
		}

		// Field name
		write_char(df, var, `CharPre' + attr.get("name")->char,
			fields[i]->name(), "", loop)
		write_char(df, var, `CharPre' + attr.get("bad_name")->char, "",
			badname, loop)

		// Group
		if (fields[i]->group()->inside()) {
			write_char(df, var, `CharPre' + "group",
				fields[i]->group()->st_list(), "", loop)
		}
		write_char(df, var, `CharPre' + "long_name", fields[i]->long_name(),
			"", loop)

		// Repeat
		if (fields[i]->repeat()->inside())
			write_char(df, var, `CharPre' + "repeat",
				fields[i]->repeat()->name(), "", loop)

		// Type
		write_char(df, var, `CharPre' + attr.get("type")->char,
			fields[i]->type(), "", loop)
		if (prematch(fields[i]->type(), "select_one ") |
			prematch(fields[i]->type(), "select_multiple ")) {
			write_char(df, var, `CharPre' + attr.get("type")->char,
				fields[i]->type(), "", loop)
			list = substr(fields[i]->type(),
				strpos(fields[i]->type(), " ") + 1, .)
			if (postmatch(list, " or_other"))
				list = substr(list, 1, strpos(list, " ") - 1)
			write_char(df, var, `CharPre' + "list_name", list,
				"", loop)
		}
		else if (geopoint) {
			write_char(df, var, `CharPre' + "geopoint", "",
				"\`suffix'", loop)
		}
		write_char(df, var, `CharPre' + "or_other", (other ? "1" : "0"),
			"", loop)
		if (other)
			df.put(`"local isother = "\`suffix'" != """')
		write_char(df, var, `CharPre' + "is_other", (other ? "" : "0"),
			other * "\`isother'", loop)

		// Label
		if (fields[i]->label() != "") {
			space = postmatch(fields[i]->label(), " ") ? "" : " "
			if (other) {
				df.put(sprintf("local labend " +
					`""\`=cond("\`suffix'" == "", "", "%s(Other)")'""', space))
			}
			write_char(df, var, `CharPre' + attr.get("label")->char,
				fields[i]->label(),
				loop * (geopoint ? space + "(\`suffix')" : "\`labend'"), loop)
		}

		// Other attributes
		for (j = 1; j <= nattribs; j++) {
			write_char(df, var, `CharPre' + attribchars[j],
				fields[i]->attrib(j), "", loop)
		}

		if (relax)
			df.put("}")

		// End the variables loop.
		if (loop)
			df.put("}")

		df.put("")

		// end group
		groups = fields[i]->end_groups()
		if (ngroups = length(groups)) {
			for (j = 1; j <= ngroups; j++) {
				df.put("* end group " + groups[j]->name())
			}
			df.put("")
		}
		// end repeat
		if (fields[i]->end_repeat()) {
			write_save_dta(df, _csv, fields[i]->repeat()->name(), 1, _relax)
			df.put("* end repeat " + fields[i]->repeat()->name())
			df.put("")
		}
	}
}

void write_dta_loop_start(`DoFileWriterS' df)
{
	df.put("foreach dta of local dtas {")
	df.put(`"use "\`dta'", clear"')
	df.put("")
	df.put("unab all : _all")
	df.put("gettoken first : all")
	df.put(sprintf("local repeat : char \`first'[%srepeat]", `CharPre'))
	df.put("")
}

void write_dta_loop_end(`DoFileWriterS' df)
{
	df.put("save, replace")
	df.put("}")
	df.put("")
}

void write_rename_for_split(`DoFileWriterS' df,
	pointer(`RepeatS') rowvector repeats)
{
	`RS' n, i

	df.put("* Rename any variable names that are difficult for -split-.")
	n = length(repeats)
	if (n == 1)
		df.put("// rename ...")
	else {
		for (i = 1; i <= n; i++) {
			df.put(sprintf(`"if "\`repeat'" == %s%s {"',
				adorn_quotes(repeats[i]->name()),
				repeats[i]->main() * " /* main fields (not a repeat group) */"))
			df.put("// rename ...")
			df.put("}")
		}
	}
	df.put("")
}

void write_split_select_multiple(`DoFileWriterS' df, `AttribSetS' attr)
{
	df.put("* Split select_multiple variables.")
	df.put(sprintf("ds, has(char %s%s)", `CharPre', attr.get("type")->char))
	df.put("foreach typevar in \`r(varlist)' {")
	df.put(sprintf(`"if strmatch("\`:char \`typevar'[%s%s]'", "' +
		`""select_multiple *") & ///"', `CharPre', attr.get("type")->char))
	df.put(sprintf("!\`:char \`typevar'[%sis_other]' {"', `CharPre'))

	df.put("* Add an underscore to the variable name if it ends in a number.")
	df.put("local var \`typevar'")
	df.put(sprintf("local list : char \`var'[%slist_name]", `CharPre'))
	df.put(`"local pos : list posof "\`list'" in labs"')
	df.put("local nparts : word \`pos' of \`nassoc'")
	df.put(sprintf("if \`:list list in otherlabs' & " +
		"!\`:char \`var'[%sor_other]' ///", `CharPre'))
	df.put("local --nparts")
	df.put(`"if inrange(substr("\`var'", -1, 1), "0", "9") & ///"')
	df.put(`"length("\`var'") < 32 - strlen("\`nparts'") {"')
	df.put(`"numlist "1/\`nparts'""')
	df.put(`"local splitvars " \`r(numlist)'""')
	df.put(`"local splitvars : subinstr local splitvars " " " \`var'_", all"')
	df.put("capture confirm new variable \`var'_ \`splitvars'")
	df.put("if !_rc {")
	df.put("rename \`var' \`var'_")
	df.put("local var \`var'_")
	df.put("}")
	df.put("}")
	df.put("")

	df.put("capture confirm numeric variable \`var', exact")
	df.put("if !_rc {")
	df.put("local parts")
	df.put("local next 1")
	df.put("}")
	df.put("else {")
	df.put("split \`var'")
	df.put("local parts \`r(varlist)'")
	df.put("local next = \`r(nvars)' + 1")
	df.put("destring \`parts', replace")
	df.put("}")
	df.put("")

	df.put("forvalues i = \`next'/\`nparts' {")
	df.put("local newvar \`var'\`i'")
	df.put("generate byte \`newvar' = .")
	df.put("local parts : list parts | newvar")
	df.put("}")
	df.put("")

	df.put("local chars : char \`var'[]")
	df.put(sprintf("local label : char \`var'[%s%s]",
		`CharPre', attr.get("label")->char))
	df.put("local len : length local label")
	df.put("local i 0")
	df.put("foreach part of local parts {")
	df.put("local ++i")
	df.put("")
	df.put("foreach char of local chars {")
	df.put(`"mata: st_global("\`part'[\`char']", "' +
		`"st_global("\`var'[\`char']"))"')
	df.put("}")
	df.put("")
	df.put("if \`len' {")
	df.put(sprintf(`"mata: st_global("\`part'[%s%s]", ///"',
		`CharPre', attr.get("label")->char))
	df.put(`"st_local("label") + ///"')
	df.put(`"(substr(st_local("label"), -1, 1) == " " ? "" : " ") + ///"')
	df.put(`""(#\`i'/\`nparts')")"')
	df.put("}")
	df.put("")
	df.put("move \`part' \`var'")
	df.put("}")
	df.put("")

	df.put("drop \`var'")
	df.put("}")
	df.put("}")
	df.put("")
}

void write_drop_note_vars(`DoFileWriterS' df, `AttribSetS' attr)
{
	df.put("* Drop note variables.")
	df.put(sprintf("ds, has(char %s%s)", `CharPre', attr.get("type")->char))
	df.put("foreach var in \`r(varlist)' {")
	df.put(sprintf(`"if "\`:char \`var'[%s%s]'" == "note" ///"',
		`CharPre', attr.get("type")->char))
	df.put("drop \`var'")
	df.put("}")
	df.put("")
}

void write_dates_times(`DoFileWriterS' df, `AttribSetS' attr)
{
	df.put("* Date and time variables")
	df.put("capture confirm variable SubmissionDate, exact")
	df.put("if !_rc {")
	df.put(sprintf("local type : char SubmissionDate[%s%s]",
		`CharPre', attr.get("type")->char))
	df.put("assert !\`:length local type'")
	df.put(sprintf("char SubmissionDate[%s%s] datetime",
		`CharPre', attr.get("type")->char))
	df.put("}")
	df.put("local datetime date today time datetime start end")
	df.put("tempvar temp")
	df.put(sprintf("ds, has(char %s%s)", `CharPre', attr.get("type")->char))
	df.put("foreach var in \`r(varlist)' {")
	df.put(sprintf("local type : char \`var'[%s%s]",
		`CharPre', attr.get("type")->char))
	df.put("if \`:list type in datetime' {")
	df.put("capture confirm numeric variable \`var'")
	df.put("if !_rc {")
	df.put("tostring \`var', replace")
	df.put(`"replace \`var' = "" if \`var' == ".""')
	df.put("}")
	df.put("")

	// date fields
	df.put(`"if inlist("\`type'", "date", "today") {"')
	df.put("local fcn    date")
	df.put("local mask   " + `DateMask')
	df.put("local format %tdMon_dd,_CCYY")
	df.put("}")
	// time fields
	df.put(`"else if "\`type'" == "time" {"')
	df.put("local fcn    clock")
	df.put("local mask   " + `TimeMask')
	df.put("local format %tchh:MM:SS_AM")
	df.put("}")
	// datetime fields
	df.put(`"else if inlist("\`type'", "datetime", "start", "end") {"')
	df.put("local fcn    clock")
	df.put("local mask   " + `DatetimeMask')
	df.put("local format %tcMon_dd,_CCYY_hh:MM:SS_AM")
	df.put("}")
	// -generate-
	df.put(`"generate double \`temp' = \`fcn'(\`var', "\`\`mask''")"')
	df.put("format \`temp' \`format'")
	df.put("count if missing(\`temp') & !missing(\`var')")
	df.put("if r(N) {")
	df.put(`"display as err "{p}""')
	df.put(`"display as err "\`type' variable \`var'""')
	df.put(`"if "\`repeat'" != "" ///"')
	df.put(`"display as err "in repeat group \`repeat'""')
	df.put("display as err " +
		`""could not be converted using the mask \`\`mask''""')
	df.put(`"display as err "{p_end}""')
	df.put("exit 9")
	df.put("}")
	df.put("")

	df.put("move \`temp' \`var'")
	df.put("foreach char in \`:char \`var'[]' {")
	df.put(`"mata: st_global("\`temp'[\`char']", "' +
		`"st_global("\`var'[\`char']"))"')
	df.put("}")
	df.put("drop \`var'")
	df.put("rename \`temp' \`var'")
	df.put("}")
	df.put("}")
	df.put("capture confirm variable SubmissionDate, exact")
	df.put("if !_rc ///")
	df.put(sprintf("char SubmissionDate[%s%s]",
		`CharPre', attr.get("type")->char))
	df.put("")
}

void write_field_labels(`DoFileWriterS' df, `AttribSetS' attr)
{
	`SS' notepre

	notepre = "Question text: "

	df.put("* Attach field labels as variable labels and notes.")
	df.put(sprintf("ds, has(char %slong_name)", `CharPre'))
	df.put("foreach var in \`r(varlist)' {")
	df.put("* Variable label")
	df.put(sprintf("local label : char \`var'[%s%s]",
		`CharPre', attr.get("label")->char))
	df.put(`"mata: st_varlabel("\`var'", st_local("label"))"')
	df.put("")

	df.put("* Notes")
	df.put("if \`:length local label' {")
	df.put("char \`var'[note0] 1")
	df.put(sprintf(`"mata: st_global("\`var'[note1]", %s + ///"',
		adorn_quotes(notepre)))
	df.put(sprintf(`"st_global("\`var'[%s%s]"))"',
		`CharPre', attr.get("label")->char))
	df.put(`"mata: st_local("temp", ///"')
	df.put(`"" " * (strlen(st_global("\`var'[note1]")) + 1))"')
	df.put("#delimit ;")
	df.put("local fromto")
	df.indent()
	df.put(sprintf(`"{%s"\`temp'""', tab(3)))
	df.put(sprintf(`"}%s"{c )-}""', tab(3)))
	df.put(sprintf(`""\`temp'"%s"{c -(}""', tab()))
	df.put(sprintf(`"'%s"{c 39}""', tab(3)))
	df.put(sprintf(`"""' + "`" + `""%s"{c 'g}""', tab(3)))
	df.put(sprintf(`""$"%s"{c S|}""', tab(3)))
	df.indent(-1)
	df.put(";")
	df.put("#delimit cr")
	df.put("while \`:list sizeof fromto' {")
	df.put("gettoken from fromto : fromto")
	df.put("gettoken to   fromto : fromto")
	df.put(`"mata: st_global("\`var'[note1]", ///"')
	df.put(`"subinstr(st_global("\`var'[note1]"), "\`from'", "\`to'", .))"')
	df.put("}")
	df.put("}")
	df.put("}")
	df.put("")
}

void write_attach_vallabs(`DoFileWriterS' df, `AttribSetS' attr)
{
	df.put("* Attach value labels.")
	df.put("ds, not(vallab)")
	df.put(`"if "\`r(varlist)'" != "" ///"')
	df.put(sprintf("ds \`r(varlist)', has(char %slist_name)", `CharPre'))
	df.put("foreach var in \`r(varlist)' {")
	df.put(sprintf("if !\`:char \`var'[%sis_other]' {", `CharPre'))
	df.put("capture confirm string variable \`var', exact")
	df.put("if !_rc {")
	df.put(`"replace \`var' = ".o" if \`var' == "other""')
	df.put("destring \`var', replace")
	// Necessary for variable labels that contain difficult characters
	df.put(sprintf(`"mata: st_varlabel("\`var'", st_global("\`var'[%s%s]"))"',
		`CharPre', attr.get("label")->char))
	df.put("}")
	df.put(sprintf("local list : char \`var'[%slist_name]", `CharPre'))
	df.put("if !\`:list list in labs' {")
	df.put(`"display as err "list \`list' not found in choices sheet""')
	df.put("exit 9")
	df.put("}")
	df.put("label values \`var' \`list'")
	df.put("}")
	df.put("}")
	df.put("")
}

void write_recode_or_other(`DoFileWriterS' df)
{
	df.put("* select or_other variables")
	df.put("forvalues i = 1/\`:list sizeof otherlabs' {")
	df.put("local lab      : word \`i' of \`otherlabs'")
	df.put("local otherval : word \`i' of \`othervals'")
	df.put("")
	df.put("ds, has(vallab \`lab')")
	df.put(`"if "\`r(varlist)'" != "" ///"')
	df.put("recode \`r(varlist)' (.o=\`otherval')")
	df.put("}")
	df.put("")
}

void write_compress(`DoFileWriterS' df)
{
	df.put("compress")
	df.put("")
}

void write_repeat_locals(`DoFileWriterS' df, `AttribSetS' attr, `SS' repeat,
	`RS' anyrepeat)
{
	// Define `repeats'.
	df.put("local repeats " +
		adorn_quotes("\`repeats' " + adorn_quotes(repeat), "list"))
	// Define `childfiles.
	if (anyrepeat) {
		df.put("tempfile child")
		df.put("local childfiles : list childfiles | child")
	}

	// Define `allbadnames'.
	df.put("local badnames")
	df.put(sprintf("ds, has(char %sbad_name)", `CharPre'))
	df.put("foreach var in \`r(varlist)' {")
	df.put(sprintf(`"if \`:char \`var'[%sbad_name]' & ///"', `CharPre'))
	df.put(sprintf(`"("\`:char \`var'[%s%s]'" != "begin repeat" | ///"',
		`CharPre', attr.get("type")->char))
	df.put(`"("\`repeat'" != "" & ///"')
	df.put(sprintf(`""\`:char \`var'[%s%s]'" == "SET-OF-\`repeat'")) {"',
		`CharPre', attr.get("name")->char))
	df.put("local badnames : list badnames | var")
	df.put("}")
	df.put("}")
	df.put(`"local allbadnames `"\`allbadnames' "\`badnames'""'"')
	df.put("")

	// Define `alldatanotform'.
	df.put(sprintf("ds, not(char %slong_name)", `CharPre'))
	df.put("local datanotform \`r(varlist)'")
	df.put("local exclude SubmissionDate KEY PARENT_KEY metainstanceID")
	df.put("local datanotform : list datanotform - exclude")
	df.put(`"local alldatanotform `"\`alldatanotform' "\`datanotform'""'"')
	df.put("")
}

// Implement -dropattrib()- and -keepattrib()-.
void write_drop_attrib(`DoFileWriterS' df, `AttribSetS' attr)
{
	`RS' n, i
	`SR' drop

	drop = select(attr.vals("char"), !attr.vals("keep"))
	if (n = length(drop)) {
		drop = sort(drop', 1)'
		df.put("foreach var of varlist _all {")
		if (n <= 3) {
			for (i = 1; i <= n; i++) {
				df.put(sprintf("char \`var'[%s%s]", `CharPre', drop[i]))
			}
		}
		else {
			df.write("foreach char in ")
			for (i = 1; i <= n; i++) {
				df.write(drop[i] + " ")
			}
			df.put("{")
			df.put(sprintf("char \`var'[%s\`char']", `CharPre'))
			df.put("}")
		}
		df.put("}")
		df.put("")
	}
}

void write_search_set_of(`DoFileWriterS' df, `AttribSetS' attr, `SS' repeat)
{
	df.put("local setof")
	df.put("foreach var of varlist _all {")
	df.put(sprintf(`"if "\`:char \`var'[%s%s]'" == "SET-OF-%s" {"',
		`CharPre', attr.get("name")->char, repeat))
	df.put("local setof \`var'")
	df.put("continue, break")
	df.put("}")
	df.put("}")
	df.put(`"assert "\`setof'" != """')
	df.put("")
}

void write_merge_repeat(`DoFileWriterS' df, pointer(`RepeatS') scalar repeat,
	`AttribSetS' attr, `RS' dropattrib)
{
	`RS' nchildren, multiple, i
	`SS' loopname, setof

	// Start a loop if there are multiple children.
	nchildren = length(repeat->children())
	multiple = nchildren > 1
	if (!multiple)
		loopname = repeat->child(1)->name()
	else {
		df.put("tempvar merge")
		df.write("foreach repeat in ")
		for (i = 1; i <= nchildren; i++) {
			df.write(sprintf("%s ", repeat->child(i)->name()))
		}
		df.put("{")
		loopname = "\`repeat'"
	}

	// Define setof, searching for the SET-OF variable if necessary.
	if (!multiple &
		repeat->child(1)->parent_set_of()->insheet() == `InsheetOK' &
		repeat->child(1)->child_set_of()->insheet()  == `InsheetOK') {
		setof = repeat->child(1)->parent_set_of()->st_long()
	}
	else {
		write_search_set_of(df, attr, loopname)
		setof = "\`setof'"
	}

	// Prepare merge.

	// Variable order
	df.put("unab before : _all")
	// Check that there is no unexpected variable list overlap.
	df.put(sprintf(`"local pos : list posof "%s" in repeats"', loopname))
	df.put("local child : word \`pos' of \`childfiles'")
	df.put("describe using \`child', varlist")
	df.put("local childvars \`r(varlist)'")
	df.put("local overlap : list before & childvars")
	df.put("local KEY KEY")
	df.put("local overlap : list overlap - KEY")
	df.put("quietly if \`:list sizeof overlap' {")
	df.put("gettoken first : overlap")
	df.put(sprintf("noisily display as err " +
		`""error merging %s and repeat group %s""',
		(repeat->main() ? "the main fields" : "repeat group " + repeat->name()),
		loopname))
	df.put("noisily display as err " +
		`""variable \`first' exists in both datasets""')
	df.put("noisily display as err " +
		`""rename it in one or both, then try again""')
	df.put("exit 9")
	df.put("}")
	df.put("")

	// Sort order
	df.put("tempvar order")
	df.put("generate \`order' = _n")

	// Merge.
	df.put("if !_N ///")
	df.put("tostring KEY, replace")
	if (!multiple)
		df.put("tempvar merge")
	df.put("merge KEY using \`child', sort _merge(\`merge')")
	df.put("tabulate \`merge'")
	df.put("assert \`merge' != 2")

	// Clean up.
	// Sort order
	// This sort may be unnecessary: -merge- may complete it automatically.
	// However, this is not ensured in the documentation, and the -reshape-
	// requires it. (Otherwise, _j could be incorrect.)
	df.put("sort \`order'")
	df.put("drop \`order' \`merge'")
	df.put("")
	// Variable order
	df.put("unab after : _all")
	df.put("local new : list after - before")
	df.put("foreach var of local new {")
	df.put("move \`var' " + setof)
	df.put("}")
	df.put("drop " + setof)

	// End the children loop.
	if (multiple)
		df.put("}")
	df.put("")

	if (dropattrib)
		write_drop_attrib(df, attr)

	write_compress(df)

	df.put("save, replace")
	df.put("")
}

void write_reshape_repeat(`DoFileWriterS' df, pointer(`RepeatS') scalar repeat,
	`AttribSetS' attr)
{
	`SS' mergekey

	// Drop KEY and the SET-OF variable, which will be unused.
	if (repeat->child_set_of()->insheet() == `InsheetOK')
		df.put("drop KEY " + repeat->child_set_of()->st_long())
	else {
		df.put("drop KEY")
		df.put("foreach var of local before {")
		df.put(sprintf(`"if "\`:char \`var'[%s%s]'" == "SET-OF-%s" {"',
			`CharPre', attr.get("name")->char, repeat->name()))
		df.put("drop \`var'")
		df.put("continue, break")
		df.put("}")
		df.put("}")
	}
	df.put("")

	mergekey = "PARENT_KEY"

	// Rename variables that end in a number.
	df.put("* Add an underscore to variable names that end in a number.")
	df.put(sprintf("ds %s, not", mergekey))
	df.put("foreach var in \`r(varlist)' {")
	df.put(sprintf(`"if inrange(substr("\`var'", -1, 1), "0", "9") & "' +
		`"length("\`var'") < %f {"',
		32 - repeat->level()))
	df.put("capture confirm new variable \`var'_")
	df.put("if !_rc ///")
	df.put("rename \`var' \`var'_")
	df.put("}")
	df.put("}")
	df.put("")

	// Positive number of observations
	df.put("if _N {")

	// Reshape.
	df.put("tempvar j")
	df.put(sprintf("sort %s, stable", mergekey))
	df.put(sprintf("by %s: generate \`j' = _n", mergekey))
	df.put(sprintf("ds %s \`j', not", mergekey))
	df.put(sprintf("reshape wide \`r(varlist)', i(%s) j(\`j')", mergekey))
	df.put("")

	// Restore variable labels.
	df.put("* Restore variable labels.")
	df.put("foreach var of varlist _all {")
	df.put(sprintf(`"mata: st_varlabel("\`var'", st_global("\`var'[%s%s]"))"',
		`CharPre', attr.get("label")->char))
	df.put("}")

	// Zero observations
	df.put("}")
	df.put("else {")
	df.put(sprintf("ds %s, not", mergekey))
	df.put("foreach var in \`r(varlist)' {")
	df.put("ren \`var' \`var'1")
	df.put("}")
	df.put("drop " + mergekey)
	df.put(sprintf(`"gen %s = """', mergekey))
	df.put("}")
	df.put("")

	df.put("rename PARENT_KEY KEY")
	df.put("")

	// Save.
	df.put(sprintf(`"local pos : list posof "%s" in repeats"', repeat->name()))
	df.put("local child : word \`pos' of \`childfiles'")
	df.put("save \`child'")
	df.put("")
}

void write_merge_repeats(`DoFileWriterS' df,
	pointer(`RepeatS') rowvector repeats, `AttribSetS' attr, `SS' _csv)
{
	`RS' nrepeats, pctr, i
	`RC' order, p
	// "dtaq" for ".dta (with) quotes"
	`SS' repeatcsv, dtaq

	// Write repeats according to .order().
	if (nrepeats = length(repeats)) {
		df.put("* Merge repeat groups.")
		df.put("")

		order = J(nrepeats, 1, .)
		for (i = 1; i <= nrepeats; i++) {
			order[i] = repeats[i]->order()
		}
		p = order(-order, 1)
	}

	for (pctr = 1; pctr <= nrepeats; pctr++) {
		i = p[pctr]

		df.put("* " + (repeats[i]->name() != "" ? repeats[i]->name() :
			"Main fields (not a repeat group)"))
		df.put("")

		repeatcsv = _csv + repeats[i]->inside() * "-" + repeats[i]->name()
		dtaq = adorn_quotes(repeatcsv + (strpos(repeatcsv, ".") ? ".dta" : ""),
			"list")
		df.put(sprintf("use %s, clear", dtaq))
		df.put("")

		if (repeats[i]->inside()) {
			df.put("* Rename any variable names that " +
				"are difficult for -merge- or -reshape-.")
			df.put("// rename ...")
			df.put("")
		}

		if (length(repeats[i]->children()))
			write_merge_repeat(df, repeats[i], attr, repeats[i]->main())
		if (repeats[i]->inside()) {
			write_reshape_repeat(df, repeats[i], attr)

			if (any(!attr.vals("keep"))) {
				df.put(sprintf("use %s, clear", dtaq))
				df.put("")
				write_drop_attrib(df, attr)
				df.put("save, replace")
				df.put("")
			}
		}
	}
}

					/* -survey()-			*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* -choices()-			*/

void write_choices(
	/* output do-files */ `SS' _vallabdo, `SS' _encodedo,
	`SS' _choices,
	/* column headers */ `SS' _listname, `SS' _name, `SS' _label,
	/* other values */ `SS' _otherlists, `SS' _other,
	`RS' _oneline)
{
	`RS' listname, name, label, rows, nvals, nstrs, i, j
	`RR' col
	`SS' strlists
	`SR' listnames, otherlists
	`SM' choices
	`DoFileWriterS' df
	`ListS' list
	`ListR' lists

	choices = read_csv(_choices)
	if (rows(choices) < 2)
		return

	col = 1..cols(choices)
	listname = min(select(col, choices[1,] :== _listname))
	name     = min(select(col, choices[1,] :== _name))
	label    = min(select(col, choices[1,] :== _label))
	choices = choices[,(listname, name, label)]
	listname = 1
	name     = 2
	label    = 3
	choices = choices[|2, . \ ., .|]
	choices[,(listname, name)] = strtrim(choices[,(listname, name)])

	df.open(_vallabdo)
	df.put("label drop _all")
	df.put("")

	if (rows = rows(choices)) {
		lists = `List'(0)
		strlists = ""
		listnames = J(1, 0, "")
		for (i = 1; i <= rows; i++) {
			if (!anyof(listnames, choices[i, listname])) {
				list.listname = choices[i, listname]
				listnames = listnames, list.listname
				list.names  = select(choices[,name],
					choices[,listname] :== list.listname)
				list.labels = select(choices[,label],
					choices[,listname] :== list.listname)
				list.vallab = !hasmissing(strtoreal(list.names)) &
					strtoreal(list.names) == floor(strtoreal(list.names)) &
					/* distinct names can be converted to the same number, e.g.,
					1 and 01 */
					length(uniqrows(list.names)) ==
					length(uniqrows(strtoreal(list.names)))
				if (!list.vallab)
					strlists = strlists + (strlists != "") * " " + list.listname

				list.matalab = 0
				nvals = length(list.names)
				for (j = 1; j <= nvals; j++) {
					if (!list.vallab)
						list.names[j] = specialexp(list.names[j])
					pragma unset nstrs
					list.labels[j] = specialexp(list.labels[j], nstrs)
					if (nstrs > 1)
						list.matalab = 1
				}

				lists = lists, list
			}
		}

		write_lists(df, lists, _oneline)
		write_sysmiss_labs(df, lists)

		otherlists = tokens(_otherlists)
		if (length(otherlists))
			write_other_labs(df, otherlists, _other)

		write_save_label_info(df)
	}

	df.close()

	df.open(_encodedo)

	if (strlists != "") {
		write_encode_start(df, strlists)
		write_lists(df, lists, _oneline, "encode")
		write_encode_end(df)
	}

	df.close()
}

// See <http://www.stata.com/statalist/archive/2013-04/msg00684.html> and
// <http://www.stata.com/statalist/archive/2006-05/msg00276.html>.
transmorphic cp(transmorphic original)
{
	transmorphic copy

	copy = original
	return(copy)
}

void write_lists(`DoFileWriterS' df, `ListR' lists, `RS' oneline, |`SS' action)
{
	// "nassoc" for "number of associations"
	`RS' labdef, nlists, mindelim, maxdelim, delim, nassoc, maxspaces, i, j
	`RC' diff
	`ListS' list
	// "ls" for "lists"
	`ListR' ls

	ls = `List'(0)
	labdef = action != "encode"
	nlists = length(lists)
	for (i = 1; i <= nlists; i++) {
		list = cp(lists[i])
		// Defining the label
		if (labdef) {
			if (!list.vallab)
				list.names = strofreal(1::rows(list.names), `RealFormat')
			if (!list.matalab) {
				list.labels =
					adorn_quotes(strip_quotes(list.labels), "label")
			}
			ls = ls, list
		}
		// Encoding
		else if (!list.vallab) {
			// Exclude name-label associations if the name equals the label.
			diff = list.names :!= list.labels
			if (any(diff)) {
				list.names  = select(list.names,  diff)
				list.labels = select(list.labels, diff)
				ls = ls, list
			}
		}
	}

	// mindelim is the index of the list before which -#delimit ;- is required.
	// maxdelim is the index of the list after which -#delimit cr- is required.
	mindelim = maxdelim = 0
	nlists = length(ls)
	if (labdef & !oneline) {
		/* Make mindelim the index of the first list that does not require Mata.
		Make maxdelim the index of the last list that does not require Mata.
		The definitions will appear as follows:

		Lists that require Mata
		#delimit ;
		List that does not require Mata
		Lists
		List that does not require Mata
		#delimit cr
		Lists that require Mata

		All the above elements are optional. If there are no lists that do not
		require Mata, the -#delimit- commands are skipped.
		*/
		for (i = 1; i <= nlists; i++) {
			if (!ls[i].matalab) {
				mindelim = mindelim ? mindelim : i
				maxdelim = i
			}
		}
	}

	for (i = 1; i <= nlists; i++) {
		if (i == mindelim)
			df.put("#delimit ;")

		delim = i >= mindelim & i <= maxdelim
		if (!(labdef & oneline)) {
			df.put(sprintf("* %s%s", ls[i].listname, delim * ";"))
		}

		// Start of the label
		if (!labdef) {
			df.put(sprintf(`"%sif "\`list'" == "%s" {"',
				(i > 1) * "else ", ls[i].listname))
		}
		else if (!ls[i].matalab) {
			df.write("label define " + ls[i].listname)
			if (!oneline) {
				df.put("")
				df.indent()
			}
		}

		// Middle of the label
		nassoc = length(ls[i].labels)
		if (!labdef)
			maxspaces = max(strlen(ls[i].labels))
		else if (!ls[i].matalab)
			maxspaces = max(strlen(ls[i].names))
		for (j = 1; j <= nassoc; j++) {
			// -replace-
			if (!labdef) {
				df.put(sprintf("replace \`temp' = %s%s if \`var' == %s",
					ls[i].labels[j],
					" " * (maxspaces - strlen(ls[i].labels[j])),
					ls[i].names[j]))
			}
			// -label define-
			else if (!ls[i].matalab) {
				if (oneline)
					df.write(sprintf(" %s %s", ls[i].names[j], ls[i].labels[j]))
				else {
					df.put(ls[i].names[j] +
						" " * (maxspaces - strlen(ls[i].names[j]) + 1) +
						ls[i].labels[j])
				}
			}
			// -st_vlmodify()-
			else {
				df.write(sprintf(`"mata: st_vlmodify("%s", %s, %s)"',
					ls[i].listname, ls[i].names[j], ls[i].labels[j]))
				if (delim)
					df.write(";")
				df.put("")
			}
		}

		// End of the label
		if (!labdef)
			df.put("}")
		else if (!ls[i].matalab) {
			if (delim) {
				df.indent(-1)
				df.write(";")
			}
			df.put("")
		}

		if (i == maxdelim)
			df.put("#delimit cr")
	}

	if (nlists)
		df.put("")
}

void write_sysmiss_labs(`DoFileWriterS' df, `ListR' lists)
{
	`RS' nlists, nsysmiss, i
	`SR' listnames

	listnames = J(1, 0, "")
	nlists = length(lists)
	for (i = 1; i <= nlists; i++) {
		if (any(lists[i].names :== adorn_quotes(".")))
			listnames = listnames, lists[i].listname
	}

	if (nsysmiss = length(listnames)) {
		printf("{p}{txt}note: list%s {res:%s} contain%s a name equal to " +
			`"{res:"."}. Because of the do-file's use of {cmd:insheet}, "' +
			`"it may not be possible to distinguish {res:"."} from "' +
			"{res:sysmiss}. When it is unclear, the do-file will assume that " +
			`"values equal the name {res:"."} and not {res:sysmiss}. "' +
			"See the help file for more information.{p_end}\n",
			(nsysmiss > 1) * "s", invtokens(listnames), (nsysmiss == 1) * "s")

		df.put(`"* Lists with a name equal to ".""')
		df.put("local sysmisslabs " + invtokens(listnames))
		df.put("")
	}
}

void write_other_labs(`DoFileWriterS' df, `SR' otherlists, `SS' other)
{
	`SS' otherval

	if (length(otherlists)) {
		df.put(`"* Add "other" values to value labels that need them."')
		df.put("local otherlabs " + invtokens(otherlists))
		df.put("foreach lab of local otherlabs {")
		df.put(`"mata: st_vlload("\`lab'", \`values' = ., \`text' = "")"')
		if (other == "min" | other == "max") {
			df.put(sprintf(`"mata: st_local("otherval", "' +
				`"strofreal(%s, "%s"))"',
				(other == "max" ? "max(\`values') + 1" : "min(\`values') - 1"),
				`RealFormat'))
			otherval = "\`otherval'"
		}
		else
			otherval = other
		df.put("local othervals \`othervals' " + otherval)
		df.put(sprintf("label define \`lab' %s other, add", otherval))
		df.put("}")
		df.put("")
	}
}

void write_save_label_info(`DoFileWriterS' df)
{
	df.put("* Save label information.")
	df.put("label dir")
	df.put("local labs \`r(names)'")
	df.put("foreach lab of local labs {")
	df.put("quietly label list \`lab'")
	df.put(`"* "nassoc" for "number of associations""')
	df.put("local nassoc \`nassoc' \`r(k)'")
	df.put("}")
	df.put("")
}

void write_encode_start(`DoFileWriterS' df, `SS' strlists)
{
	df.put("* Encode fields whose list contains a noninteger name.")
	df.put("local lists " + strlists)
	df.put("tempvar temp")
	df.put(sprintf("ds, has(char %slist_name)", `CharPre'))
	df.put("foreach var in \`r(varlist)' {")
	df.put(sprintf("local list : char \`var'[%slist_name]", `CharPre'))
	df.put("if \`:list list in lists' & !\`:char \`var'[Odk_is_other]' {")
	df.put("capture confirm numeric variable \`var'")
	df.put("if !_rc {")
	df.put(sprintf("tostring \`var', replace format(%s)", `RealFormat'))
	df.put("if !\`:list list in sysmisslabs' ///")
	df.put(`"replace \`var' = "" if \`var' == ".""')
	df.put("}")
	df.put("generate \`temp' = \`var'")
	df.put("")
}

void write_encode_end(`DoFileWriterS' df)
{
	df.put("replace \`var' = \`temp'")
	df.put("drop \`temp'")
	df.put("encode \`var', gen(\`temp') label(\`list') noextend")
	df.put("move \`temp' \`var'")
	df.put("foreach char in \`:char \`var'[]' {")
	df.put(`"mata: st_global("\`temp'[\`char']", "' +
		`"st_global("\`var'[\`char']"))"')
	df.put("}")
	df.put("drop \`var'")
	df.put("rename \`temp' \`var'")
	df.put("}")
	df.put("}")
	df.put("")
}

					/* -choices()-			*/
/* -------------------------------------------------------------------------- */

end
exit

ODK notes
---------

From SurveyCTO: "[Field] names must begin with a letter, colon, or underscore.
Subsequent characters can include numbers, dashes, and periods."

List names are much less restrictive: they may include even spaces or single or
double quotes. List names are case-sensitive. -odkmeta- requires that list names
are Stata names.

Useful sources, including for terminology:

http://opendatakit.org/help/form-design/guidelines/
http://opendatakit.org/help/form-design/examples/
http://opendatakit.org/help/form-design/xlsform/
