odkmeta
=======

`odkmeta` writes a [do-file](http://www.stata.com/manuals13/u16.pdf) to import ODK data to Stata, using the metadata from the `survey` and `choices` worksheets of the XLSForm. The do-file completes the following tasks in order:

- Import lists as [value labels](http://www.stata.com/help.cgi?label)
- Add `other` values to value labels
- Import field attributes as [characteristics](http://www.stata.com/help.cgi?char)
- Split `select_multiple` variables
- Drop `note` variables
- [Format](http://www.stata.com/help.cgi?format) `date`, `time`, and `datetime` variables
- Attach value labels
- Attach field labels as [variable labels](http://www.stata.com/help.cgi?label) and [notes](http://www.stata.com/help.cgi?notes)
- [Merge](http://www.stata.com/help.cgi?merge) repeat groups

The latest stable version is [`stable/odkmeta.ado`](/stable/odkmeta.ado), and is available through [SSC](http://www.stata.com/support/ssc-installation/): type `ssc install odkmeta` in Stata to install. Run [`write_ado.do`](/write_ado.do) to append all working source code files into a single `odkmeta.ado` containing the latest changes.

Certification script
--------------------

The [certification script](http://www.stata.com/help.cgi?cscript) of `odkmeta` is [`cscript/odkmeta.do`](/cscript/odkmeta.do). If you are new to certification scripts, you may find [this](http://www.stata-journal.com/sjpdf.html?articlenum=pr0001) Stata Journal article helpful. See [this guide](/cscript/Tests.md) for more on `odkmeta` testing.

Contributing
------------

Help keep `odkmeta` up-to-date by contributing code. See the [issues](https://github.com/matthew-white/odkmeta/issues?state=open) for current to-dos. If you have experience with an ODK flavor not yet supported, please contribute your knowledge through pull requests or issues.

Most contributors will wish to modify one of `write_*.mata`, e.g., [`write_choices.mata`](/write_choices.mata). The `odkmeta` Stata program itself is stored in [`odkmeta.do`](/odkmeta.do); review it for an overview of the program flow. When contributing code, adding associated [cscript tests](/cscript/Tests.md) is much appreciated.

Follow [these steps](/doc/Development environment.md) to set up your Stata environment for `odkmeta` development. At the end, individual source code files should be able to run on their own: there is no need to run `write_ado.do` when working on a single source code file.

Development files for which GitHub is not suitable are stored on Box: https://app.box.com/odkmeta-public. The Box has public read access; contact Matt for write access. If an issue refers to files that cannot be uploaded to GitHub, they should be saved in Box. The Box should never contain personally identifiable or other sensitive information.

License
-------

See [LICENSE.txt](/LICENSE.txt) for licensing information (MIT).

Stata help file
---------------

Converted automatically from SMCL:

```
log html odkmeta.sthlp odkmeta.md
```

The help file looks best when viewed in Stata as SMCL.

<pre>
<b><u>Title</u></b>
<p>
    <b>odkmeta</b> -- Create a do-file to import ODK data
<p>
<p>
<a name="syntax"></a><b><u>Syntax</u></b>
<p>
        <b>odkmeta</b> <b>using</b> <i>filename</i><b>,</b> <b>csv(</b><i>csvfile</i><b>)</b> <b><u>s</u></b><b>urvey(</b><i>surveyfile</i><b>,</b> <i>surveyopts</i><b>)</b>
          <b><u>cho</u></b><b>ices(</b><i>choicesfile</i><b>,</b> <i>choicesopts</i><b>)</b> [<i>options</i>]
<p>
    <i>options</i>                               Description
    -------------------------------------------------------------------------
    Main
    * <b>csv(</b><i>csvfile</i><b>)</b>                        name of the .csv file that contains
                                            the ODK data
    * <b><u>s</u></b><b>urvey(</b><i>surveyfile</i><b>,</b> <i>surveyopts</i><b>)</b>      import metadata from the <i>survey</i>
                                            worksheet <i>surveyfile</i>
    * <b><u>cho</u></b><b>ices(</b><i>choicesfile</i><b>,</b> <i>choicesopts</i><b>)</b>   import metadata from the <i>choices</i>
                                            worksheet <i>choicesfile</i>
<p>
    Fields
      <b><u>drop</u></b><b>attrib(</b><i>headers</i><b>)</b>                 do not import field attributes with
                                            the column headers <i>headers</i>
      <b><u>keep</u></b><b>attrib(</b><i>headers</i><b>)</b>                 import only field attributes with
                                            the column headers <i>headers</i>
      <b><u>rel</u></b><b>ax</b>                               ignore fields in <i>surveyfile</i> that do
                                            not exist in <i>csvfile</i>
<p>
    Lists
      <b><u>oth</u></b><b>er(</b><i>other</i><b>)</b>                        Stata value of <b>other</b> values of
                                            <b>select or_other</b> fields; default
                                            is <b>max</b>
      <b><u>one</u></b><b>line</b>                             write each list on a single line
<p>
    Options
      <b>replace</b>                             overwrite existing <i>filename</i>
    -------------------------------------------------------------------------
    * <b>csv()</b>, <b>survey()</b>, and <b>choices()</b> are required.
<p>
<a name="surveyopts"></a>    <i>surveyopts</i>               Description
    -------------------------------------------------------------------------
    Main
      <b><u>t</u></b><b>ype(</b><i>header</i><b>)</b>           column header of the <i>type</i> field attribute;
                               default is <b>type</b>
      <b>name(</b><i>header</i><b>)</b>           column header of the <i>name</i> field attribute;
                               default is <b>name</b>
      <b><u>la</u></b><b>bel(</b><i>header</i><b>)</b>          column header of the <i>label</i> field attribute;
                               default is <b>label</b>
      <b><u>d</u></b><b>isabled(</b><i>header</i><b>)</b>       column header of the <i>disabled</i> field attribute;
                               default is <b>disabled</b>
    -------------------------------------------------------------------------
<p>
<a name="choicesopts"></a>    <i>choicesopts</i>              Description
    -------------------------------------------------------------------------
    Main
      <b><u>li</u></b><b>stname(</b><i>header</i><b>)</b>       column header of the <i>list_name</i> list attribute;
                               default is <b>list_name</b>
      <b>name(</b><i>header</i><b>)</b>           column header of the <i>name</i> list attribute;
                               default is <b>name</b>
      <b><u>la</u></b><b>bel(</b><i>header</i><b>)</b>          column header of the <i>label</i> list attribute;
                               default is <b>label</b>
    -------------------------------------------------------------------------
<p>
<a name="other"></a>    <i>other</i>                    Description
    -------------------------------------------------------------------------
      <b>max</b>                    maximum value of each list: maximum list value
                               plus one
      <b>min</b>                    minimum value of each list: minimum list value
                               minus one
      <i>#</i>                      constant value for all value labels
    -------------------------------------------------------------------------
<p>
<p>
<a name="description"></a><b><u>Description</u></b>
<p>
    <b>odkmeta</b> creates a do-file to import ODK data, using the metadata from the
    <i>survey</i> and <i>choices</i> worksheets of the XLSForm. The do-file, saved to
    <i>filename</i>, completes the following tasks in order:
<p>
        o Import lists as value labels
        o Add <b>other</b> values to value labels
        o Import field attributes as characteristics
        o Split <b>select_multiple</b> variables
        o Drop <b>note</b> variables
        o Format <b>date</b>, <b>time</b>, and <b>datetime</b> variables
        o Attach value labels
        o Attach field labels as variable labels and notes
        o Merge repeat groups
<p>
    After <b>select_multiple</b> variables have been split, tasks can be removed
    from the do-file without affecting other tasks.  User-written supplements
    to the do-file may make use of any field attributes, which are imported
    as characteristics.
<p>
<p>
<a name="remarks"></a><b><u>Remarks</u></b>
<p>
    The <b>odkmeta</b> do-file uses <b>insheet</b> to import data.  Fields that are long
    strings of digits, such as <b>simserial</b> fields, will be imported as numeric
    even if they are more than 16 digits.  As a result, they will lose
    precision.
<p>
    The do-file makes limited use of Mata to manage variable labels, value
    labels, and characteristics and to import field attributes and lists that
    contain difficult characters.
<p>
    The do-file starts with the definitions of several local macros; these
    are constants that the do-file uses.  For instance, local macro
    <b>`datemask'</b> is the mask of date values in the .csv files.  The local
    macros are automatically set to default values, but they may need to be
    changed depending on the data.
<p>
<p>
<a name="remarks_field_names"></a><b><u>Remarks for field names</u></b>
<p>
    ODK field names follow different conventions from Stata's constraints on
    variable names.  Further, the field names in the .csv files are the
    fields' "long names," which are formed by concatenating the list of the
    <i>groups</i> in which the field is nested with the field's "short name." ODK
    long names are often much longer than the length limit on variable names,
    which is 32 characters.
<p>
    These differences in convention lead to three kinds of problematic field
    names:
<p>
        1.  Long field names that involve an invalid combination of
            characters, for example, a name that begins with a colon followed
            by a number.  <b>insheet</b> will not convert these to Stata names,
            instead naming each variable <b>v</b> concatenated with a positive
            integer, for example, <b>v1</b>.
        2.  Long field names that are unique ODK names but when converted to
            Stata names and truncated to 32 characters become duplicates.
            <b>insheet</b> will again convert these to <b>v</b><i>#</i> names.
        3.  Long field names of the form <b>v</b><i>#</i> that become duplicates with other
            variables that cannot be converted, for which <b>insheet</b> chooses <b>v</b><i>#</i>
            names.  These will be converted to different <b>v</b><i>#</i> names.
<p>
    Because of problem 3, it is recommended that you do not name fields as
    <b>v</b><i>#</i>.
<p>
    If a field name cannot be imported, its characteristic <b>Odk_bad_name</b> is <b>1</b>;
    otherwise it is <b>0</b>.
<p>
    Most tasks that the <b>odkmeta</b> do-file completes do not depend on variable
    names. There are two exceptions:
<p>
        1.  The do-file uses <b>split</b> to split <b>select_multiple</b> variables. <b>split</b>
            will result in an error if a <b>select_multiple</b> variable has a long
            name or if splitting it would result in duplicate variable names.
        2.  The do-file uses <b>reshape</b> and <b>merge</b> to merge repeat groups.
            <b>reshape</b> will result in an error if there are long variable names.
            The merging code will result in an error if there are duplicate
            variable names in two datasets.
<p>
    Where variable names result in an error, renaming is left to the user.
    The section of the do-file for splitting is preceded by a designated area
    for renaming.  In the section for reshaping and merging, each repeat
    group has its own area for renaming.
<p>
    Many forms do not require any variable renaming.  For others, only a few
    variables need to be renamed; such renaming should go in the designated
    areas.  However, some forms, usually because of many nested groups or
    groups with long names, have many long field names that become duplicate
    Stata names (problem 2 above).  In this case, it may work best to use
    fields' short names where possible.  The following code attempts to
    rename variables to their field short names.  Place it as-is before the
    renaming for <b>split</b>:
<p>
    <b>foreach var of varlist _all {</b>
        <b>if "`:char `var'[Odk_group]'" != "" {</b>
            <b>local name = "`:char `var'[Odk_name]'" + ///</b>
                <b>cond(`:char `var'[Odk_is_other]', "_other", "") + ///</b>
                <b>"`:char `var'[Odk_geopoint]'"</b>
            <b>local newvar = strtoname("`name'")</b>
            <b>capture rename `var' `newvar'</b>
        <b>}</b>
    <b>}</b>
<p>
<p>
<a name="remarks_lists"></a><b><u>Remarks for lists</u></b>
<p>
    ODK list names are not necessarily valid Stata names.  However, <b>odkmeta</b>
    uses list names as value label names, and it requires that all ODK list
    names be Stata names.
<p>
    ODK lists are lists of associations of names and labels.  There are two
    broad categories of lists:  those whose names are all integer and those
    with at least one noninteger name.  In the former case, the values of the
    value label are the same as the names of the list.  In the latter, the
    values of the value label indicate the order of the names within the
    list:  the first name will equal <b>1</b>, the second <b>2</b>, and so on.  For such
    lists, the value of the value label may differ from the name of the list
    even if the name is a valid value label value; what matters is whether
    all names of the list are integer.
<p>
    However, the value labels of these lists are easy to modify.  Simply
    change the values of the value labels in the do-file; the rest of the
    do-file will be unaffected.  Do not change the value label text.
<p>
    Certain names do not interact well with <b>insheet</b>, which the <b>odkmeta</b>
    do-file uses to import the data.
<p>
    For instance, it is not always possible to distinguish a name of <b>"."</b> from
    <b>sysmiss</b>. When it is unclear, the do-file assumes that values equal the
    name <b>"."</b> and not <b>sysmiss</b>.  The problem arises when <b>insheet</b> imports <b>select</b>
    fields whose names in the data are the same as the values of a Stata
    numeric variable:  real numbers, <b>sysmiss</b>, and extended missing values.
    <b>insheet</b> imports such fields as numeric, converting blank values (<b>""</b>) as
    <b>sysmiss</b>, thereby using the same Stata value for the name <b>"."</b> and for
    blank values.
<p>
    <b>insheet</b> does not always interact well with list values' names that look
    like numbers with leading zeros, for example, <b>01</b> or <b>0.5</b>.  If <b>insheet</b>
    imports a <b>select</b> field as numeric, it will remove such leading zeros,
    leading to incorrect values or an error in the do-file. For similar
    reasons, trailing zeros after a decimal point may be problematic.
<p>
    List values' names that look like decimals may also not interact well
    with <b>insheet</b>. If <b>insheet</b> imports a <b>select</b> field as numeric, the do-file
    will convert it to string. However, for precision reasons, the resulting
    string may differ from the original name if the decimal has no exact
    finite-digit representation in binary.
<p>
    Generally, names that look like numbers that cannot be stored precisely
    as <b>double</b> are problematic.  This includes numbers large in magnitude.
<p>
<p>
<a name="remarks_variants"></a><b><u>Remarks for ODK variants</u></b>
<p>
    <b>odkmeta</b> is not designed for features specific to ODK variants, such as
    SurveyCTO or formhub.  However, it is often possible to modify the
    <b>odkmeta</b> do-file to account for these features, especially as all field
    attributes are imported as characteristics.
<p>
    <u>SurveyCTO</u>
<p>
    For instance, the <b>odkmeta</b> do-file will result in an error for SurveyCTO
    forms that contain dynamic choice lists.  One solution is to make the
    following changes to the do-file in order to import <b>select</b> fields with
    dynamic lists as string variables.
<p>
    One section of the <b>odkmeta</b> do-file encodes <b>select</b> fields whose list
    contains a noninteger name.  Here, remove dynamic lists from the list of
    such lists:
<p>
    <b>* Encode fields whose list contains a noninteger name.</b>
    <b>local lists list1 list2 list3 ...</b>
    ...
<p>
    Above, if <b>list3</b> were a dynamic list, it should be removed.
<p>
    The next section of the do-file attaches value labels to variables:
<p>
    <b>* Attach value labels.</b>
    <b>ds, not(vallab)</b>
    <b>if "`r(varlist)'" != "" ///</b>
        <b>ds `r(varlist)', has(char Odk_list_name)</b>
    <b>foreach var in `r(varlist)' {</b>
        <b>if !`:char `var'[Odk_is_other]' {</b>
    <b>...</b>
<p>
    Add a line to the second <b>if</b> command to exclude fields whose <i>appearance</i>
    attribute contains a <b>search()</b> expression:
<p>
    <b>* Attach value labels.</b>
    <b>ds, not(vallab)</b>
    <b>if "`r(varlist)'" != "" ///</b>
        <b>ds `r(varlist)', has(char Odk_list_name)</b>
    <b>foreach var in `r(varlist)' {</b>
        <b>if !`:char `var'[Odk_is_other]' &amp; ///</b>
            <b>!strmatch("`:char `var'[Odk_appearance]'", "*search(*)*") {</b>
    <b>...</b>
<p>
    The do-file will now import fields with dynamic lists without resulting
    in an error.
<p>
    <u>formhub</u>
<p>
    formhub does not export <b>note</b> fields in the .csv files; specify option
    <b>relax</b> to <b>odkmeta</b>.
<p>
    formhub exports blank values as <b>"n/a"</b>.  Multiple sections of the <b>odkmeta</b>
    do-file must be modified to accommodate these.
<p>
    Immediately before this line in the section for formatting <b>date</b>, <b>time</b>,
    and <b>datetime</b> variables:
<p>
    <b>if inlist("`type'", "date", "today") {</b>
<p>
    add the following line:
<p>
    <b>replace `var' = "" if `var' == "n/a"</b>
<p>
    Immediately before this line in the section for attaching value labels:
<p>
    <b>replace `var' = ".o" if `var' == "other"</b>
<p>
    add the following line:
<p>
    <b>replace `var' = "" if `var' == "n/a"</b>
<p>
    These lines replace <b>"n/a"</b> values with blank (<b>""</b>).
<p>
<p>
<a name="remarks_missing"></a><b><u>Remarks for "don't know," refusal, and other missing values</u></b>
<p>
    ODK lists may contain missing values, including "don't know" and refusal
    values.  These will be imported as nonmissing in Stata.  However, if the
    lists use largely consistent names or labels for the values, it may be
    possible to automate the conversion of the values to extended missing
    values in Stata.  The following SSC programs may be helpful:
<p>
    <b>labmvs</b>       <b>ssc install labutil2</b>
    <b>labmv</b>        <b>ssc install labutil2</b>
    <b>labrecode</b>    <b>ssc install labutil2</b>
    <b>labelmiss</b>    <b>ssc install labelmiss</b>
<p>
<p>
<a name="options"></a><b><u>Options</u></b>
<p>
        +------+
    ----+ Main +-------------------------------------------------------------
<p>
    <b>survey(</b><i>surveyfile</i><b>,</b> <i>surveyopts</i><b>)</b> imports the field metadata from the
        XLSForm's <i>survey</i> worksheet.  <b>survey()</b> requires <i>surveyfile</i> to be a
        comma-separated text file.  Strings with embedded commas, double
        quotes, or end-of-line characters must be enclosed in quotes, and
        embedded double quotes must be preceded by another double quote.
<p>
        Each attribute in the <i>survey</i> worksheet has its own column and column
        header.  Use the suboptions <b>type()</b>, <b>name()</b>, <b>label()</b>, and <b>disabled()</b>
        to specify alternative column headers for the <i>type</i>, <i>name</i>, <i>label</i>, and
        <i>disabled</i> attributes, respectively.  All field attributes are imported
        as characteristics.
<p>
        If the <i>survey</i> worksheet has duplicate column headers, only the first
        column for each column header is used.
<p>
        The <i>type</i> characteristic is standardized as follows:
<p>
        o <b>select one</b> is replaced as <b>select_one</b>.
        o <b>select or other</b> is replaced as <b>select or_other</b>:  <b>select_one</b>
            <i>list_name</i> <b>or other</b> is replaced as <b>select_one</b> <i>list_name</i> <b>or_other</b>,
            and <b>select_multiple</b> <i>list_name</i> <b>or other</b> is replaced as
            <b>select_multiple</b> <i>list_name</i> <b>or_other</b>.
        o <b>begin_group</b> is replaced as <b>begin group</b>; <b>end_group</b> is replaced as
            <b>end group</b>; <b>begin_repeat</b> is replaced as <b>begin repeat</b>; and
            <b>end_repeat</b> is replaced as <b>end repeat</b>.
<p>
        In addition to the attributes specified in the <i>survey</i> worksheet,
        <b>odkmeta</b> attaches these characteristics to variables:
<p>
<a name="Odk_bad_name"></a>            <b>Odk_bad_name</b> is <b>1</b> if the variable's name differs from its ODK
            field name and <b>0</b> if not.  See the remarks for field names above.
<p>
            <b>Odk_group</b> contains a list of the <i>groups</i> in which the variable is
            nested, in order of the <i>group</i> level.
<p>
            <b>Odk_long_name</b> contains the field's "long name," which is formed
            by concatenating the list of the <i>groups</i> in which the field is
            nested with the field "short name," with elements separated by
            <b>"-"</b>.
<p>
            <b>Odk_repeat</b> contains the (long) name of the repeat group in which
            the variable is nested.
<p>
            <b>Odk_list_name</b> contains the name of a <b>select</b> field's list.
<p>
            <b>Odk_or_other</b> is <b>1</b> if the variable is a <b>select or_other</b> field and
            <b>0</b> if not.
<p>
            <b>Odk_is_other</b> is <b>1</b> if the variable is a free-text <b>other</b> variable
            associated with a <b>select or_other</b> field; otherwise it is <b>0</b>.
<p>
            For <b>geopoint</b> variables, <b>Odk_geopoint</b> is the variable's <b>geopoint</b>
            component:  <b>Latitude</b>, <b>Longitude</b>, <b>Altitude</b>, or <b>Accuracy</b>.  For
            variables that are not type <b>geopoint</b>, <b>Odk_geopoint</b> is blank.
<p>
    <b>choices(</b><i>choicesfile</i><b>,</b> <i>choicesopts</i><b>)</b> imports the list metadata from the
        XLSForm's <i>choices</i> worksheet.  <b>choices()</b> requires <i>choicesfile</i> to be a
        comma-separated text file.  Strings with embedded commas, double
        quotes, or end-of-line characters must be enclosed in quotes, and
        embedded double quotes must be preceded by another double quote.
<p>
        Each attribute in the <i>choices</i> worksheet has its own column and column
        header.  Use the suboptions <b>listname()</b>, <b>name()</b>, and <b>label()</b> to
        specify alternative column headers for the <i>list_name</i>, <i>name</i>, and <i>label</i>
        attributes, respectively.  List attributes are imported as value
        labels.
<p>
        If the <i>choices</i> worksheet has duplicate column headers, only the first
        column for each column header is used.
<p>
        +--------+
    ----+ Fields +-----------------------------------------------------------
<p>
    <b>dropattrib(</b><i>headers</i><b>)</b> specifies the column headers of field attributes that
        should not be imported as characteristics.  <b>_all</b> specifies that all
        characteristics be dropped.
<p>
    <b>keepattrib(</b><i>headers</i><b>)</b> specifies the column headers of field attributes to
        import as characteristics.  <b>_all</b> means all column headers. Other
        attributes are not imported.
<p>
    <b>relax</b> specifies that fields mentioned in <i>surveyfile</i> that do not exist in
        <i>csvfile</i> be ignored.  By default, the do-file attempts to attach the
        characteristics to these variables, resulting in an error if the
        variable does not exist.  For fields associated with multiple
        variables, for example, <b>geopoint</b> fields, <b>relax</b> attempts to attach the
        characteristics to as many variables as possible:  an error does not
        result if some but not all variables exist.
<p>
        +-------+
    ----+ Lists +------------------------------------------------------------
<p>
    <b>other(</b><i>other</i><b>)</b> specifies the Stata value of <b>other</b> values of <b>select or_other</b>
        fields.
<p>
        <b>max</b>, the default, specifies that the Stata value of <b>other</b> vary by the
        field's list.  For each list, <b>other</b> will be the maximum value of the
        list plus one.
<p>
        <b>min</b> specifies that the Stata value of <b>other</b> vary by the field's list.
        For each list, <b>other</b> will be the minimum value of the list minus one.
<p>
        <i>#</i> specifies a constant value for <b>other</b> that will be used for all
        lists.
<p>
    <b>oneline</b> specifies that each list's value label definition be written on
        one line, rather than on multiple using <b>#delimit ;</b>.
<p>
        +-------+
    ----+ Other +------------------------------------------------------------
<p>
    <b>replace</b> specifies that the <b>odkmeta</b> do-file be replaced if it already
        exists.
<p>
<p>
<a name="examples"></a><b><u>Examples</u></b>
<p>
    Create a do-file named <b>import.do</b> that imports ODK data, including the
    metadata in <b>survey.csv</b> and <b>choices.csv</b>
        <b>. odkmeta using import.do, csv("ODKexample.csv") survey("survey.csv")</b>
            <b>choices("choices.csv")</b>
<p>
    Same as the previous <b>odkmeta</b> command, but specifies that the field <i>name</i>
    attribute appears in the <b>fieldname</b> column of <b>survey_fieldname.csv</b>
        <b>. odkmeta using import.do, csv("ODKexample.csv")</b>
            <b>survey("survey_fieldname.csv", name(fieldname))</b>
            <b>choices("choices.csv") replace</b>
<p>
    Same as the previous <b>odkmeta</b> command, but specifies that the list <i>name</i>
    attribute appears in the <b>valuename</b> column of <b>choices_valuename.csv</b>
        <b>. odkmeta using import.do, csv("ODKexample.csv")</b>
            <b>survey("survey_fieldname.csv", name(fieldname))</b>
            <b>choices("choices_valuename.csv", name(valuename)) replace</b>
<p>
    Create a do-file that imports all field attributes except for <i>hint</i>
        <b>. odkmeta using import.do, csv("ODKexample.csv") survey("survey.csv")</b>
            <b>choices("choices.csv") dropattrib(hint) replace</b>
<p>
    Same as the previous <b>odkmeta</b> command, but does not import any field
    attributes
        <b>. odkmeta using import.do, csv("ODKexample.csv") survey("survey.csv")</b>
            <b>choices("choices.csv") dropattrib(_all) replace</b>
<p>
    Create a do-file that imports <b>other</b> values of <b>select or_other</b> fields as
    <b>99</b>
        <b>. odkmeta using import.do, csv("ODKexample.csv") survey("survey.csv")</b>
            <b>choices("choices.csv") other(99) replace</b>
<p>
<p>
<a name="acknowledgements"></a><b><u>Acknowledgements</u></b>
<p>
    Lindsey Shaughnessy of Innovations for Poverty Action assisted in almost
    all aspects of <b>odkmeta</b>'s development.  She collaborated on the structure
    of the program, was a very helpful tester, and contributed information
    about ODK.
<p>
<p>
<a name="author"></a><b><u>Author</u></b>
<p>
    Matthew White
<p>
    For questions or suggestions, submit a GitHub issue or e-mail
    researchsupport@poverty-action.org.
</pre>
