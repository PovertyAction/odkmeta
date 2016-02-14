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
			Collection
			Group
			Repeat
			Field
			string
			csv
			stata
			error
			DoFileWriter
			AttribProps
			Attrib
			AttribSet
			List

			BaseOptions
			SurveyOptions
			ChoicesOptions

			DoStartBaseWriter
			DoStartController
			DoStartWriter

			DoEndBaseWriter
			DoEndController
			DoEndWriter

			write_survey
			write_choices

			ODKMetaDoWriter

			odkmeta
		)
	;
	#d cr
end
