
val aspMapping = (Map.fromList coq_ID_Type_ordering []) : ((coq_ASP_ID, coq_CakeML_ASPCallback) coq_MapC)

val plcMapping = (Map.fromList coq_ID_Type_ordering [("0", "localhost:5001")]) : ((coq_Plc, coq_UUID) coq_MapC)

val pubKeyMapping = (Map.fromList coq_ID_Type_ordering []) : ((coq_Plc, coq_PublicKey) coq_MapC)

val aspServerPair = (Coq_pair "aspServer" (fn _ => fn _ => fn _ => fn _ => passed_bs)) : ((coq_ASP_Address, coq_CakeML_ASPCallback) prod)

val pubKeyServerPair = (Coq_pair "pubKeyServer" (fn _ => BString.unshow "OUTPUT_PUBKEY")) : ((coq_ASP_Address, coq_CakeML_PubKeyCallback) prod)

val plcServerPair = (Coq_pair "plcServer" (fn _ => "OUTPUT_UUID")) : ((coq_ASP_Address, coq_CakeML_PlcCallback) prod)

val uuidServerPair = (Coq_pair "uuidServer" (fn _ => "OUTPUT_PLC")) : ((coq_ASP_Address, coq_CakeML_uuidCallback) prod)

val client_am_library = 
  (Build_AM_Library 
    aspMapping plcMapping pubKeyMapping 
    aspServerPair pubKeyServerPair plcServerPair uuidServerPair) : coq_AM_Library
