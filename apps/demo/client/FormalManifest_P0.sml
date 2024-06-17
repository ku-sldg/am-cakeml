val formal_manifest = 
	(Build_Manifest 
		"P0"
		["ssl_sig_aspid"]
		[(Coq_pair "P1" "ssl_sig_aspid")]
		["P0", "P1"]
		[]
		[]
		True
	) : coq_Manifest