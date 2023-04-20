(* Depends on: util, copland, system/sockets, am/Measurementsm am/CommTypes,
   am/ServerAm extracted/Term_Defs_Core.cml *)

(* NOTE: Hardcoding of implicit place here *)
val server_formal_manifest = 
  Build_Manifest "1" ["testASP"] ["testPlc"] ["testPubKey"] True

val server_aspMapping = (Map.fromList coq_ID_Type_ordering []) : ((coq_ASP_ID, coq_CakeML_ASPCallback) coq_MapC)

val server_plcMapping = (Map.fromList coq_ID_Type_ordering [("testPlc", "UUID!")]) : ((coq_Plc, coq_UUID) coq_MapC)

val server_pubKeyMapping = (Map.fromList coq_ID_Type_ordering []) : ((coq_Plc, coq_PublicKey) coq_MapC)

val server_aspServerPair = (Coq_pair "aspServer" (fn _ => fn _ => fn _ => fn _ => passed_bs)) : ((coq_ASP_Address, coq_CakeML_ASPCallback) prod)

val server_pubKeyServerPair = (Coq_pair "pubKeyServer" (fn _ => "OUTPUT_PUBKEY")) : ((coq_ASP_Address, coq_CakeML_PubKeyCallback) prod)

val server_plcServerPair = (Coq_pair "plcServer" (fn _ => "OUTPUT_UUID")) : ((coq_ASP_Address, coq_CakeML_PlcCallback) prod)

val server_uuidServerPair = (Coq_pair "uuidServer" (fn _ => "OUTPUT_PLC")) : ((coq_ASP_Address, coq_CakeML_uuidCallback) prod)

val server_am_library = 
  Build_AM_Library 
    server_aspMapping server_plcMapping server_pubKeyMapping 
    server_aspServerPair server_pubKeyServerPair server_plcServerPair server_uuidServerPair

fun run_am_serve_auth_tok_req (t : coq_Term) (fromPlc : coq_Plc) (myPl : coq_Plc) (authTok : coq_ReqAuthTok) (init_ev : coq_RawEv) =
  run_am_app_comp (am_serve_auth_tok_req t fromPlc myPl authTok init_ev) []

(* When things go well, this returns a JSON evidence string. When they go wrong,
   it returns a raw error message string. In the future, we may want to wrap
   said error messages in JSON as well to make it easier on the client. *)
fun evalJson s fromPlc my_plc = (* jsonToStr (responseToJson (RES O O [])) *)
    let val _ = print fromPlc
        val _ = print my_plc
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


fun respondToMsg client uuidCb my_plc = Socket.output client (evalJson (Socket.inputAll client) (uuidCb (Socket.showFd client)) my_plc)


fun handleIncoming listener uuidCb my_plc =
    let val client = Socket.accept listener
     in respondToMsg client uuidCb my_plc;
        Socket.close client
    end
    handle Socket.Err s     => TextIOExtra.printLn_err ("Socket failure: " ^ s)
         | Socket.InvalidFD => TextIOExtra.printLn_err "Invalid file descriptor"


(* Json.json -> () *)
fun startServer (json : Json.json) (my_plc : coq_Plc) uuidCb =
    let val (port, queueLength, privateKey, plcMap) = JsonConfig.extract_server_config json
        val _ = TextIOExtra.printLn ("Starting up Server")
        val _ = TextIOExtra.printLn ("On port: " ^ (Int.toString port) ^ "\nQueue Length: " ^ (Int.toString queueLength))
    in 
     loop handleIncoming (Socket.listen port queueLength) uuidCb my_plc
    end
    handle Socket.Err s => TextIO.print_err ("Socket failure on listener instantiation: " ^ s ^ "\n")
         | Crypto.Err s => TextIO.print_err ("Crypto error: " ^ s ^ "\n")
         | JsonConfig.Excn s => TextIO.print_err ("JsonConfig Error: " ^ s ^ "\n")
         | Exception s => TextIO.print_err ("EXCEPTION: " ^ s ^ "\n")
         | Json.Exn s1 s2 => TextIO.print_err ("Json Exception: " ^ s1 ^ "\n" ^ s2 ^ "\n")
         | Result.Exn => TextIO.print_err ("Result Exn:\n")
         | Undef => TextIO.print_err ("Undefined Exception:\n")
         | _          => TextIO.print_err "Fatal: unknown error!\n"

(* () -> () *)
fun main () =
    let val json = JsonConfig.get_json () 
        val (concrete, aspDisp, plcDisp, pubKeyDisp, uuidDisp) =
          case (manifest_compiler server_formal_manifest server_am_library) of
            Coq_pair (Coq_pair (Coq_pair (Coq_pair concrete aspDisp) plcDisp) pubKeyDisp) uuidDisp =>
              (concrete, aspDisp, plcDisp, pubKeyDisp, uuidDisp)
        (* Retrieving implicit self place from manifest here *)
        val (Build_ConcreteManifest my_plc _ _ _ _ _ _) = concrete
    in
      startServer json my_plc uuidDisp
    end
        
val () = main ()
