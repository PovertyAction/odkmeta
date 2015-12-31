vers 11.2

matamac
declareclass Collection Group Repeat

mata:

class `Field' {
	public:
		/* getters and setters */
		`RS'							order(), is_dup()
		`SS'							name(), type(), label(), attrib(),
										dup_var(), other_dup_name()
		`SR'							attribs()
		pointer(`GroupS') scalar		group()
		pointer(`RepeatS') scalar		repeat()
		void							set_name(), set_type(), set_label(),
										set_attribs(), set_group(),
										set_repeat(), set_dup_var(),
										set_other_dup_name()

		`RS'							begin_repeat(), end_repeat()
		`SS'							long_name(), st_long()
		`InsheetCodeS'					insheet()
		pointer(`GroupS') rowvector		begin_groups(), end_groups()

	private:
		static `RS'						ctr
		`RS'							order
		`SS'							name, type, label, dupvar, otherdup
		`SR'							attribs
		pointer(`GroupS') scalar		group
		pointer(`RepeatS') scalar		repeat

		pointer(`GroupS') rowvector		_begin_groups(), _end_groups()
		void							new()
}

void `Field'::new()
{
	if (ctr == .)
		ctr = 0
	order = ++ctr
}

// Returns the relative position of the field within the form.
`RS' `Field'::order()
	return(order)

`SS' `Field'::name()
	return(name)

void `Field'::set_name(`SS' newname)
	name = newname

`SS' `Field'::type()
	return(type)

void `Field'::set_type(`SS' newtype)
	type = newtype

`SS' `Field'::label()
	return(label)

void `Field'::set_label(`SS' newlabel)
	label = newlabel

`SR' `Field'::attribs()
	return(attribs)

`SS' `Field'::attrib(`RS' i)
	return(attribs[i])

void `Field'::set_attribs(`SR' newattribs)
	attribs = newattribs

// Returns a pointer to the group in which the field is nested.
// If the field is not in a group, it returns NULL.
pointer(`GroupS') scalar `Field'::group()
	return(group)

// Sets the pointer to the group in which the field is nested.
void `Field'::set_group(pointer(`GroupS') scalar newgroup)
	group = newgroup

// Returns a pointer to the repeat group in which the field is nested.
// If the field is not in a repeat group, it returns NULL.
pointer(`RepeatS') scalar `Field'::repeat()
	return(repeat)

// Sets the pointer to the repeat group in which the field is nested.
void `Field'::set_repeat(pointer(`RepeatS') scalar newrepeat)
	repeat = newrepeat

// Returns 1 if the Stata name of the field is the same as a previous field's;
// otherwise it returns 0.
`RS' `Field'::is_dup()
	return(otherdup != "")

/* If is_dup() == 1 and the field is associated with multiple variables, returns
the ODK long name of the first variable of the field with a duplicate Stata
name. For example, if mygeo is a geopoint field, then name() == "mygeo", and
dup_var() could be "mygeo-Latitude". If is_dup() == 0 or the field is associated
with a single variable, -dup_var()- returns "". */
`SS' `Field'::dup_var()
	return(dupvar)

// For fields associated with multiple variables, sets the name of the first
// variable with a duplicate Stata name.
void `Field'::set_dup_var(`SS' newdupvar)
	dupvar = newdupvar

// If is_dup() == 1, returns the ODK long name of the other field with the same
// Stata name. Otherwise, it returns "".
`SS' `Field'::other_dup_name()
	return(otherdup)

// Sets the ODK long name of the other field with the same Stata name.
void `Field'::set_other_dup_name(`SS' newotherdup)
	otherdup = newotherdup

// Returns the long name of the field.
`SS' `Field'::long_name()
	return((type != "begin repeat") * group->long_name() + name)

// Returns the long name of the field as a Stata name.
`SS' `Field'::st_long()
	return(insheet_name(long_name()))

/* Returns an `InsheetCode' scalar representing how -insheet- will import the
field's variables' long names. Return codes:
`InsheetOK'		All the variables' names are OK.
`InsheetBad'	-insheet- will not convert at least one of the variables' names
				to a Stata name.
`InsheetDup' 	At least one of the variables' Stata name is duplicate, either
				with another variable of the same field or with a variable of
				another field in the same repeat group.
`InsheetV'		At least one of the variables' Stata name is a v# name, and
				another field in the same repeat group is `InsheetBad' or
				`InsheetDup'.
*/
`InsheetCodeS' `Field'::insheet()
{
	`RS' n, i

	if (st_long() == "")
		return(`InsheetBad')
	if (is_dup())
		return(`InsheetDup')

	// geopoint variables (not fields) have a nonnumeric suffix, so they never
	// match the pattern v#.
	if (regexm(st_long(), "^v[1-9][0-9]*$") & type != "geopoint") {
		n = length(repeat->fields())
		for (i = 1; i <= n; i++) {
			if (repeat->field(i)->order != order &
				(repeat->field(i)->st_long() == "" |
				repeat->field(i)->is_dup())) {
				return(`InsheetV')
			}
		}
	}

	return(`InsheetOK')
}

// Returns 1 if the field is the first field in its repeat group; returns 0 if
// not.
`RS' `Field'::begin_repeat()
{
	pointer(`FieldS') scalar first

	if (repeat->main())
		return(0)

	first = repeat->first_field()
	if (first == NULL)
		return(0)
	return(order == first->order)
}

// Returns 1 if the field is the last field in its repeat group; returns 0 if
// not.
`RS' `Field'::end_repeat()
{
	pointer(`FieldS') scalar last

	if (repeat->main())
		return(0)

	last = repeat->last_field()
	if (last == NULL)
		return(0)
	return(order == last->order())
}

// Returns pointers to the groups for which the field is the first field.
pointer(`GroupS') rowvector `Field'::begin_groups()
	return(_begin_groups(group))

pointer(`GroupS') rowvector `Field'::_begin_groups(pointer(`GroupS') scalar g)
{
	pointer(`FieldS') scalar groupfirst

	if (g == NULL)
		return(J(1, 0, NULL))
	if (g->main())
		return(J(1, 0, NULL))

	groupfirst = g->first_field(1)
	if (groupfirst == NULL)
		return(J(1, 0, NULL))

	if (order == groupfirst->order())
		return(_begin_groups(g->parent()), g)
	else
		return(J(1, 0, NULL))
	/*NOTREACHED*/
}

// Returns pointers to the groups for which the field is the last field.
pointer(`GroupS') rowvector `Field'::end_groups()
	return(_end_groups(group))

pointer(`GroupS') rowvector `Field'::_end_groups(pointer(`GroupS') scalar g)
{
	pointer(`FieldS') scalar grouplast

	if (g == NULL)
		return(J(1, 0, NULL))
	if (g->main())
		return(J(1, 0, NULL))

	grouplast = g->last_field(1)
	if (grouplast == NULL)
		return(J(1, 0, NULL))

	if (order == grouplast->order())
		return(g, _end_groups(g->parent()))
	else
		return(J(1, 0, NULL))
	/*NOTREACHED*/
}

end
