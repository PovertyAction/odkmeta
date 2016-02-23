foreach dta of local dtas {
	use "`dta'", clear

	unab all : _all
	gettoken first : all
	local repeat : char `first'[<%= char_name("repeat") %>]

