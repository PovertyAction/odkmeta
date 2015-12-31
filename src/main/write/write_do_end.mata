vers 11.2

matamac

findfile DoFileWriter.mata
include `"`r(fn)'"'

mata:

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

end
