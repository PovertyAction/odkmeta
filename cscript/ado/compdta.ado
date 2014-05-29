* Compares the data and metadata of two Stata datasets, resulting in an error if
* they are not the same.
pr compdta
	vers 9

	* Parse command line.
	syntax anything(name=dtas id=datasets)
	gettoken dta1 dtas : dtas
	gettoken dta2 dtas : dtas
	if `:length loc dtas' ///
		err 198

	* If only one dataset is specified, compare it to the dataset in memory.
	if !`:length loc dta2' {
		loc dta2 : copy loc dta1
		tempfile dta1
		qui sa `dta1', replace
	}

	* Check variable lists.
	forv i = 1/2 {
		qui d using `"`dta`i''"', varl
		loc varl`i' `r(varlist)'
		loc sort`i' `r(sortlist)'
	}
	if !`:list varl1 == varl2' {
		if `:list varl1 === varl2' {
			di as err "variable orders differ"
			ex 9
		}
		else {
			di as err "variable lists differ"
			ex 9
		}
		/*NOTREACHED*/
	}
	if !`:list sort1 == sort2' {
		di as err "sort variables differ"
		ex 9
	}

	preserve

	qui u `"`dta1'"', clear

	* Check values.
	cf _all using `"`dta2'"'

	* Check variable and dataset attributes.
	mata: compattribs(st_local("dta1"), st_local("dta2"))
end

loc RS	real scalar
loc RC	real colvector
loc SS	string scalar
loc SR	string rowvector
loc SC	string colvector

loc Vallab		vallab
loc VallabS		struct `Vallab' scalar
loc VallabR		struct `Vallab' rowvector

loc Char	evar_char
loc CharR	struct `Char' rowvector

loc dtaAttribs		dta_attribs
loc dtaAttribsS		struct `dtaAttribs' scalar

loc VarAttribs		var_attribs
loc VarAttribsR		struct `VarAttribs' rowvector

loc Attribs		attribs
loc AttribsS	struct `Attribs' scalar
loc AttribsR	struct `Attribs' rowvector

mata:
mata set matastrict on

struct `Vallab' {
	`SS' name
	`RC' values
	`SC' text
}

struct `Char' {
	`SS' name, text
}

struct `dtaAttribs' {
	`SS'		label
	`CharR'		chars
	`VallabR'	vallabs
}

struct `VarAttribs' {
	`RS'		index
	`SS'		name, type, format, varlab
	`VallabS'	vallab
	`CharR'		chars
}

struct `Attribs' {
	`dtaAttribsS'	dta
	`VarAttribsR'	vars
}

`AttribsS' function getattribs(`SS' _dta)
{
	`RS' n, nchars, i, j
	`RC' values
	`SC' charnames, vallabs, text
	`AttribsS' attribs

	stata(sprintf(`"qui u `"%s"', clear"', _dta))

	// Dataset label
	stata("loc lab : data lab")
	attribs.dta.label = st_local("lab")

	// Dataset characteristics
	charnames = sort(st_dir("char", "_dta", "*"), 1)
	n = length(charnames)
	attribs.dta.chars = `Char'(n)
	for (i = 1; i <= n; i++) {
		attribs.dta.chars[i].name = charnames[i]
		attribs.dta.chars[i].text = st_global(sprintf("_dta[%s]", charnames[i]))
	}

	// All value labels in the dataset
	stata("qui lab dir")
	vallabs = sort(tokens(st_global("r(names)"))', 1)
	n = length(vallabs)
	attribs.dta.vallabs = `Vallab'(n)
	for (i = 1; i <= n; i++) {
		attribs.dta.vallabs[i].name = vallabs[i]
		pragma unset values
		pragma unset text
		st_vlload(vallabs[i], values, text)
		attribs.dta.vallabs[i].values = values
		attribs.dta.vallabs[i].text   = text
	}

	// Variable attributes
	n = st_nvar()
	attribs.vars = `VarAttribs'(n)
	for (i = 1; i <= n; i++) {
		attribs.vars[i].index  = i
		attribs.vars[i].name   = st_varname(i)
		attribs.vars[i].type   = st_vartype(i)
		attribs.vars[i].format = st_varformat(i)
		attribs.vars[i].varlab = st_varlabel(i)

		// Value label
		attribs.vars[i].vallab.name = st_varvaluelabel(i)
		if (attribs.vars[i].vallab.name != "") {
			pragma unset values
			pragma unset text
			st_vlload(attribs.vars[i].vallab.name, values, text)
			attribs.vars[i].vallab.values = values
			attribs.vars[i].vallab.text   = text
		}

		// Characteristics
		charnames = sort(st_dir("char", attribs.vars[i].name, "*"), 1)
		nchars = length(charnames)
		attribs.vars[i].chars = `Char'(nchars)
		for (j = 1; j <= nchars; j++) {
			attribs.vars[i].chars[j].name = charnames[j]
			attribs.vars[i].chars[j].text =
				st_global(sprintf("%s[%s]", attribs.vars[i].name, charnames[j]))
		}
	}

	return(attribs)
}

void function compattribs(`SS' _dta1, _dta2)
{
	`RS' n, i
	`SS' var
	`AttribsR' attribs

	attribs = `Attribs'(2)
	attribs[1] = getattribs(_dta1)
	attribs[2] = getattribs(_dta2)

	// Dataset label
	if (attribs[1].dta.label != attribs[2].dta.label) {
		errprintf("dataset labels differ\n")
		exit(9)
	}

	// Dataset characteristics
	if (attribs[1].dta.chars != attribs[2].dta.chars) {
		errprintf("dataset characteristics differ\n")
		exit(9)
	}

	// Variable attributes

	if (length(attribs[1].vars) != length(attribs[2].vars)) {
		errprintf("variable lists differ\n")
		exit(9)
	}

	n = length(attribs[1].vars)
	for (i = 1; i <= n; i++) {
		// Not checking variable position, since
		// attribs[1].vars[i].index = attribs[2].vars[i].index = i
		// by definition.

		// Variable name
		if (attribs[1].vars[i].name != attribs[2].vars[i].name) {
			errprintf("variable lists or variable orders differ\n")
			exit(9)
		}

		// Storage type
		var = attribs[1].vars[i].name
		if (attribs[1].vars[i].type != attribs[2].vars[i].type) {
			errprintf("storage types differ for variable %s\n", var)
			exit(9)
		}

		// Display format
		if (attribs[1].vars[i].format != attribs[2].vars[i].format) {
			errprintf("display formats differ for variable %s\n", var)
			exit(9)
		}

		// Value label
		if (attribs[1].vars[i].vallab != attribs[2].vars[i].vallab) {
			errprintf("value labels differ for variable %s\n", var)
			exit(9)
		}

		// Variable label
		if (attribs[1].vars[i].varlab != attribs[2].vars[i].varlab) {
			errprintf("variable labels differ for variable %s\n", var)
			exit(9)
		}

		// Characteristics
		if (attribs[1].vars[i].chars != attribs[2].vars[i].chars) {
			errprintf("characteristics differ for variable %s\n", var)
			exit(9)
		}
	}

	// All value labels
	if (length(attribs[1].dta.vallabs) != length(attribs[2].dta.vallabs)) {
		errprintf("number of value labels differs\n")
		exit(9)
	}
	n = length(attribs[1].dta.vallabs)
	for (i = 1; i <= n; i++) {
		if (attribs[1].dta.vallabs[i] != attribs[2].dta.vallabs[i]) {
			errprintf("value labels differ\n")
			exit(9)
		}
	}
}

end
