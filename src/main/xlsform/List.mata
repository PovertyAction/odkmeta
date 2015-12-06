vers 11.2

findfile type_definitions.do
include `"`r(fn)'"'

mata:

struct `List' {
	`SS' listname
	`SC' names, labels
	`RS' vallab, matalab
}

end
