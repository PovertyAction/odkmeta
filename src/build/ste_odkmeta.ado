pr ste_odkmeta
	vers 11.2

	_find_project_root
	loc write "`r(path)'/src/main/write"

	di
	#d ;
	loc writers
		DoStart start
		DoEnd   end
	;
	#d cr
	while `:list sizeof writers' {
		gettoken stub   writers : writers
		gettoken subdir writers : writers

		di as txt "Templatizing {res:`subdir'}..."

		loc dir "`write'/`subdir'"
		#d ;
		ste using `"`dir'/templates"',
			base(`dir'/`stub'BaseWriter.mata)
			control(`stub'Controller)
			complete(`dir'/`stub'Writer.mata)
		;
		#d cr
	}
end
