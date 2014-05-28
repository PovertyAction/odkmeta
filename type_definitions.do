vers 11.2

loc RS	real scalar
loc RR	real rowvector
loc RC	real colvector
loc RM	real matrix
loc SS	string scalar
loc SR	string rowvector
loc SC	string colvector
loc SM	string matrix
loc TS	transmorphic scalar
loc TR	transmorphic rowvector
loc TC	transmorphic colvector
loc TM	transmorphic matrix

* Convert real x to string using -strofreal(x, `RealFormat')-.
loc RealFormat	""%24.0g""

* Names of locals specified by the user at the start of the do-file
loc DateMask		""datemask""
loc TimeMask		""timemask""
loc DatetimeMask	""datetimemask""

loc InsheetCode		real
loc InsheetCodeS	`InsheetCode' scalar
loc InsheetOK		0
loc InsheetBad		1
loc InsheetDup		2
loc InsheetV		3

loc DoFileWriter	do_file_writer
loc DoFileWriterS	class `DoFileWriter' scalar

loc AttribProps		odk_attrib_props
loc AttribPropsS	struct `AttribProps' scalar

loc Attrib		odk_attrib
loc AttribS		struct `Attrib' scalar
loc AttribR		struct `Attrib' rowvector

loc AttribSet	odk_attrib_set
loc AttribSetS	class `AttribSet' scalar

loc Collection		odk_collection
loc CollectionS		class `Collection' scalar

loc Group	odk_group
loc GroupS	class `Group' scalar

loc Repeat		odk_repeat_group
loc RepeatS		class `Repeat' scalar

loc Field	odk_field
loc FieldS	class `Field' scalar

loc List	odk_list
loc ListS	struct `List' scalar
loc ListR	struct `List' rowvector
