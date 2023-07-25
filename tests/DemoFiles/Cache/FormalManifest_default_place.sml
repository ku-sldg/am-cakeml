val formal_manifest = 
	(Build_Manifest 
		"default_place"
		[]
		["default_place", "P0", "P1"]
		["P0", "default_place", "P1", "P2"]
		True
	) : coq_Manifest
