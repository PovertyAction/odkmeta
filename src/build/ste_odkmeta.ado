pr ste_odkmeta
	vers 11.2

	_find_project_root
	loc write "`r(path)'/src/main/write"
	loc start "`write'/start"

	#d ;
	ste using `"`start'/templates"',
		base(`start'/DoStartBaseWriter.mata)
		control(DoStartController)
		complete(`start'/DoStartWriter.mata)
	;
	#d cr
end
