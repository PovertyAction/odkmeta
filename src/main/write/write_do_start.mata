vers 11.2

findfile DoFileWriter.mata
include `"`r(fn)'"'

mata:

void write_do_start(`SS' _outfile, `SS' _0)
{
	`DoFileWriterS' df

	df.open(_outfile)

	// Notes at the top of the do-file
	df.put(sprintf("* Created on %s at %s by the following -odkmeta- command:",
		strofreal(date(c("current_date"), "DMY"), "%tdMonth_dd,_CCYY"),
		c("current_time")))
	df.put("* odkmeta " + _0)
	df.put("* -odkmeta- version 1.1.0 was used.")
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

void write_temp_mata(`DoFileWriterS' df)
{
	df.put("* Find unused Mata names.")
	df.put("foreach var in values text {")
	df.put(`"mata: st_local("external", invtokens(direxternal("*")'))"')
	df.put("tempname \`var'")
	df.put("while \`:list \`var' in external' {")
	df.put("tempname \`var'")
	df.put("}")
	df.put("}")
	df.put("")
}

end
