
val aspMapping = (Map.fromList coq_ID_Type_ordering []) : ((coq_ASP_ID, coq_CakeML_ASPCallback) coq_MapC)

val aspServer_cb = (fn _ => fn _ => fn _ => fn _ => fn _ => passed_bs) : (coq_ASP_Address -> coq_CakeML_ASPCallback)

val pubKeyServer_cb = (fn _ => fn _ => BString.unshow "OUTPUT_PUBKEY") :  (coq_ASP_Address -> coq_CakeML_PubKeyCallback)

val plcServer_cb = (fn _ => fn _ => "OUTPUT_UUID") : (coq_ASP_Address ->  coq_CakeML_PlcCallback)

val uuidServer_cb = (fn _ => fn _ => "OUTPUT_PLC") : (coq_ASP_Address -> coq_CakeML_uuidCallback)

val client_am_library = 
  (Build_AM_Library 
    aspMapping aspServer_cb pubKeyServer_cb plcServer_cb uuidServer_cb) : coq_AM_Library
