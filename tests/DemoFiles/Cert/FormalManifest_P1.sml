val formal_manifest = 
	(Build_Manifest 
		"P1"
		["attest_aspid"]
		["P1", "P2"]
		["default_place", "P0", "P1", "P2"]
		True
	) : coq_Manifest
