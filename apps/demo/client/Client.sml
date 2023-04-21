(* Depends on: util, copland, am/Measurements, am/ServerAm *)

(* NOTE: Hardcoding of source place is here now *)
val formal_manifest = 
  (Build_Manifest "10" ["testASP"] ["testPlc"] [BString.unshow "3082010a0282010100c822fb2b7842e61fa6a779a48f2164793e21d640687146b48ac4e977a4a69f90383c94f3ea5e5336052b728f0a83151603edef890b2a6099376ae87a384a6b236ed51c7f19d94c8b4acb9b00de6cb1c6fc40ff9fec7967ebdbc48cd9b15103411a3b8978d93e59988a7baa21dd3e6fa220359e228f847b81be77bf2467bea40496135a8d06a42c3416bffec3646c8fda7eee19a74275fa2b21bfaa5c8b0dc8e82511b2d8b9a7b760b1d0ae0be03cd98615f3e6c2bc51b1ab11f5b87aad9b44264a2470f26a3a55e4dbd1fa6ea52e66093b4a3eae73bcd7237f07b1ea394a9f893b32d6da15a46f5d7e77c5a6b12ebf41cc7743f4cc241266e58566645dfbbd210203010001"] True) : coq_Manifest

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

val kim_meas = Coq_asp (ASPC ALL EXTD (Coq_asp_paramsC kim_meas_aspid [] dest_plc
    kim_meas_targid))

fun main () =
    let val authb = True
        val (concrete, aspDisp, plcDisp, pubKeyDisp, uuidDisp) = ManifestUtils.setup_and_get_AM_config formal_manifest client_am_library
        val main_phrase = kim_meas (*demo_phrase3*)
        (* Retrieving implicit self place from manifest here *)
        val my_plc = ManifestUtils.get_myPlc()
        (* NOTE: The dest plc is hardcoded here! *)
        val _ = TextIO.print ("Client Launched!\nLoaded following implicit place from Manifest: '" ^ my_plc ^ "'\n\n")
        val am_comp = (am_sendReq_dispatch authb main_phrase my_plc dest_plc aspDisp plcDisp plcDisp) in
        print ( (evidenceCToString (run_am_app_comp am_comp Coq_mtc_app)
          ) ^ "\n\n")
    end
    handle Exception e => TextIO.print_err e 
          | ManifestUtils.Excn e => TextIO.print_err ("ManifestUtils Error: " ^ e)

val _ = main ()
