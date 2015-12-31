vers 11.2

matamac

findfile add_class_decl.do
include `"`r(fn)'"'
add_class_decl Field.mata

mata:

// Parent class of `Group' and `Repeat'
// There are no instances of `Collection', only of `Group' and `Repeat'.
class `Collection' {
	public:
		/* getters and setters */
		`RS'							order()
		`SS'							name()
		pointer(`FieldS') scalar		field()
		pointer(`FieldS') rowvector		fields()
		void							set_name(), add_field()

		`RS'							main(), inside(), level()
		pointer(`FieldS') scalar		first_field(), last_field()

	protected:
		virtual pointer(`TS') scalar		trans_parent()
		virtual pointer(`TS') rowvector		trans_children()

	private:
		static `RS'						ctr
		`RS'							order
		`SS'							name
		pointer(`FieldS') rowvector		fields

		`RS'							_level()
		static `RR'						field_orders()
		pointer(`FieldS') rowvector		all_fields()
		void							new()
}

void `Collection'::new()
{
	if (ctr == .)
		ctr = 0
	order = ++ctr
}

// Returns a pointer to the parent collection stored in the child class
// definition.
pointer(`TS') scalar `Collection'::trans_parent()
	_error("`Collection'.trans_parent() invoked")

// Returns pointers to the children collections stored in the child class
// definition.
pointer(`TS') rowvector `Collection'::trans_children()
	_error("`Collection'.trans_children() invoked")

// Returns the relative position of the collection within the form.
`RS' `Collection'::order()
	return(order)

`SS' `Collection'::name()
	return(name)

void `Collection'::set_name(`SS' newname)
	name = newname

// Returns pointers to the fields that the collection contains.
pointer(`FieldS') rowvector `Collection'::fields()
	return(fields)

pointer(`FieldS') scalar `Collection'::field(`RS' i)
	return(fields[i])

// Adds newfield to fields.
void `Collection'::add_field(pointer(`FieldS') scalar newfield)
	fields = fields, newfield

// Returns 1 if the collection represents the main fields, not a group or repeat
// group; returns 0 otherwise.
`RS' `Collection'::main()
	return(trans_parent() == NULL)

// Returns 1 if the collection does not represent the main fields; return 0
// otherwise.
`RS' `Collection'::inside()
	return(trans_parent() != NULL)

// Returns the level of a collection within its family tree: for the main
// fields, -_level()- returns 0; for collections among the main fields, it
// returns 1; for collections within those collections, it returns 2; and so on.
`RS' `Collection'::_level(pointer(`CollectionS') scalar collec)
{
	if (collec->main())
		return(0)
	else
		return(_level(collec->trans_parent()) + 1)
	/*NOTREACHED*/
}

`RS' `Collection'::level()
	return(_level(&this))

// Returns pointers to the collection's fields as well as the fields of the
// collection's descendants.
pointer(`FieldS') rowvector `Collection'::all_fields()
{
	`RS' n, i
	pointer(`FieldS') rowvector allfields
	pointer(`CollectionS') rowvector children

	allfields = fields

	children = trans_children()
	n = length(children)
	for (i = 1; i <= n; i++) {
		allfields = allfields, children[i]->all_fields()
	}

	return(allfields)
}

// Returns a pointer to the first field by field order within the collection.
pointer(`FieldS') scalar `Collection'::first_field(|`RS' include_children)
{
	`RR' orders
	pointer(`FieldS') rowvector f

	if (args() & include_children)
		f = all_fields()
	else
		f = fields

	if (!length(f))
		return(NULL)
	else {
		orders = field_orders(f)
		return(select(f, orders :== min(orders)))
	}
	/*NOTREACHED*/
}

// Returns a pointer to the last field by field order within the collection.
pointer(`FieldS') scalar `Collection'::last_field(|`RS' include_children)
{
	`RR' orders
	pointer(`FieldS') rowvector f

	if (args() & include_children)
		f = all_fields()
	else
		f = fields

	if (!length(f))
		return(NULL)
	else {
		orders = field_orders(f)
		return(select(f, orders :== max(orders)))
	}
	/*NOTREACHED*/
}

// Returns the field orders of a rowvector of fields.
`RR' `Collection'::field_orders(pointer(`FieldS') rowvector f)
{
	`RS' n, i
	`RR' orders

	n = length(f)
	orders = J(1, n, .)
	for (i = 1; i <= n; i++) {
		orders[i] = f[i]->order()
	}

	return(orders)
}

end
