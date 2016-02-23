args(
	// Merge child dataset into parent
	pointer(`RepeatS') scalar parent,
	`SS' child,
	// SET-OF variable of the parent dataset
	`SS' set_of
)
<% `SS' description %>
unab before : _all
<% // Check that there is no unexpected variable list overlap. %>
local pos : list posof <%= adorn_quotes(child) %> in repeats
local child : word `pos' of `childfiles'
describe using `child', varlist
local childvars `r(varlist)'
local overlap : list before & childvars
local KEY KEY
local overlap : list overlap - KEY
quietly if `:list sizeof overlap' {
	gettoken first : overlap
	<% description = parent->main() ? "the main fields" : "repeat group " + parent->long_name() %>
	noisily display as err "error merging <%= description %> and repeat group <%= child %>"
	noisily display as err "variable `first' exists in both datasets"
	noisily display as err "rename it in one or both, then try again"
	exit 9
}

tempvar order
generate `order' = _n
if !_N ///
	tostring KEY, replace
tempvar merge
merge KEY using `child', sort _merge(`merge')
tabulate `merge'
assert `merge' != 2
<% /* Restore the sort order.
This sort may be unnecessary: -merge- may complete it automatically.
However, this is not assured in the documentation, and the -reshape- requires it.
(Otherwise, _j could be incorrect.) */ %>
sort `order'
drop `order' `merge'

<% // Restore the variable order. %>
unab after : _all
local new : list after - before
foreach var of local new {
	move `var' <%= set_of %>
}
drop <%= set_of %>
