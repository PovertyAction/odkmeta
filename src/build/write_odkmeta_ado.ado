pr write_odkmeta_ado
	vers 11.2

	ste_odkmeta

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

			write_do_end
			write_survey
			write_choices

			ODKMetaDoWriter

			odkmeta
		)
	;
	#d cr
end
