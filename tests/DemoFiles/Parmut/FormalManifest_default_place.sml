val formal_manifest = 
	(Build_Manifest 
		"default_place"
		[]
		["default_place", "P3", "P0", "P1", "P4"]
		["P3", "P1", "default_place", "P4", "P2", "P0"]
		True
	) : coq_Manifest
