	tempfile startdo enddo chardo cleando1 cleando2 vallabdo encodedo ///
		encodetab fulldo

	* Do-file start and end
	mata: write_do_start("`startdo'", st_local("0"))
	mata: write_do_end("`enddo'", "`relax'" != "")

	* -survey()-
	#d ;
	mata: write_survey(
		/* output do-files */ "`chardo'", "`cleando1'", "`cleando2'",
		/* output locals */ "anyrepeat", "otherlists", "listnamechar",
			"isotherchar",
		`"`sfn'"', st_local("csv"),
		/* column headers */ st_local("type"), st_local("sname"),
			st_local("slabel"), st_local("disabled"),
		st_local("dropattrib"), st_local("keepattrib"), "`relax'" != "")
	;
	#d cr

	* -choices()-
	#d ;
	mata: write_choices(
		/* output do-files */ "`vallabdo'", "`encodedo'",
		`"`cfn'"',
		/* column headers */ st_local("listname"), st_local("cname"),
			st_local("clabel"),
		/* characteristic names */ "`listnamechar'", "`isotherchar'",
		/* other values */ "`otherlists'", "`other'",
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
