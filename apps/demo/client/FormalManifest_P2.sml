val formal_manifest = 
	(Build_Manifest 
		"P2"
		["cert_aspid", "appraise_aspid"]
		[(Coq_pair "P1" "attest_aspid")]
		["P2"]
		[]
		[]
		True
	) : coq_Manifest