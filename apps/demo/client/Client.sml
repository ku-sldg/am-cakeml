(* Depends on: util, copland, am/Measurements, am/ServerAm *)

(* NOTE: Hardcoding of source place is here now *)
val formal_manifest = 
  Build_Manifest "0" ["testASP"] ["testPlc"] ["testPubKey"] True

val aspMapping = (Map.fromList coq_ID_Type_ordering []) : ((coq_ASP_ID, coq_CakeML_ASPCallback) coq_MapC)

val plcMapping = (Map.fromList coq_ID_Type_ordering [("testPlc", "UUID!")]) : ((coq_Plc, coq_UUID) coq_MapC)

val pubKeyMapping = (Map.fromList coq_ID_Type_ordering []) : ((coq_Plc, coq_PublicKey) coq_MapC)

val aspServerPair = (Coq_pair "aspServer" (fn _ => fn _ => fn _ => fn _ => passed_bs)) : ((coq_ASP_Address, coq_CakeML_ASPCallback) prod)

val pubKeyServerPair = (Coq_pair "pubKeyServer" (fn _ => "OUTPUT_PUBKEY")) : ((coq_ASP_Address, coq_CakeML_PubKeyCallback) prod)

val plcServerPair = (Coq_pair "plcServer" (fn _ => "OUTPUT_UUID")) : ((coq_ASP_Address, coq_CakeML_PlcCallback) prod)

val uuidServerPair = (Coq_pair "uuidServer" (fn _ => "OUTPUT_PLC")) : ((coq_ASP_Address, coq_CakeML_uuidCallback) prod)

val client_am_library = 
  Build_AM_Library 
    aspMapping plcMapping pubKeyMapping 
    aspServerPair pubKeyServerPair plcServerPair uuidServerPair

val kim_meas = Coq_asp (ASPC ALL EXTD (Coq_asp_paramsC kim_meas_aspid [] dest_plc
    kim_meas_targid))

fun main () =
    let val authb = True
        val (concrete, aspDisp, plcDisp, pubKeyDisp, uuidDisp) =
          case (manifest_compiler formal_manifest client_am_library) of
            Coq_pair (Coq_pair (Coq_pair (Coq_pair concrete aspDisp) plcDisp) pubKeyDisp) uuidDisp =>
              (concrete, aspDisp, plcDisp, pubKeyDisp, uuidDisp)
        val testPlcDisp = plcDisp "testPlc"
        val _ = TextIO.print testPlcDisp
        val main_phrase = kim_meas (*demo_phrase3*)
        (* Retrieving implicit self place from manifest here *)
        val (Build_ConcreteManifest my_plc _ _ _ _ _ _) = concrete
        (* NOTE: The dest plc is hardcoded here! *)
        val am_comp = (am_sendReq_dispatch authb main_phrase my_plc dest_plc aspDisp plcDisp pubKeyDisp) in
        print ( (evidenceCToString (run_am_app_comp am_comp Coq_mtc_app)
          ) ^ "\n\n")
    end
        
val _ = main ()
