pr ste_odkmeta
	vers 11.2

	_find_project_root
	loc dir "`r(path)'/src/main/write"

	#d ;
	ste using `"`dir'/templates"',
		base(`dir'/ODKMetaBaseWriter.mata)
		control(ODKMetaController)
		complete(`dir'/ODKMetaWriter.mata)
	;
	#d cr
end
