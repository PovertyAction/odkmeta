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

end
