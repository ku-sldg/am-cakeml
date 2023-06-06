(* Depends on: util, copland, system/sockets, am/Measurementsm am/CommTypes,
   am/ServerAm extracted/Term_Defs_Core.cml *)


fun run_am_serve_auth_tok_req (t : coq_Term) (fromPlc : coq_Plc) (myPl : coq_Plc) (authTok : coq_ReqAuthTok) (init_ev : coq_RawEv) =
  run_am_app_comp (am_serve_auth_tok_req t fromPlc myPl authTok init_ev) []

(* When things go well, this returns a JSON evidence string. When they go wrong,
   it returns a raw error message string. In the future, we may want to wrap
   said error messages in JSON as well to make it easier on the client. *)
fun evalJson s  = (* jsonToStr (responseToJson (RES O O [])) *)
    let val fromPlc = "10"
        val my_plc = "0"
        val (REQ t authTok ev) = jsonToRequest (strToJson s)
        (*
        val _ = print "\n\nGOT past REQ decoding\n"
        *)
        val _ = print ("Auth Tok Received in REQ: \n" ^ (evCToString authTok) ^ "\n\n")
        (* val ev = ev' *)
        val resev = run_am_serve_auth_tok_req t fromPlc my_plc authTok ev
            
    in jsonToStr (responseToJson (RES resev))
    end
    handle Json.Exn s1 s2 =>
           (TextIO.print_err ("JSON error" ^ s1 ^ ": " ^ s2 ^ "\n");
            "Invalid JSON/Copland term")
        (*
         | USMexpn s =>
            (TextIO.print_err (String.concat ["USM error: ", s, "\n"]);
            "USM failure")   *)


fun respondToMsg client = Socket.output client (evalJson (Socket.inputAll client))


fun handleIncoming listener =
    let val client = Socket.accept listener
     in respondToMsg client;
        Socket.close client
    end
    handle Socket.Err s     => TextIOExtra.printLn_err ("Socket failure: " ^ s)
         | Socket.InvalidFD => TextIOExtra.printLn_err "Invalid file descriptor"


(* () -> () *)
fun startServer () =
    let val queueLength = 5 (* TODO: Hardcoded queuelength *)
        val uuid = ManifestUtils.get_myUUID()
        val (ip, port) = decodeUUID uuid
        val _ = TextIOExtra.printLn ("Starting up Server")
        val _ = TextIOExtra.printLn ("On port: " ^ (Int.toString port) ^ "\nQueue Length: " ^ (Int.toString queueLength))
    in 
     loop handleIncoming (Socket.listen port queueLength)
    end
    handle Socket.Err s => TextIO.print_err ("Socket failure on listener instantiation: " ^ s ^ "\n")
         | Crypto.Err s => TextIO.print_err ("Crypto error: " ^ s ^ "\n")
         | Exception s => TextIO.print_err ("EXCEPTION: " ^ s ^ "\n")
         | Json.Exn s1 s2 => TextIO.print_err ("Json Exception: " ^ s1 ^ "\n" ^ s2 ^ "\n")
         | Result.Exn => TextIO.print_err ("Result Exn:\n")
         | Undef => TextIO.print_err ("Undefined Exception:\n")


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

(* () -> () *)
fun main () =
  let val auth_phrase = ssl_sig_parameterized coq_P0
      val kim_phrase = Coq_att coq_P1 (kim_meas dest_plc kim_meas_targid)
      val cert_phrase = cert_style
      val _ = print_json_man_list_verbose [auth_phrase, kim_phrase, cert_phrase] coq_P0
      val (concreteMan, privKey, _) = ManifestJsonConfig.retrieve_CLI_args () 
      val (concrete, privKey, aspDisp, plcDisp, pubKeyDisp, uuidDisp) = ManifestUtils.setup_and_get_AM_config formal_manifest am_library concreteMan privKey auth_phrase
      val (Build_ConcreteManifest plc plcMap pubKeyMap aspServer_addr pubKeyServer_addr plcServer_addr uuidServer_addr) = concrete
      (* Retrieving implicit self place from manifest here *)
      val my_plc = ManifestUtils.get_myPlc()
      (* Retrieving implicit self place from manifest here *)
      val _ = print ("My Place (retrieved from Manifest): " ^ my_plc ^ "\n\n")
  in
    startServer()
  end
  handle Exception e => TextIO.print_err e 
          | ManifestUtils.Excn e => TextIO.print_err ("ManifestUtils Error: " ^ e)
          | ManifestJsonConfig.Excn e => TextIO.print_err ("ManifestUtils Error: " ^ e)
          | Word8Extra.InvalidHex => TextIO.print_err "BSTRING UNSHOW ERROR"
          | _          => TextIO.print_err "Fatal: unknown error!\n"

val () = main ()
