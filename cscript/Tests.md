odkmeta tests
=============

Below is a list of `odkmeta` tests. Unless marked otherwise, all tests are implemented in the [cscript](/cscript/odkmeta.do). Each test is associated with a unique positive integer ID. IDs are consecutive starting with 137. Some live-project tests with IDs before 137 are stored off GitHub and are not listed in the table below. If you are an [IPA](http://poverty-action.org/) employee, contact Matt or Lindsey to gain access.

Contributions of new tests are welcome. When adding a test to the cscript, please add a row to the table below. Further, please add expected datasets, checking them according to [this guide](/cscript/Checking a cscript dataset.md). All datasets should be readable by Stata 11, the minimal supported version.

Note that the `.xls` forms in `Tests` may differ from the corresponding `survey` and `choices` `.csv` files.

<table>
<tr>
	<th>Test ID</th>
	<th>Checked by</th>
	<th>Area</th>
	<th>Form description</th>
</tr>
<tr>
	<td>1</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Example test</td>
	<td>LindseyAudio_orother.xls: used as an example for the cscript.</td>
</tr>
<tr>
	<td>2</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a></td>
	<td>Basic</td>
	<td>Exactly one, extremely simple integer field. The question text should contain a space somewhere in the middle. No field attribute should contain a difficult Stata character, an end-of-line delimiter (\r\n, \n, or \r: <a>http://en.wikipedia.org/wiki/Newline</a>), or a comma.<br><br>The .csv files for the survey and choices sheets must be saved with the Windows end-of-line (EOL) delimiter (\r\n). Their filenames should not contain spaces. The ODK data .csv filename should not contain spaces.<br><br>Do not use option -replace-. To overwrite, erase the .dta file yourself beforehand. (You can use the Stata -erase- command for this.) [ID 19] tests -replace-.</td>
</tr>
<tr>
	<td>3</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a></td>
	<td>.csv file</td>
	<td>Same as [ID 2], except with the .csv files saved with the \n EOL delimiter instead of \r\n. -odkmeta- should be able to handle .csv files from any OS.</td>
</tr>
<tr>
	<td>4</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>.csv file</td>
	<td>Same as [ID 2], except with the .csv files saved with the \r EOL delimiter instead of \r\n.</td>
</tr>
<tr>
	<td>5</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a></td>
	<td>.csv file</td>
	<td>Same as [ID 2], except that the question text should contain \n somewhere in the middle. -odkmeta- should replace it with a space (so multiple, consecutive spaces are likely).</td>
</tr>
<tr>
	<td>6</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>.csv file</td>
	<td>Same as [ID 2], except that the question text should contain \r somewhere in the middle. -odkmeta- should replace it with a space.</td>
</tr>
<tr>
	<td>7</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>.csv file</td>
	<td>Same as [ID 2], except that the question text should contain \r\n somewhere in the middle. -odkmeta- should replace it with a single space, not two.</td>
</tr>
<tr>
	<td>8</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a></td>
	<td>.csv file</td>
	<td>Same as [ID 2], except that the question text should contain a comma somewhere in the middle. This is a basic check of -odkmeta-'s .csv parsing.</td>
</tr>
<tr>
	<td>9</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a></td>
	<td>.csv file</td>
	<td>Same as [ID 2], except that the question text should contain a quote (") somewhere in the middle. This is a basic check of -odkmeta-'s .csv parsing.</td>
</tr>
<tr>
	<td>10</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a></td>
	<td>.csv file</td>
	<td>Same as [ID 2], except that the .csv files for the survey and choices sheets, as well as the .csv file for the ODK data, should all contain spaces in their filenames.</td>
</tr>
<tr>
	<td>11</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Attributes</td>
	<td>Same as [ID 2], except that one of the field attribute column headers should have at least one uppercase letter. However, the characteristic name for the attribute should still be all lowercase: that's the point of this test. The resulting dataset should be exactly the same as that of [ID 2].</td>
</tr>
<tr>
	<td>12</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a></td>
	<td>Lists</td>
	<td>Exactly one select_multiple field whose question text contains "$". After the -odkmeta- do-file completes, the "$" should be preserved in the variables labels and notes.</td>
</tr>
<tr>
	<td>19</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Basic</td>
	<td>Same as [ID 2], except use option -replace-. Run the command twice in the do-file to make sure the replacement has a chance to actually happen. The resulting dataset should be exactly the same as that of [ID 2].</td>
</tr>
<tr>
	<td>20</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a>, <a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Lists</td>
	<td>Exactly one select_one field with the following list:<br>name label<br>1 1<br>2 2<br>3 3<br>99 DK<br>All the labels equals the names except for one case (99 DK). Nonetheless, in the definition of the value label in the final dataset, all the associations should be defined. Defining 1 as 1 is redundant, on one hand, but it's part of the metadata, so it should appear in the value label. In a previous version of -odkmeta-, only 99 DK (the only one not redundant) was defined, and I want to make sure this isn't still happening. The data have instances for all possible values: 1, 2, 3, and 99 (DK).</td>
</tr>
<tr>
	<td>21</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a>, <a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Lists</td>
	<td>Same as [ID 20], except that in the list, 99 DK is removed: all the labels equal the names in all cases. Again, all the associations should be defined. Fringe cases like this is part of the motivation for keeping all associations in the value label. If we removed redundant associations, this value label simply wouldn't exist, which would be problematic.</td>
</tr>
<tr>
	<td>22</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a>, <a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Lists</td>
	<td>Exactly one select_one field with the following list:<br>name label<br>1 1<br>2 2<br>. Blank<br>This is a case of a string list in which "." is used as a name. (I've seen this used by projects in PocketSurvey. It's trouble!) Other names/labels are all numeric, but ./Blank is string. (By Blank, I really mean the string "Blank" -- I don't mean nothing/empty.) The resulting variable should be numeric and value labeled, and the value label text for ./Blank should be "Blank". The value label value should be 3. It's important that the example data have cases of ./Blank.</td>
</tr>
<tr>
	<td>23</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a>, <a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Lists</td>
	<td>Exactly one select_one field with the following list:<br>name label<br>1 1<br>2 2<br>.a .a<br>This looks like an extended missing value, but that isn't a concept in ODK, so the resulting variable should be treated like a "string list": the variable should be numeric and value labeled, and the value label value for .a should be 3. It's important for the example data to have cases of .a.</td>
</tr>
<tr>
	<td>24</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Attributes</td>
	<td>In the survey sheet, have one attribute (column) named "_all". This is a tough case given the -keepattrib()- and -dropattrib()- options, but the resulting characteristic name should be Odk_all. In a previous version of -odkmeta-, it was Odk_all1, and I want to make sure that isn't happening anymore.</td>
</tr>
<tr>
	<td>25</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Attributes</td>
	<td>In the survey sheet, have attributes (columns) named: bad_name, group, long_name, repeat, list_name, or_other, and is_other. These are reserved characteristic names, so the resulting characteristics for these attributes should be named Odk_group1 (with the suffix 1), Odk_full_name1, etc.</td>
</tr>
<tr>
	<td>27</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a></td>
	<td>.csv file</td>
	<td>Have only two fields, one named ab and the other named a#b. The problem is that Stata will try to -insheet- a#b as ab. The resulting dataset should have ab named ab and a#b named some v# variable, but everything else should be correct: a#b should have a variable label, notes, all the characteristics, and so on. The other thing that should be wrong is the variable name, which -odkmeta- can't really resolve.</td>
</tr>
<tr>
	<td>28</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a></td>
	<td>.csv file</td>
	<td>Same as [ID 27], except let's see what happens when we add fields named v1 v2 v3 v4 v5 v6 v7 v8 v9 (after a#b). The variable name for a#b should be the same as in [ID 27], and v1-v9 should all have the correct names, except one of them should be wrong, because a#b's v# name will displace it. So the variable names might get weird, but everything else should be alright.</td>
</tr>
<tr>
	<td>29</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a></td>
	<td>.csv file</td>
	<td>Have only one field named thisisaveryveryveryunreasonablylongfieldname. It's OK as an ODK field name, but too long for a Stata name. When imported to Stata, its name should be truncated to thisisaveryveryveryunreasonablyl, but otherwise everything else should be OK.</td>
</tr>
<tr>
	<td>32</td>
	<td>NA</td>
	<td>Basic</td>
	<td>The survey sheet has multiple rows, but the choices sheet has only the headers row. (Tested by [ID 2]. Don't implement.)</td>
</tr>
<tr>
	<td>33</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>The survey sheet has only the header row. The choices sheet has only the headers row. We have headers but literally nothing else, including no data.</td>
</tr>
<tr>
	<td>34</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Same as [ID 36], but the survey sheet has only the headers row.</td>
</tr>
<tr>
	<td>35</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Same as [ID 36], but the survey sheet is completely blank.</td>
</tr>
<tr>
	<td>36</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a></td>
	<td>Lists</td>
	<td>Exactly one select_one field with the following list:<br>name label<br>1 A<br>2 B<br>3 C</td>
</tr>
<tr>
	<td>37</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Same as [ID 2], but the choices sheet is completely blank.</td>
</tr>
<tr>
	<td>38</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>The survey sheet has only the headers row. The choices sheet is completely blank.</td>
</tr>
<tr>
	<td>39</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Both the survey and choices sheets are completely blank.</td>
</tr>
<tr>
	<td>40</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>The choices sheet has only the headers row. The survey sheet is completely blank.</td>
</tr>
<tr>
	<td>41</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Lists</td>
	<td>Same as [ID 36], but use option -oneline- and check that the do-file has no #delimit or semicolons.</td>
</tr>
<tr>
	<td>42</td>
	<td>NA</td>
	<td>Lists</td>
	<td>A select_multiple field with all missing values. It should still be split. (Tested by [ID 1]. Don't implement.)</td>
</tr>
<tr>
	<td>43</td>
	<td>NA</td>
	<td>Lists</td>
	<td>A select_multiple field with at least one nonmissing value. It should be split. (Tested by [ID 1]. Don't implement.)</td>
</tr>
<tr>
	<td>44</td>
	<td>NA</td>
	<td>Lists</td>
	<td>Test select_one or_other. (Tested by [ID 1]. Don't implement.)</td>
</tr>
<tr>
	<td>45</td>
	<td>NA</td>
	<td>Lists</td>
	<td>Test select_multiple or_other. (Tested by [ID 1]. Don't implement.)</td>
</tr>
<tr>
	<td>46</td>
	<td>NA</td>
	<td>Lists</td>
	<td>Define a "value label" list as an ODK list that looks like a Stata value label: names are integer, and labels are strings; it's an integer-to-text correspondence. Test a form with more than one value label list. (Tested by [ID 1]. Don't implement.)</td>
</tr>
<tr>
	<td>47</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a>, <a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Lists</td>
	<td>Define a "string list" as an ODK list for which one or more names are noninteger. For example, a list with name=NewHaven (no space), label="New Haven" (with space) would be an example of a string list. Test a form with exactly two fields and two lists, both of which are string lists. Let's say the fields are X and Y and the lists are A and B (you can change these in the form). Make X a select_one A and Y a select_one B. I want to test a form with multiple string lists.</td>
</tr>
<tr>
	<td>48</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Basic</td>
	<td>Same as [ID 1], but the order of the columns is reversed in both survey and choices sheets. The resulting dataset should be exactly the same.</td>
</tr>
<tr>
	<td>49</td>
	<td>NA</td>
	<td>Lists</td>
	<td>A form with a list that we'll call A. Field X is select_multiple A. Field Y is select_multiple A or_other. The number of split variables of X should be one less than the number for Y. (This is where `noother' comes in in the -odkmeta- do-file.) (Tested by [ID 1]. Don't implement.)</td>
</tr>
<tr>
	<td>50</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a>, <a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Field types</td>
	<td>A simple form that contains at least the following three fields. A field of date type. A field of time type. A field of today type. [ID 1] already checks types start, end, and datetime.</td>
</tr>
<tr>
	<td>51</td>
	<td>NA</td>
	<td>Field types</td>
	<td>A simple form that contains at least the following three types. A field of acknowledge type. A field of barcode type. A field of calculate type. Together with [ID 1] and [ID 50], this tests all possible field types. (Combined with [ID 50].)</td>
</tr>
<tr>
	<td>52</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Basic</td>
	<td>Same as [ID 1], but in the survey sheet, rename the type, name, label, and disabled attribute column headers, and in the choices sheet, rename the list_name, name, and label attribute column headers; then use the -survey()- and -choices()- suboptions to specify the new names to -odkmeta-.</td>
</tr>
<tr>
	<td>53</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Same as [ID 1], but misspecify the column header of the type field attribute using -survey(, type())-: specify Type instead of type. Column headers are case-sensitive.</td>
</tr>
<tr>
	<td>54</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Basic</td>
	<td>Same as [ID 2], but the .csv file has no data (but it has the headers row).</td>
</tr>
<tr>
	<td>55</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Same as [ID 2], but the .csv file is completely blank.</td>
</tr>
<tr>
	<td>56</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a></td>
	<td>Lists</td>
	<td>Same as [ID 36], but make the field select_one or_other. There should be instances of "other" in the data.</td>
</tr>
<tr>
	<td>57</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Lists</td>
	<td>Same as [ID 56], but specify option -other(max)-. The result should be the same as that of [ID 56].</td>
</tr>
<tr>
	<td>58</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Lists</td>
	<td>Same as [ID 56], but specify option -other(min)-.</td>
</tr>
<tr>
	<td>59</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Lists</td>
	<td>Same as [ID 56], but specify option -other(99)-.</td>
</tr>
<tr>
	<td>60</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Lists</td>
	<td>Same as [ID 56], but specify option -other(.o)-. .o is a particularly hard value for -other()-, since it's used internally in the do-file, but it should still succeed.</td>
</tr>
<tr>
	<td>61</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Same as [ID 36], but make the list name not a Stata name: include an embedded space. (Only change the choices sheet.)</td>
</tr>
<tr>
	<td>62</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Same as [ID 36], but make the list name not a Stata name: include a double quote somewhere in the middle. (Only change the choices sheet.)</td>
</tr>
<tr>
	<td>63</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Same as [ID 36], but make the list name not a Stata name: include a leading number. (Only change the choices sheet.)</td>
</tr>
<tr>
	<td>64</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Same as [ID 36], but make the list name not a Stata name: include a left single quote somewhere in the middle. (Only change the choices sheet.)</td>
</tr>
<tr>
	<td>65</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Same as [ID 36], but make the list name after select_one in the survey sheet not a Stata name: include an embedded space. Don't change the choices sheet.</td>
</tr>
<tr>
	<td>66</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Same as [ID 36], but make the list name after select_one in the survey sheet not a Stata name: include a double quote somewhere in the middle. Don't change the choices sheet.</td>
</tr>
<tr>
	<td>67</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Same as [ID 36], but make the list name after select_one in the survey sheet not a Stata name: include a leading number. Don't change the choices sheet.</td>
</tr>
<tr>
	<td>68</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Same as [ID 36], but make the list name after select_one in the survey sheet not a Stata name: include a left single quote somewhere in the middle. Don't change the choices sheet.</td>
</tr>
<tr>
	<td>71</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Basic</td>
	<td>Same as [ID 2], but don't specify the .do extension in the -using- qualifier. -odkmeta- should still create a do-file.</td>
</tr>
<tr>
	<td>72</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a>, <a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Lists</td>
	<td>Exactly one select_one field with the following list (the order of the rows matters):<br>name label<br>3 3<br>2 2<br>1 1<br>DK DK<br>The name "DK" is a string value, so the list is treated as a "string list." The resulting variable should be numeric and value labeled with the following value label:<br>1 3<br>2 2<br>3 1<br>4 DK<br>That is, the first value of the list (3) is given the value label TEXT of 3, but it's value is really 1. You can use -label list- or -browse, nolabel- to confirm this.</td>
</tr>
<tr>
	<td>73</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Basic</td>
	<td>Same as [ID 2], but don't specify the .csv extensions in -csv()-, -survey()-, or -choices()-. It shouldn't matter: the result should be the same as [ID 2].</td>
</tr>
<tr>
	<td>74</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td><code>relax</code></td>
	<td>Test of -relax-. Same as [ID 2], but add a field to the survey sheet that doesn't exist. The result should be the same as that of [ID 2].</td>
</tr>
<tr>
	<td>75</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Basic</td>
	<td>Same as [ID 2], but the .csv filenames specified to -csv()-, -survey()-, and -choices()- are enclosed by double quotes.</td>
</tr>
<tr>
	<td>76</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Basic</td>
	<td>Same as [ID 52], but the .csv filenames specified to -csv()-, -survey()-, and -choices()- are enclosed by double quotes.</td>
</tr>
<tr>
	<td>77</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Basic</td>
	<td>Same as [ID 2], but the type field attribute is named t`ype with the left single quote. (This test fails, but I think that's OK. It'd take significant rewriting to fix it.)</td>
</tr>
<tr>
	<td>80</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>.csv file</td>
	<td>Similar to [ID 27]. Have exactly three fields, one named ab, one named a#b, and one named a^b (if # and ^ don't work, choose any two distinct symbols other than - or _). The problem is that Stata will try to -insheet- a#b and a^b as ab. The resulting dataset should have ab named ab; a#b and a^b named some v# variable; but everything else correct: a#b and a^b should have variable labels, notes, all the characteristics, and so on. The only thing that should be wrong is the variable names, which -odkmeta- can't really resolve. LS: updated to ab, a.b and a..b, because the only characters allowed are letter, number, underscore, dash, period</td>
</tr>
<tr>
	<td>81</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td><code>relax</code></td>
	<td>Same as [ID 28], but add a field that doesn't exist and use option -relax-. I want to test the interaction of `namevars' and -relax-.</td>
</tr>
<tr>
	<td>82</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Same as [ID 36], but the choices sheet is missing. The do-file should result in an error.</td>
</tr>
<tr>
	<td>83</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Lists</td>
	<td>Same as [ID 36], but the choices sheet contains an extra, unused list. The result should be the same as [ID 36].</td>
</tr>
<tr>
	<td>84</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>.csv file</td>
	<td>A form with two fields named ab and a.b. Stata will give a.b some v# name. Also include in the forms five fields named v1-v5. Normally they would conflict with a.b's v# name, but put them in a group. There should be no conflict, and these v# fields in the group should import completely correctly, even their variable names.</td>
</tr>
<tr>
	<td>85</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>.csv file</td>
	<td>Same as [ID 2], except that the field is named v1. This is a v# name, but it is unproblematic, so there should be no use of `fields'.</td>
</tr>
<tr>
	<td>86</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>.csv file</td>
	<td>Have a geopoint field with a v# name. Before the field, have a number of fields whose names don't -insheet- well, such that one of the fields will get the same v# name as the geopoint field. Since the geopoint variable names have suffixes, the geopoint field should be completely unaffected.</td>
</tr>
<tr>
	<td>87</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Lists</td>
	<td>Same as [ID 21], but make replace 1 as A in the name and label, 2 as B, and 3 as C: I want to test a string list such that all names equal all labels.</td>
</tr>
<tr>
	<td>89</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Basic</td>
	<td>Same as [ID 2], but the question text is blank.</td>
</tr>
<tr>
	<td>90</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Basic</td>
	<td>Same as [ID 2], but the question text should be longer than 80 characters.</td>
</tr>
<tr>
	<td>91</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>.csv file</td>
	<td>Let's test duplicate column headers in the survey sheet. Have two attributes with the same name (e.g., hint). Only the first should be imported. Have two attributes with the same name such that the name is "reserved" (e.g., label, type, name, etc.). Only the first should be imported. Have two attributes with different names but with similar enough names that their characteristic names would be the same (e.g., constraint_message vs. "constraint message"). Both should be imported. Have an attribute whose name is not reserved but whose characteristic name would be that of a reserved name, e.g., "long name" becomes long_name. This attribute should still be imported. The rule is: duplicate headers are ignored, but duplicate characteristic names shouldn't mess us up.</td>
</tr>
<tr>
	<td>92</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Lists</td>
	<td>Exactly one field, a select_one or_other with a string list (at least one name is noninteger). It's important that there are instances of other and of not other in the data</td>
</tr>
<tr>
	<td>93</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Lists</td>
	<td>Exactly one field, a select_multiple (not or_other) with a string list (at least one name is noninteger).</td>
</tr>
<tr>
	<td>94</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Lists</td>
	<td>Exactly one field, a select_multiple or_other with a string list (at least one name is noninteger). It's important that there are instances of other and of not other in the data</td>
</tr>
<tr>
	<td>96</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Basic</td>
	<td>Same as [ID 1], but the disabled attribute of the disabled field is "yes " with a space instead of "yes". The result should be the same as [ID 1].</td>
</tr>
<tr>
	<td>98</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Groups and repeats</td>
	<td>Same as [ID 84], but "begin group" is replaced with begin_group, and "end group" is replaced with end_group. The result should be the same as [ID 84].</td>
</tr>
<tr>
	<td>101</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Attributes</td>
	<td>Similar to [ID 25]. In the survey sheet, have an attribute (column) named geopoint. This is a reserved characteristic name, so the resulting characteristic for this attribute should be named Odk_geopoint1 (with the suffix 1).</td>
</tr>
<tr>
	<td>102</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Field types</td>
	<td>[ID 99] initially failed because a datetime field had all missing values. For this one, create a form with fields of these types: date datetime end geopoint note "select_one list" "select_one list or_other" "select_multiple list" "select_multiple list or_other" start time today. In the data itself, have one observation with all missing values for these variables: the cells should be completely blank. Don't worry about other field types, which don't have special code in the do-file, so shouldn't have any potential issues with missing values.</td>
</tr>
<tr>
	<td>103</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>.csv file</td>
	<td>Let's test fields that result in multiple variables (those of type geopoint or select or_other) whose names are long enough that the variable suffix is truncated but not so long that there are duplicates. Let's have a form with exactly six fields:<br>1. geopoint field whose name is exactly 30 characters long. Latitude and Longitude will be truncated to La and Lo, but there still won't be duplicate variable names. We'll see the use of `varsuf'.<br>2. geopoint field whose name is exactly 31 characters long. Latitude and Longitude will be truncated to L and L, so there will be duplicates. We'll see the use of `pos' and `fields' but not `varsuf'.<br>3. select_one or_other field whose name is exactly 31 characters long. _other will be truncated to "_", but there still won't be duplicate variable names. We'll see the use of `varsuf'.<br>4. select_one or_other field whose name is exactly 32 characters long. _other will be truncated completely, so there will be duplicates. We'll see the use of `pos' and `fields'.<br>5. select_multiple or_other field whose name is exactly 31 characters long. _other will be truncated to "_", but there still won't be duplicate variable names. We'll see the use of `varsuf'.<br>6. select_multiple or_other field whose name is exactly 32 characters long. _other will be truncated completely, so there will be duplicates. We'll see the use of `pos' and `fields'.<br>This test also tests multivariable fields with variables whose Stata names would be duplicates with other variables of the same field.</td>
</tr>
<tr>
	<td>104</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>.csv file</td>
	<td>Similar to [ID 103], but let's test easier cases of multivariable fields with un-insheetable variable names. Have three multivariable fields: one geopoint, one select_one or_other, and one select_multiple or_other. Then have three corresponding integer fields whose names will result in the duplicates. For example, you could have a geopoint field named mygeo and an integer field named mygeoLatitude or "mygeo.Latitude". The two fields have different field names, but one of the variables associated with mygeo (mygeo-Latitude) will have a Stata name that conflicts with that of mygeoLatitude. For this conflict to occur, have the integer come before the multivariable field: here, mygeoLatitude should come before mygeo. For the select or_other fields, it doesn't matter whether the corresponding integer conflicts with the select variable or the "other" variable. For example, if you have a select_one or_other field named myselect, the integer could be named "my.select" (producing a conflict with the select variable) or "my.select_other" (producing a conflict with the "other" variable).</td>
</tr>
<tr>
	<td>106</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Lists</td>
	<td>A form with a select_one field (X) that's preceded by another field (Y). X's list should have names that are all integer. 1=dog 2=cat, and so on. There's a skip pattern such that X is asked only for some values of Y. In the data, there should be missing and nonmissing values of X: I want to test that the missing values stay missing in the import. This sounds like a pretty simple test, but I just fixed it!</td>
</tr>
<tr>
	<td>107</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Lists</td>
	<td>Exactly one select_one field with the following list:<br>name label<br>1 1<br>1.5 1.5<br>2 2<br>I want to test lists with names that are all numeric but not all integer. Previously these were imported as value labels, but they should be imported as string lists.</td>
</tr>
<tr>
	<td>108</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Basic</td>
	<td>Same as [ID 2], but the .csv filenames specified to -csv()-, -survey()-, and -choices()- contain embedded spaces. They should be enclosed by double quotes.</td>
</tr>
<tr>
	<td>109</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Basic</td>
	<td>Same as [ID 2], but the .csv filenames specified to -csv()-, -survey()-, and -choices()- contain embedded spaces. They should not be enclosed by double quotes.</td>
</tr>
<tr>
	<td>110</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Groups and repeats</td>
	<td>A form that looks like this:<br>type name<br>whatever A<br>begin group G<br>whatever B<br>end group G<br>whatever C<br>(Feel free to change any of the names.) I want to test just about the simplest possible form with a group.</td>
</tr>
<tr>
	<td>111</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Groups and repeats</td>
	<td>A form that looks like this:<br>type name<br>whatever A<br>begin repeat R<br>whatever B<br>end repeat R<br>whatever C<br>(Feel free to change any of the names.) I want to test just about the simplest possible form with a repeat group.</td>
</tr>
<tr>
	<td>112</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Groups and repeats</td>
	<td>Let's test nested groups:<br>type name<br>begin group G1<br>whatever A<br>begin group G2<br>whatever B<br>end group G2<br>end group G1</td>
</tr>
<tr>
	<td>113</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Groups and repeats</td>
	<td>Let's test nested repeat groups. This isn't exactly parallel to [ID 112]: the parent repeat group contains two child repeat groups.<br>type name<br>whatever A<br>begin repeat R1<br>whatever B<br>begin repeat R2<br>whatever C<br>end repeat R2<br>begin repeat R3<br>whatever D<br>end repeat R3<br>end repeat R1</td>
</tr>
<tr>
	<td>114</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Groups and repeats</td>
	<td>Same as [ID 111], but there should be absolutely no repeat instances. The repeat group .csv file should be totally, completely blank other than the column names row.</td>
</tr>
<tr>
	<td>115</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Groups and repeats</td>
	<td>Let's now try groups and repeat groups interacting with each other. We'll have a form in which a repeat group is inside a group and a group is inside a repeat group:<br>type name<br>whatever A<br>begin group G1<br>whatever B<br>begin repeat R1<br>whatever C<br>begin group G2<br>whatever D<br>end group G2<br>end repeat R1<br>end group G1</td>
</tr>
<tr>
	<td>116</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Groups and repeats</td>
	<td>(DON'T MAKE A FORM FOR THIS. Matt will modify [ID 2].) Let's try immediately successive/nested groups. These are supposed to look a certain way in the -odkmeta- do-file.<br>type name<br>begin group G1<br>begin group G2<br>whatever A<br>end group G2<br>end group G1</td>
</tr>
<tr>
	<td>117</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Groups and repeats</td>
	<td>Let's test "begin group" immediately following "end group":<br>type name<br>begin group G1<br>whatever A<br>end group G1<br>begin group G2<br>whatever B<br>end group G2</td>
</tr>
<tr>
	<td>118</td>
	<td>NA</td>
	<td>Groups and repeats</td>
	<td>(Don't implement this; tested by [ID 113].) Let's test "begin repeat" immediately following "end repeat":<br>type name<br>whatever A<br>begin repeat R1<br>whatever B<br>end repeat R1<br>begin repeat R2<br>whatever C<br>end repeat R2</td>
</tr>
<tr>
	<td>119</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Duplicate repeat group names, where the repeat groups are outside groups</td>
</tr>
<tr>
	<td>120</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Duplicate repeat group names, where the repeat groups are inside groups</td>
</tr>
<tr>
	<td>121</td>
	<td>NA</td>
	<td><code>relax</code></td>
	<td>(Don't implement: same as [ID 183].) Let's test -relax- with repeat groups. There should be exactly one field that doesn't exist, within a repeat group. Check the resulting warning message -- it should mention the repeat group name.</td>
</tr>
<tr>
	<td>122</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td><code>relax</code></td>
	<td>Let's test -relax- with repeat groups. There should be exactly two fields that don't exist, within a repeat group; there should also be exactly one other field that doesn't exist, outside a repeat group. Check the resulting warning messages -- they should mention the repeat group name where relevant.</td>
</tr>
<tr>
	<td>123</td>
	<td>NA</td>
	<td>Groups and repeats</td>
	<td>Let's test repeat groups with the same short name but different full names:<br>type name<br>whatever A<br>begin group G1<br>begin repeat duplicate_name<br>whatever B<br>end repeat duplicate_name<br>end group G1<br>begin group G2<br>begin repeat duplicate_name<br>whatever C<br>end repeat duplicate_name<br>end group G2<br>(Note from Lindsey: this form is not allowed. Repeat groups must have different short names AND different long names.)</td>
</tr>
<tr>
	<td>124</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Groups and repeats</td>
	<td>Randomly generate some number of group/repeat group arrangements, valid or otherwise, then send them to -odkmeta- and see how it responds. No need to check the data -- let's just check its basic response.</td>
</tr>
<tr>
	<td>137</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Lists</td>
	<td>Same as [ID 92], but the list is ordered reverse alphabetically according to name in the choices sheet (in [ID 92], it is ordered alphabetically). The values of the value label should reflect the order of the values in the choices sheet, not the alphabetical order.</td>
</tr>
<tr>
	<td>138</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Lists</td>
	<td>Same as [ID 36], but the type is "select one" instead of select_one. The result should be the same as [ID 36].</td>
</tr>
<tr>
	<td>139</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Lists</td>
	<td>Same as [ID 1], but use "select_one or other" and "select_multiple or other". The result should be the same as [ID 1].</td>
</tr>
<tr>
	<td>140</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Lists</td>
	<td>Same as [ID 1], but use "select one or other". The result should be the same as [ID 1].</td>
</tr>
<tr>
	<td>141</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a>, <a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Field types</td>
	<td>Same as [ID 1], but make date values in the data DMY instead of MDY; time values hm instead of hms; and datetime values DMYhms instead of MDYhms. This will test the `datemask', `timemask', and `datetimemask' locals at the top of the do-file.</td>
</tr>
<tr>
	<td>142</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a>, <a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Lists</td>
	<td>Same as [ID 93], except the field name ends in a number. Before the select_multiple variable is split, -odkmeta- will add an underscore to the variable name (otherwise it'd be a mess of numbers at the end).</td>
</tr>
<tr>
	<td>143</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a></td>
	<td>Lists</td>
	<td>Same as [ID 142], but with the following twist. Let's say the single field in [ID 142] was named favfruit1. The do-file would want to rename the variable to favfruit1_ before splitting. Except... Let's add an integer field to the form named favfruit1_, the name that the select_multiple variable favfruit1 would be renamed to. The do-file should now not try to add the underscore to favfruit1.</td>
</tr>
<tr>
	<td>144</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a></td>
	<td>Lists</td>
	<td>Same as [ID 143], except favfruit1_ is named favfruit1_1. The idea is that favfruit1 can be split as-is, but while it can be renamed to favfruit1_, it can't be split after that rename -- therefore it shouldn't be renamed at all and should just be split as-is even though it'll result in messiness. This was actually a problem with an IPA project's data!</td>
</tr>
<tr>
	<td>145</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Field types</td>
	<td>I realized that [ID 1] only has datetime values, so [ID 141] isn't as full a test as I meant it to be. This test will be the same as [ID 50], but make date values in the data DMY instead of MDY; time values hm instead of hms; and datetime values DMYhms instead of MDYhms. This will test the `datemask', `timemask', and `datetimemask' locals at the top of the do-file.</td>
</tr>
<tr>
	<td>146</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Groups and repeats</td>
	<td>Exactly the same as [ID 113], including the same data, but don't reshape and merge: check the unmerged .dta files.</td>
</tr>
<tr>
	<td>147</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Groups and repeats</td>
	<td>Exactly the same as [ID 115], including the same data, but don't reshape and merge: check the unmerged .dta files.</td>
</tr>
<tr>
	<td>148</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>.csv file</td>
	<td>Same as [ID 1], but the .csv filename contains a period in its base name, i.e., a period other than the one in ".csv".</td>
</tr>
<tr>
	<td>149</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Check that this form results in an error:<br>type name<br>begin repeat A<br>whatever F1<br>begin repeat B<br>whatever F2<br>end repeat B<br>end repeat A<br>begin repeat C<br>whatever F3<br>begin repeat B<br>whatever F4<br>end repeat B<br>end repeat C</td>
</tr>
<tr>
	<td>150</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Duplicate group names, where the groups are outside other groups</td>
</tr>
<tr>
	<td>151</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Duplicate group names, where the groups are inside other groups</td>
</tr>
<tr>
	<td>152</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Same as [ID 110], except that group G contains a "void group" that contains no fields. The form should look like this:<br>type name<br>whatever A<br>begin group G<br>begin group void_group<br>end group void_group<br>whatever B<br>end group G<br>whatever C</td>
</tr>
<tr>
	<td>153</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Same as [ID 111], except that repeat group R contains a "void repeat group" that contains no field. See [ID 152].</td>
</tr>
<tr>
	<td>154</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Same as [ID 110], except that there is no field C and there is no "end group".</td>
</tr>
<tr>
	<td>155</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Same as [ID 111], except that there is no field C and there is no "end repeat".</td>
</tr>
<tr>
	<td>156</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>A form with one disabled field</td>
</tr>
<tr>
	<td>157</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Basic</td>
	<td>A form with a single field -- no groups or repeats -- whose name is exactly 234 characters long.</td>
</tr>
<tr>
	<td>158</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>A form with a single field whose name is exactly 235 characters long.</td>
</tr>
<tr>
	<td>159</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>A form with a single field in a repeat group whose name is exactly 235 characters long.</td>
</tr>
<tr>
	<td>160</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>A form with a single field in a group whose long name when converted to a Stata variable name is KEY.</td>
</tr>
<tr>
	<td>161</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>A form with a single field in a group whose long name when converted to a Stata variable name is PARENT_KEY.</td>
</tr>
<tr>
	<td>162</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Groups and repeats</td>
	<td>A form that looks like this:<br>type name<br>integer SETOFmyrepeat<br>begin repeat myrepeat<br>whatever X<br>end repeat myrepeat<br>The idea is that SETOFmyrepeat will have a duplicate Stata (but not ODK) name with the SET-OF field of repeat group myrepeat.</td>
</tr>
<tr>
	<td>163</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a></td>
	<td>Groups and repeats</td>
	<td>A form that looks like this:<br>type name<br>begin repeat myrepeat<br>integer SETOFmyrepeat<br>end repeat myrepeat<br>Same as [ID 162], except that SETOFmyrepeat is in the repeat group instead of among the main fields, and X has been dropped.</td>
</tr>
<tr>
	<td>164</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Groups and repeats</td>
	<td>Same as [ID 111], except there are no instances (of the main fields or of the repeat group).</td>
</tr>
<tr>
	<td>165</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a></td>
	<td>Groups and repeats</td>
	<td>A form that looks like this:<br>type name<br>integer A<br>begin repeat R<br>integer B1<br>end repeat R<br>Feel free to change any of the field names, but it's important that B1 (the one field in the repeat group) have a field name that ends with a number.</td>
</tr>
<tr>
	<td>166</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a></td>
	<td>Groups and repeats</td>
	<td>A form that looks like this:<br>type name<br>integer A<br>begin repeat R<br>integer B1<br>integer B1_<br>end repeat R<br>Feel free to change any of the field names, but it's important that B1 (the one field in the repeat group) have a field name that ends with a number and that the field name of B1_ be the same as B1's exact that it has a trailing underscore.</td>
</tr>
<tr>
	<td>167</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a></td>
	<td>Groups and repeats</td>
	<td>A form that looks like this:<br>type name<br>integer SETOFmyrepeat<br>begin repeat myrepeat<br>integer SETOFmyrepeat<br>end repeat myrepeat<br>It's sort of a combination of [ID 162] and [ID 163]: the field names of both parent and child SET-OF fields will be un-insheetable.</td>
</tr>
<tr>
	<td>168</td>
	<td>NA</td>
	<td>Basic</td>
	<td>(Don't implement: implemented by [ID 36].) Have a field in the data that's not in the form other than SubmissionDate KEY PARENT_KEY metainstanceID. Check the warning messages using -get_warnings-. For this test, there should be only one warning message: we'll test all the warning messages at once in a later test.</td>
</tr>
<tr>
	<td>169</td>
	<td>NA</td>
	<td>Basic</td>
	<td>(Implemented by [ID 2].) Get that [ID 2] produces no warning messages.</td>
</tr>
<tr>
	<td>170</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td><code>relax</code></td>
	<td>Same as [ID 81], but have there be a field in the data not in the form. For example, rename SubmissionDate as _submission_time. I want to test all three warnings at the same time.</td>
</tr>
<tr>
	<td>171</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td><code>dropattrib()</code></td>
	<td>Same as [ID 1], but drop the attributes type and "constraint message". Also try dropping the attribute constraint_message just to see what happens -- there should be a warning.</td>
</tr>
<tr>
	<td>172</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td><code>dropattrib()</code></td>
	<td>Same as [ID 1], but specify -dropattrib(_all)-.</td>
</tr>
<tr>
	<td>173</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td><code>dropattrib()</code></td>
	<td>Same as [ID 172], but also specify attribute "type" to -dropattrib()-. The result should be the same as [ID 172].</td>
</tr>
<tr>
	<td>174</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td><code>dropattrib()</code></td>
	<td>Same as [ID 1], but keep the attributes type and "constraint message". Also try keeping the attribute constraint_message just to see what happens -- there should be a warning.</td>
</tr>
<tr>
	<td>175</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td><code>dropattrib()</code></td>
	<td>Same as [ID 1], but specify -keepattrib(_all)-. The result should be the same as [ID 1].</td>
</tr>
<tr>
	<td>176</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td><code>dropattrib()</code></td>
	<td>Same as [ID 1], but specify -keepattrib(_all type)-. The result should be the same as [ID 1].</td>
</tr>
<tr>
	<td>177</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>User tries to specify both -keepattrib()- and -dropattrib()-</td>
</tr>
<tr>
	<td>178</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td><code>dropattrib()</code></td>
	<td>Same as [ID 111], but specify -dropattrib(type)-.</td>
</tr>
<tr>
	<td>179</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td><code>dropattrib()</code></td>
	<td>Same as [ID 111], but specify -dropattrib(_all)-.</td>
</tr>
<tr>
	<td>180</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td><code>dropattrib()</code></td>
	<td>Same as [ID 111], but specify -keepattrib(type)-.</td>
</tr>
<tr>
	<td>181</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td><code>dropattrib()</code></td>
	<td>Same as [ID 111], but specify -keepattrib(_all)-.</td>
</tr>
<tr>
	<td>182</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td><code>relax</code></td>
	<td>Same as [170], but specify -dropattrib(_all)-. I want to test the interaction between -dropattrib()- and -relax-.</td>
</tr>
<tr>
	<td>183</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td><code>relax</code></td>
	<td>A form that looks like this:<br>type name<br>whatever A<br>begin repeat R<br>whatever B<br>whatever DoesntExist<br>end repeat R<br>whatever C<br>Where DoesntExist doesn't exist in the data. I want to test the interaction between -relax- and repeat groups.</td>
</tr>
<tr>
	<td>184</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Groups and repeats</td>
	<td>Add a field to [ID 111] that exists in the data (importantly: in the repeat group) but not the form. I want to test the warning message for datanotform for fields in repeat groups.</td>
</tr>
<tr>
	<td>185</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Check error message when -specialexp()- is not installed.</td>
</tr>
<tr>
	<td>186</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Same as [ID 36], but specify -other(junk)-.</td>
</tr>
<tr>
	<td>187</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Run the same -odkmeta- command twice without specifying -replace-.</td>
</tr>
<tr>
	<td>188</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Specify a nonexistent column header to -survey, type())-.</td>
</tr>
<tr>
	<td>189</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Make all the fields disabled.</td>
</tr>
<tr>
	<td>190</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Test a bad repeat group merge such that there is no overlap between the variable lists in two datasets (see local `overlap').</td>
</tr>
<tr>
	<td>191</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td><code>specialexp()</code></td>
	<td>Same as [ID 21], but make a value name of a list \`'.</td>
</tr>
<tr>
	<td>192</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td><code>specialexp()</code></td>
	<td>Same as [ID 21], but make a value label of a list \`'.</td>
</tr>
<tr>
	<td>193</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td><code>specialexp()</code></td>
	<td>Same as [ID 21], but make the hint attribute of varname be \`'.</td>
</tr>
<tr>
	<td>194</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td><code>specialexp()</code></td>
	<td>Same as [ID 21], but for a value of a list, make both name and label \`'.</td>
</tr>
<tr>
	<td>195</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td><code>specialexp()</code></td>
	<td>Same as [ID 21], but make the label attribute of varname be \`'.</td>
</tr>
<tr>
	<td>196</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td><code>specialexp()</code></td>
	<td>Same as [ID 12], but make the hint attribute be \`'.</td>
</tr>
<tr>
	<td>197</td>
	<td><a href="https://github.com/internetlindsey">internetlindsey</a></td>
	<td>Lists</td>
	<td>A single select_one field with the following list:<br>name label<br>1 1<br>01 01<br>001 001</td>
</tr>
<tr>
	<td>198</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>The user does not specify -using-.</td>
</tr>
<tr>
	<td>199</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Basic</td>
	<td>Same as [ID 1], but the column header of the hint attribute is un-insheetable, so -load_csv()- gives it a v# variable name; but that name is used by another column.</td>
</tr>
<tr>
	<td>200</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Invalid name attribute in the survey sheet: a name is more than one word.</td>
</tr>
<tr>
	<td>201</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Same as [ID 36], but a name in the choices sheet is missing.</td>
</tr>
<tr>
	<td>202</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>Same as [ID 36], but a label in the choices sheet is missing.</td>
</tr>
<tr>
	<td>203</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Groups and repeats</td>
	<td>Same as [ID 84], but rename fields v1-v5 as 1-5, and rename the group in which they are nested as v. Then v-3 will conflict with the Stata name of a.b, which is v3, since a.b conflicts with ab.</td>
</tr>
<tr>
	<td>204</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>The survey worksheet is a single field followed by a "begin group" row. (There is no "end group" row.)</td>
</tr>
<tr>
	<td>205</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>The survey worksheet is a "begin group" row without an "end group"; there are no fields.</td>
</tr>
<tr>
	<td>206</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>The survey worksheet is a single field followed by a "begin repeat" row. (There is no "end repeat" row.)</td>
</tr>
<tr>
	<td>207</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>User mistakes</td>
	<td>The survey worksheet is a "begin repeat" row without an "end repeat"; there are no fields.</td>
</tr>
<tr>
	<td>208</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Basic</td>
	<td>Same as [ID 2], but there is a nonblank disabled attribute not equal to "blank".</td>
</tr>
<tr>
	<td>209</td>
	<td><a href="https://github.com/matthew-white">matthew-white</a></td>
	<td>Groups and repeats</td>
	<td>A form that looks like this:<br>type name<br>integer SETOFmygroupmyrepeat<br>begin group mygroup<br>begin repeat myrepeat<br>integer SETOFmyrepeat<br>end repeat myrepeat<br>end group mygroup</td>
</tr>
</table>
