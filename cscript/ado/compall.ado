pr compall
	vers 9

	args dir1 dir2

	if `:length loc 3' ///
		err 198

	if !`:length loc dir1' {
		di as err "dirname1 required"
		ex 198
	}

	if "`dir2'" == "" {
		loc dir2 "`dir1'"
		loc dir1 .
	}

	forv i = 1/2 {
		loc dtas`i' : dir "`dir`i''" file "*.dta"
	}

	* Check that the lists of .dta files are the same.
	loc 1not2 : list dtas1 - dtas2
	if `:list sizeof 1not2' {
		di as err "in `dir1' but not `dir2':"
		macro li _1not2
		ex 198
	}
	loc 2not1 : list dtas2 - dtas1
	if `:list sizeof 2not1' {
		di as err "in `dir2' but not `dir1':"
		macro li _2not1
		ex 198
	}

	foreach dta of loc dtas1 {
		di as txt "Comparing {res:`dta'}..."
		compdta "`dir1'/`dta'" "`dir2'/`dta'"
	}
end
