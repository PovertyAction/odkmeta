vers 11.2

matamac

findfile Collection.mata
include `"`r(fn)'"'

mata:

// Represents ODK groups.
class `Group' extends `Collection' {
	public:
		/* getters and setters */
		pointer(`GroupS') scalar		parent(), child()
		pointer(`GroupS') rowvector		children()
		void							set_parent(), add_child()

		`SS'							long_name(), st_list()

	protected:
		virtual pointer(`TS') scalar		trans_parent()
		virtual pointer(`TS') rowvector		trans_children()

	private:
		pointer(`GroupS') scalar		parent
		pointer(`GroupS') rowvector		children
}

pointer(`TS') scalar `Group'::trans_parent()
	return(parent)

pointer(`GroupS') scalar `Group'::parent()
	return(parent)

void `Group'::set_parent(pointer(`GroupS') scalar newparent)
	parent = newparent

pointer(`TS') rowvector `Group'::trans_children()
	return(children)

pointer(`GroupS') rowvector `Group'::children()
	return(children)

pointer(`GroupS') scalar `Group'::child(`RS' i)
	return(children[i])

// Adds newchild to children.
void `Group'::add_child(pointer(`GroupS') scalar newchild)
	children = children, newchild

// Returns the group's long name.
`SS' `Group'::long_name()
{
	if (main())
		return("")
	else
		return(parent->long_name() + name() + "-")
	/*NOTREACHED*/
}

// Returns the name of the group appended to a string list of the names of the
// groups in which the group is nested.
`SS' `Group'::st_list()
{
	`SS' parentlist

	if (main())
		return("")
	else {
		parentlist = parent->st_list()
		return(parentlist + (parentlist != "") * " " +
			adorn_quotes(name(), "list"))
	}
	/*NOTREACHED*/
}

end
