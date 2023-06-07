(* Depends on: util, copland, am/Measurements, am/ServerAm *)

(* val kim_meas = Coq_asp (ASPC ALL EXTD (Coq_asp_paramsC kim_meas_aspid [] dest_plc
    kim_meas_targid)) *)

fun run_am_serve_auth_tok_req (t : coq_Term) (fromPlc : coq_Plc) (myPl : coq_Plc) (authTok : coq_ReqAuthTok) (init_ev : coq_RawEv) =
  run_am_app_comp (am_serve_auth_tok_req t fromPlc myPl authTok init_ev) []

fun run_am_client_auth_tok_req (t : coq_Term) (myPl : coq_Plc) (init_ev : coq_RawEv) (app_bool:bool) =
  run_am_app_comp (am_client_auth_tok_req t myPl init_ev app_bool) empty_am_result


(*
val ssl_demo = True (* True *)
*)



fun print_json_man_id (m:coq_Manifest) =
    let val _ = print ("\n" ^ (Json.stringify (ManifestJsonConfig.encode_Manifest m)) ^ "\n") in
    m
    end

fun print_json_man_list (ls: coq_Manifest list) =
    let val _ = List.map print_json_man_id ls
    in
      ()
    end

fun print_json_man_list_verbose (ts:coq_Term list) (p:coq_Plc) = 
  let (* val _ = print ("\nFormal Manifests generated from phrase: \n\n'" ^ (termToString t) ^ "'\n\nat top-level place: \n'" ^ p ^ "': \n") *)
      val demo_man_list : coq_Manifest list = demo_man_gen_run ts p 
      val _ = ManifestJsonConfig.write_FormalManifestList demo_man_list
  in
    (print_json_man_list demo_man_list) : unit
  end
  handle ManifestJsonConfig.Excn e => TextIOExtra.printLn e


(* val _ = print_json_man_list_verbose [cert_style, ssl_sig] coq_P0 *)



