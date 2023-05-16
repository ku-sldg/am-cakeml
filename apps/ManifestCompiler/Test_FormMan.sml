
(* NOTE: Hardcoding of source place is here now *)
val formal_manifest = 
  (Build_Manifest 
    "0" 
    [ssl_sig_aspid] 
    ["0", "1", "2"]
    ["0", "1", "2"]
    True
  ) : coq_Manifest
  