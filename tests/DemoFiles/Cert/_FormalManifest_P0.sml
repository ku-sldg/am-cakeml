val formal_manifest = 
	(Build_Manifest 
		"P0"
		["ssl_sig_aspid"]
		[]
		["P0", "P1"]
		["P1", "P2", "default_place", "P0"]
		["default_place"]
		False
	) : coq_Manifest
