vers 11.2

matamac

mata:

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

end
