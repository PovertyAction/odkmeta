pr write_odkmeta_ado
	vers 11.2

	qui ste_odkmeta

	_find_project_root
	#d ;
	writeado
		using `"`r(path)'/src/build/odkmeta.ado"',
		stata(main/odkmeta.do)
		class_declarations(
			Collection
			Group
			Repeat
			Field
		)
		mata(
			// Classes with declaration dependencies
			Collection
			Group
			Repeat
			Field

			// External dependencies
			DoFileWriter

			// Functions
			csv
			error
			stata
			string

			BaseOptions
			SurveyOptions
			ChoicesOptions

			AttribProps
			Attrib
			AttribSet
			FormFields

			List
			FormLists

			ODKMetaBaseWriter
			ODKMetaController
			ODKMetaWriter

			odkmeta
		)
	;
	#d cr
end
