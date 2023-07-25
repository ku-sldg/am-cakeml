val formal_manifest = 
	(Build_Manifest 
		"P1"
		["attest_aspid", "attest_aspid", "attest_aspid"]
		["P1", "P2", "P4", "P3"]
		["default_place", "P0", "P1", "P2", "P4", "P3"]
		True
	) : coq_Manifest