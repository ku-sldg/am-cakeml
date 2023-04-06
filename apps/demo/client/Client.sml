(* Depends on: util, copland, am/Measurements, am/ServerAm *)

val formal_manifest = 
  Build_Manifest ["testASP"] ["testPlc"] ["testPubKey"] True

val aspMapping = (Map.fromList coq_ID_Type_ordering []) : ((coq_ASP_ID, coq_CakeML_ASPCallback) coq_MapC)

val plcMapping = (Map.fromList coq_ID_Type_ordering [("testPlc", "UUID!")]) : ((coq_Plc, coq_UUID) coq_MapC)

val pubKeyMapping = (Map.fromList coq_ID_Type_ordering []) : ((coq_Plc, coq_PublicKey) coq_MapC)

val aspServerPair = (Coq_pair "aspServer" (fn _ => fn _ => fn _ => fn _ => passed_bs)) : ((coq_ASP_Address, coq_CakeML_ASPCallback) prod)

val pubKeyServerPair = (Coq_pair "pubKeyServer" (fn _ => "OUTPUT_PUBKEY")) : ((coq_ASP_Address, coq_CakeML_PubKeyCallback) prod)

val plcServerPair = (Coq_pair "plcServer" (fn _ => "OUTPUT_UUID")) : ((coq_ASP_Address, coq_CakeML_PlcCallback) prod)

val client_am_library = 
  Build_AM_Library 
    aspMapping plcMapping pubKeyMapping 
    aspServerPair pubKeyServerPair plcServerPair

fun main () =
    let val authb = True
        val (concrete, aspDisp, plcDisp, pubKeyDisp) =
          case (manifest_compiler formal_manifest client_am_library) of
            Coq_pair (Coq_pair (Coq_pair concrete aspDisp) plcDisp) pubKeyDisp =>
              (concrete, aspDisp, plcDisp, pubKeyDisp)
        val testPlcDisp = plcDisp "testPlc"
        val _ = TextIO.print testPlcDisp
        val main_phrase = kim_meas (*demo_phrase3*) in
        if (authb)
        then
            print ( (evidenceCToString (client_demo_am_comp_auth main_phrase )) ^ "\n\n")
        else
            print ( (evidenceCToString (client_demo_am_comp main_phrase )) ^ "\n\n")
    end
        
val _ = main ()      