(*
fun main_ssl () =
    let val auth_phrase = ssl_sig_parameterized coq_P0
        val (concreteMan, privKey) = ManifestJsonConfig.retrieve_CLI_args () 
        val (concrete, privKey, aspDisp, plcDisp, pubKeyDisp, uuidDisp) = ManifestUtils.setup_and_get_AM_config formal_manifest am_library concreteMan privKey auth_phrase
        val (Build_ConcreteManifest plc plcMap pubKeyMap aspServer_addr pubKeyServer_addr plcServer_addr uuidServer_addr) = concrete
        val main_phrase = (* Coq_att dest_plc *) (kim_meas dest_plc kim_meas_targid) (*kim_meas*) (*demo_phrase3*)
        (* Retrieving implicit self place from manifest here *)
        val my_plc = ManifestUtils.get_myPlc()
        val _ = print ("\n\nClient my_plc: \n" ^ my_plc ^ "\n\n")
        val uuid = ManifestUtils.get_myUUID()
        (* NOTE: The dest plc is hardcoded here! *)
        val _ = TextIO.print ("Client Launched!\nLoaded following implicit place from Manifest: '" ^ my_plc ^ "'\n\n")
        val _ = TextIO.print ("Loaded following implicit UUID from Manifest: '" ^ uuid ^ "'\n\n")
       (* val am_comp = run_am_serve_auth_tok_req main_phrase my_plc my_plc mt_evc [] *)
        val nonceB = True
        val appraiseB = True
        (* val _ = print_json_man_list_verbose [auth_phrase, main_phrase] coq_P0  *)

        (*
        val am_comp = run_am_client_auth_tok_req main_phrase my_plc [] appraiseB
        *)

        
        val am_comp' = (am_sendReq_dispatch (Some auth_phrase) nonceB main_phrase my_plc dest_plc appraiseB plcDisp)
        val am_comp = run_am_app_comp am_comp' empty_am_result



        (*val am_comp = run_am_app_comp (am_sendReq_dispatch (Some auth_phrase) nonceB main_phrase my_plc dest_plc appraiseB plcDisp) empty_am_result*)

        (* Hard-codings ok above? *)
        (* val am_comp = (am_sendReq_dispatch authb main_phrase my_plc dest_plc plcDisp)  *)
    in
        (* print ( (evidenceCToString (am_comp)) ^ "\n\n") *)
        print ( ("\n\nClient Result:\n" ^ am_result_ToString (am_comp))  ^ "\n\n")
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
*)


 
fun main' ()(* (main_phrase:coq_Term) *) =
    let val auth_phrase = ssl_sig_parameterized coq_P0
        (* val main_phrase = cert_style (*kim_meas*) (*demo_phrase3*) *)
        val (concreteMan, privKey, main_phrase) = ManifestJsonConfig.retrieve_CLI_args () 
        val (concrete, privKey, aspDisp, plcDisp, pubKeyDisp, uuidDisp) = ManifestUtils.setup_and_get_AM_config formal_manifest am_library concreteMan privKey auth_phrase
        val (Build_ConcreteManifest plc plcMap pubKeyMap aspServer_addr pubKeyServer_addr plcServer_addr uuidServer_addr) = concrete
        (* Retrieving implicit self place from manifest here *)
        val my_plc = ManifestUtils.get_myPlc()
        val to_plc = coq_P1
        val _ = print ("\n\nClient my_plc: \n" ^ my_plc ^ "\n\n")
        val uuid = ManifestUtils.get_myUUID()
        (* NOTE: The dest plc is hardcoded here! *)
        val _ = TextIO.print ("Client Launched!\nLoaded following implicit place from Manifest: '" ^ my_plc ^ "'\n\n")
        val _ = TextIO.print ("Loaded following implicit UUID from Manifest: '" ^ uuid ^ "'\n\n")
        val nonceB = True
        val appraiseB = True
        (* val _ = print_json_man_list_verbose [auth_phrase, main_phrase] coq_P0  *)


        (* val am_comp' = (am_sendReq_dispatch (Some auth_phrase) nonceB main_phrase my_plc to_plc appraiseB plcDisp)
        val am_comp = run_am_app_comp am_comp' empty_am_result *)
        val am_comp = run_am_client_auth_tok_req main_phrase my_plc [] appraiseB
    in
        print ( ("\n\nClient Result:\n" ^ am_result_ToString (am_comp))  ^ "\n\n")
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

fun main () = main' ()

(*
    let val ssl_demo = True
        val main_phrase =
          if (ssl_demo)
          then (kim_meas dest_plc kim_meas_targid)
          else cert_style_trimmed 
       in
      (main' main_phrase)
    end
    *)


val _ = main ()


















(*

fun main_cert () =
    let val auth_phrase = ssl_sig_parameterized coq_P0
        val main_phrase = cert_style (*kim_meas*) (*demo_phrase3*)
        val (concreteMan, privKey) = ManifestJsonConfig.retrieve_CLI_args () 
        val (concrete, privKey, aspDisp, plcDisp, pubKeyDisp, uuidDisp) = ManifestUtils.setup_and_get_AM_config formal_manifest am_library concreteMan privKey auth_phrase
        val (Build_ConcreteManifest plc plcMap pubKeyMap aspServer_addr pubKeyServer_addr plcServer_addr uuidServer_addr) = concrete
        (* Retrieving implicit self place from manifest here *)
        val my_plc = ManifestUtils.get_myPlc()
        val to_plc = coq_P1
        val _ = print ("\n\nClient my_plc: \n" ^ my_plc ^ "\n\n")
        val uuid = ManifestUtils.get_myUUID()
        (* NOTE: The dest plc is hardcoded here! *)
        val _ = TextIO.print ("Client Launched!\nLoaded following implicit place from Manifest: '" ^ my_plc ^ "'\n\n")
        val _ = TextIO.print ("Loaded following implicit UUID from Manifest: '" ^ uuid ^ "'\n\n")
        val nonceB = True
        val appraiseB = True
        (* val _ = print_json_man_list_verbose [auth_phrase, main_phrase] coq_P0  *)
        val am_comp' = (am_sendReq_dispatch (Some auth_phrase) nonceB cert_style_trimmed my_plc to_plc appraiseB plcDisp)
        val am_comp = run_am_app_comp am_comp' empty_am_result
        (* val am_comp = run_am_client_auth_tok_req main_phrase my_plc [] appraise_resultB *)
    in
        print ( ("\n\nClient Result:\n" ^ am_result_ToString (am_comp))  ^ "\n\n")
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


*)
