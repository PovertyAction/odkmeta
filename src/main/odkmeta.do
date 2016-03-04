pr odkmeta
	vers 11.2

	cap mata: mata which specialexp()
	if _rc {
		* [ID 185]
		di as err "SSC package specialexp required"
		di as err "to install, type {cmd:ssc install specialexp}"
		di as err "{p}after installation, you may need to " ///
			"{help mata mlib:index Mata} or restart Stata{p_end}"
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
		/*NOTREACHED*/
	}

	preserve

	#d ;
	mata: odkmeta(
		// Main
		"using",
		"csv",
		"survey",
		"choices",
		// Fields
		"dropattrib",
		"keepattrib",
		"relax",
		// Lists
		"other",
		"oneline",
		// Non-option values
		"0"
	);
	#d cr
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

/* -parse_survey- completes checking that involves single rows of the survey
sheet; the rest is done in `FormFields'. Unlike `FormFields',
-parse_survey- displays the problematic row, and in general, where possible
it is better to implement a check in -parse_survey- rather than
`FormFields'. However, all complex checks that involve Mata are best put
in `FormFields'. */
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
	* [ID 65]
	check_col `typevar' if `select' & wordcount(`stdtype') != ///
		2 + (word(`stdtype', wordcount(`stdtype')) == "or_other"), ///
		`opt' sub(type) `listvars'

	* Check that the list names specified to select variables are Stata names.
	* [ID 66], [ID 67], [ID 68]
	check_col `typevar' if `select' & ///
		(word(`stdtype', 2) != strtoname(word(`stdtype', 2)) | ///
		strpos(word(`stdtype', 2), "`")), ///
		`opt' sub(type) `listvars'

	* Check the word count of `namevar'.
	* [ID 200]
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

	* [ID 61], [ID 62], [ID 63], [ID 64]
	check_col `listnamevar' ///
		if (strtrim(`listnamevar') != strtoname(strtrim(`listnamevar')) | ///
		strpos(`listnamevar', "`")) & `nonmiss', ///
		`opt' sub(listname) `listvars'

	* [ID 201]
	check_col `namevar' if mi(strtrim(`namevar')) & `nonmiss', ///
		`opt' sub(name) `listvars'

	* [ID 202]
	check_col `labelvar' if mi(`labelvar') & `nonmiss', ///
		`opt' sub(label) `listvars'

	sret loc fn			"`fn'"
	sret loc listname	"`listname'"
	sret loc name		"`name'"
	sret loc label		"`label'"
end

					/* parse user input		*/
/* -------------------------------------------------------------------------- */
