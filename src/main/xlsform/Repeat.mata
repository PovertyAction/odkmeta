vers 11.2

matamac
declareclass Collection Group Field

mata:

// Represents repeat groups.
class `Repeat' extends `Collection' {
	public:
		/* getters and setters */
		pointer(`RepeatS') scalar		parent(), child()
		pointer(`RepeatS') rowvector	children()
		pointer(`GroupS') scalar		parent_group()
		pointer(`FieldS') scalar		parent_set_of(), child_set_of()
		void							set_parent(), add_child(),
										set_parent_group(), set_parent_set_of(),
										set_child_set_of()

		`SS'							long_name()

	protected:
		virtual pointer(`TS') scalar		trans_parent()
		virtual pointer(`TS') rowvector		trans_children()

	private:
		pointer(`RepeatS') scalar		parent
		pointer(`RepeatS') rowvector	children
		pointer(`GroupS') scalar		parentgroup
		pointer(`FieldS') scalar		parentsetof, childsetof
}

pointer(`TS') scalar `Repeat'::trans_parent()
	return(parent)

pointer(`RepeatS') scalar `Repeat'::parent()
	return(parent)

void `Repeat'::set_parent(pointer(`RepeatS') scalar newparent)
	parent = newparent

pointer(`TS') rowvector `Repeat'::trans_children()
	return(children)

pointer(`RepeatS') rowvector `Repeat'::children()
	return(children)

pointer(`RepeatS') scalar `Repeat'::child(`RS' i)
	return(children[i])

// Adds newchild to children.
void `Repeat'::add_child(pointer(`RepeatS') scalar newchild)
	children = children, newchild

pointer(`GroupS') scalar `Repeat'::parent_group()
	return(parentgroup)

void `Repeat'::set_parent_group(newgroup)
	parentgroup = newgroup

// Every repeat group is associated with two SET-OF fields, one in the repeat
// group and one in its parent.
// -parent_set_of()- returns a pointer to the parent's SET-OF field.
pointer(`FieldS') scalar `Repeat'::parent_set_of()
	return(parentsetof)

void `Repeat'::set_parent_set_of(pointer(`FieldS') scalar newsetof)
	parentsetof = newsetof

// Every repeat group is associated with two SET-OF fields, one in the repeat
// group and one in its parent.
// -child_set_of()- returns a pointer to this repeat group's SET-OF field (the
// child SET-OF).
pointer(`FieldS') scalar `Repeat'::child_set_of()
	return(childsetof)

void `Repeat'::set_child_set_of(pointer(`FieldS') scalar newsetof)
	childsetof = newsetof

// Returns the repeat group's long name.
`SS' `Repeat'::long_name()
{
	// The main fields, represented as a repeat group, have parentgroup == NULL.
	if (parentgroup == NULL)
		return(name())
	else
		return(parentgroup->long_name() + name())
	/*NOTREACHED*/
}

end
