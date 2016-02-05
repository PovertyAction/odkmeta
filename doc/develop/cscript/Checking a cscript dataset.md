Checking a cscript dataset
==========================

Follow these steps to check a Stata dataset before putting it in a cscript `expected` directory:

- Check the data itself: inspect at least a subset of the values and make sure they are as expected. Metadata like variable labels is nice, but in the end, the most important thing is that these values are coming through right. As part of this, do a quick `browse` through the first few observations of the data, checking all variables.
- Type `describe` or `describe, fullnames` (abbreviated `d, f`) and inspect:
	- Variable names
	- The order of variables
	- Variable labels. These will be truncated after 80 characters.
	- Check that all variables have notes (denoted by the asterisk next to the variable label)
	- Check that the correct value labels are attached to variables
- Type `notes` and check the question text.
- Type `char list` and check the other field attributes (don't worry about the `note0`, `note1`, and `destring` characteristics):
	- Literally everything in the survey sheet should be imported as a characteristic.
	- `or_other` variables should get the characteristics of the corresponding `select` variable.
	- Where applicable, check that these characteristics are correct (see [`help odkmeta`](/README.md)):
		- `bad_name`
		- `group`
		- `long_name`
		- `repeat`
		- `list_name`
		- `or_other`
		- `is_other`
		- `geopoint`
	- No other characteristics should be defined.
	- Checking characteristics is a pain when there are many variables. I suggest choosing one `select_one` variable and one `select_multiple` variable (to check the characteristics `list_name or_other is_other`), one `geopoint` variable, one variable in a group, one variable in a repeat group, and at least one variable with many field attributes.
- Type `label list` and check the value labels.
- Check the `other` value. Not all value labels should have this value &mdash; only those that need it.
- Check that date and time variables are formatted correctly. They should be numeric, not string, and should have a `%td` or `%tc` format.
- Check that `select_multiple` variables have been split correctly.
- Check that repeat groups have been reshaped and merged into their parents.

Difficult Stata characters
--------------------------

- Left single quote: `` ` ``
- Right single quote: `'`
- Double quote: `"`
- Dollar sign: `$`
- Backslash: `\`
