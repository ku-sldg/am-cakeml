val formal_manifest = 
	(Build_Manifest 
		"P3"
		[cache_aspid]
		[(Coq_pair "P2" cache_aspid)]
		[]
		[]
		[]
		True
	) : coq_Manifest