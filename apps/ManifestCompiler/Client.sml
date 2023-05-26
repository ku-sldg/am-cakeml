(* Depends on: util, copland, am/Measurements, am/ServerAm *)

val kim_meas = Coq_asp (ASPC ALL EXTD (Coq_asp_paramsC kim_meas_aspid [] dest_plc
    kim_meas_targid))

fun run_am_serve_auth_tok_req (t : coq_Term) (fromPlc : coq_Plc) (myPl : coq_Plc) (authTok : coq_ReqAuthTok) (init_ev : coq_RawEv) =
  run_am_app_comp (am_serve_auth_tok_req t fromPlc myPl authTok init_ev) []


val ssl_demo = False (* True *)


fun main_ssl () =
    let val authb = True (* if (ssl_demo) then True else False *)
        val (concreteMan, privKey) = ManifestJsonConfig.retrieve_CLI_args () 
        val (concrete, privKey, aspDisp, plcDisp, pubKeyDisp, uuidDisp) = ManifestUtils.setup_and_get_AM_config formal_manifest am_library concreteMan privKey
        val (Build_ConcreteManifest plc plcMap pubKeyMap aspServer_addr pubKeyServer_addr plcServer_addr uuidServer_addr) = concrete
        val main_phrase = kim_meas (*kim_meas*) (*demo_phrase3*)
        (* Retrieving implicit self place from manifest here *)
        val my_plc = ManifestUtils.get_myPlc()
        val _ = print ("\n\nClient my_plc: \n" ^ my_plc ^ "\n\n")
        val uuid = ManifestUtils.get_myUUID()
        (* NOTE: The dest plc is hardcoded here! *)
        val _ = TextIO.print ("Client Launched!\nLoaded following implicit place from Manifest: '" ^ my_plc ^ "'\n\n")
        val _ = TextIO.print ("Loaded following implicit UUID from Manifest: '" ^ uuid ^ "'\n\n")
       (* val am_comp = run_am_serve_auth_tok_req main_phrase my_plc my_plc mt_evc [] *)
        val am_comp' = run_am_app_comp (am_sendReq_dispatch authb main_phrase my_plc dest_plc plcDisp) Coq_mtc_app

        (* Hard-codings ok above? *)
        (* val am_comp = (am_sendReq_dispatch authb main_phrase my_plc dest_plc plcDisp)  *)
    in
        print ( (evidenceCToString (am_comp')) ^ "\n\n")
    end
    handle Exception e => TextIO.print_err e 
          | ManifestUtils.Excn e => TextIO.print_err ("ManifestUtils Error: " ^ e)
          | ManifestJsonConfig.Excn e => TextIO.print_err ("ManifestUtils Error: " ^ e)
          | Word8Extra.InvalidHex => TextIO.print_err "BSTRING UNSHOW ERROR"
          | Socket.Err s => TextIO.print_err ("Socket failure on listener instantiation: " ^ s ^ "\n")
          | Crypto.Err s => TextIO.print_err ("Crypto error: " ^ s ^ "\n")
          | Json.Exn s1 s2 => TextIO.print_err ("Json Exception: " ^ s1 ^ "\n" ^ s2 ^ "\n")
          | Result.Exn => TextIO.print_err ("Result Exn:\n")
          | Undef => TextIO.print_err ("Undefined Exception:\n")
          | _ => TextIO.print_err "Unknown Error Encountered!\n"

fun main_cert () =
    let val (concreteMan, privKey) = ManifestJsonConfig.retrieve_CLI_args () 
        val (concrete, privKey, aspDisp, plcDisp, pubKeyDisp, uuidDisp) = ManifestUtils.setup_and_get_AM_config formal_manifest am_library concreteMan privKey
        val (Build_ConcreteManifest plc plcMap pubKeyMap aspServer_addr pubKeyServer_addr plcServer_addr uuidServer_addr) = concrete
        val main_phrase = cert_style (*kim_meas*) (*demo_phrase3*)
        (* Retrieving implicit self place from manifest here *)
        val my_plc = ManifestUtils.get_myPlc()
        val _ = print ("\n\nClient my_plc: \n" ^ my_plc ^ "\n\n")
        val uuid = ManifestUtils.get_myUUID()
        (* NOTE: The dest plc is hardcoded here! *)
        val _ = TextIO.print ("Client Launched!\nLoaded following implicit place from Manifest: '" ^ my_plc ^ "'\n\n")
        val _ = TextIO.print ("Loaded following implicit UUID from Manifest: '" ^ uuid ^ "'\n\n")
        val am_comp = run_am_serve_auth_tok_req main_phrase my_plc my_plc mt_evc []
    in
        print ( (rawEvToString (am_comp))  ^ "\n\n")
    end
    handle Exception e => TextIO.print_err e 
          | ManifestUtils.Excn e => TextIO.print_err ("ManifestUtils Error: " ^ e)
          | ManifestJsonConfig.Excn e => TextIO.print_err ("ManifestUtils Error: " ^ e)
          | Word8Extra.InvalidHex => TextIO.print_err "BSTRING UNSHOW ERROR"
          | Socket.Err s => TextIO.print_err ("Socket failure on listener instantiation: " ^ s ^ "\n")
          | Crypto.Err s => TextIO.print_err ("Crypto error: " ^ s ^ "\n")
          | Json.Exn s1 s2 => TextIO.print_err ("Json Exception: " ^ s1 ^ "\n" ^ s2 ^ "\n")
          | Result.Exn => TextIO.print_err ("Result Exn:\n")
          | Undef => TextIO.print_err ("Undefined Exception:\n")
          | _ => TextIO.print_err "Unknown Error Encountered!\n"

fun main () = 
    if (ssl_demo)
    then main_ssl ()
    else main_cert ()


val _ = main ()
