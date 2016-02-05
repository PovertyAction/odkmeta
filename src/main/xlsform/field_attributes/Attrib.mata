vers 11.2

matamac
matainclude AttribProps

mata:

// A single field attribute, used solely within class `AttribSet'
// `Attrib' and `AttribProps' are separated so the user can freely change props
// (the elements of `AttribProps') but can modify name only through `AttribSet'.
struct `Attrib' {
	`SS' name
	`AttribPropsS' props
}

end
