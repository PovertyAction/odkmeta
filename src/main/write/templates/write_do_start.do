<% // Notes at the top of the do-file %>
* Created on <%= current_date() %> at <%= c("current_time") %> by the following -odkmeta- command:
* odkmeta <%= command_line %>
* -odkmeta- version 1.1.0 was used.

<% // -version- %>
version 9

<% // User parameters not covered by an option %>
* Change these values as required by your data.

* The mask of date values in the .csv files. See -help date()-.
* Fields of type date or today have these values.
local <%= `DateMask' %> MDY
* The mask of time values in the .csv files. See -help clock()-.
* Fields of type time have these values.
local <%= `TimeMask' %> hms
* The mask of datetime values in the .csv files. See -help clock()-.
* Fields of type datetime, start, or end have these values.
local <%= `DatetimeMask' %> MDYhms


/* -------------------------------------------------------------------------- */

* Start the import.
* Be cautious about modifying what follows.

<% // Set system parameters, saving their current values so they can be %>
<% // restored at the end of the do-file. %>
local varabbrev = c(varabbrev)
set varabbrev off

* Find unused Mata names.
foreach var in values text {
	mata: st_local("external", invtokens(direxternal("*")'))
	tempname `var'
	while `:list `var' in external' {
		tempname `var'
	}
}

label drop _all

