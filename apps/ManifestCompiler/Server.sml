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
         

(* () -> () *)
fun main () =
  let val (concreteMan, privKey) = ManifestJsonConfig.retrieve_CLI_args () 
      val (concrete, privKey, aspDisp, plcDisp, pubKeyDisp, uuidDisp) = ManifestUtils.setup_and_get_AM_config formal_manifest am_library concreteMan privKey
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
