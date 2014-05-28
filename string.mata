vers 11.2

findfile type_definitions.do
include `"`r(fn)'"'

mata:

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

end
