(* Depends on: util, copland, system/sockets, am/Measurementsm am/CommTypes,
   am/ServerAm extracted/Term_Defs_Core.cml *)

val server_formal_manifest = 
  Build_Manifest ["testASP"] ["testPlc"] ["testPubKey"] True

val server_aspMapping = (Map.fromList coq_ID_Type_ordering []) : ((coq_ASP_ID, coq_CakeML_ASPCallback) coq_MapC)

val server_plcMapping = (Map.fromList coq_ID_Type_ordering [("testPlc", "UUID!")]) : ((coq_Plc, coq_UUID) coq_MapC)

val server_pubKeyMapping = (Map.fromList coq_ID_Type_ordering []) : ((coq_Plc, coq_PublicKey) coq_MapC)

val server_aspServerPair = (Coq_pair "aspServer" (fn _ => fn _ => fn _ => fn _ => passed_bs)) : ((coq_ASP_Address, coq_CakeML_ASPCallback) prod)

val server_pubKeyServerPair = (Coq_pair "pubKeyServer" (fn _ => "OUTPUT_PUBKEY")) : ((coq_ASP_Address, coq_CakeML_PubKeyCallback) prod)

val server_plcServerPair = (Coq_pair "plcServer" (fn _ => "OUTPUT_UUID")) : ((coq_ASP_Address, coq_CakeML_PlcCallback) prod)

val server_am_library = 
  Build_AM_Library 
    server_aspMapping server_plcMapping server_pubKeyMapping 
    server_aspServerPair server_pubKeyServerPair server_plcServerPair

(* term_policy_check_good :: Coq_Term (extracted/Term_Defs_Core.cml/) -> bool *)
fun term_policy_check_good (p : coq_Plc) termIn = privPolicy coq_Eq_Class_ID_Type p termIn (* TODO: invoke policy code here *)

(* When things go well, this returns a JSON evidence string. When they go wrong,
   it returns a raw error message string. In the future, we may want to wrap
   said error messages in JSON as well to make it easier on the client. *)
fun evalJson s =       (* jsonToStr (responseToJson (RES O O [])) *)
    
    let val (REQ pl1 pl2 pMap t authTok ev) = jsonToRequest (strToJson s)
        (* val ev = ev' *)
        val resev = run_am_serve_auth_tok_req t pl1 pl2 authTok ev
            
    in jsonToStr (responseToJson (RES pl2 pl1 resev))
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


(* Json.json -> () *)
fun startServer (json : Json.json) =
    let val (port, queueLength, privateKey, plcMap) = JsonConfig.extract_server_config json
        val _ = TextIOExtra.printLn ("Starting up Server")
        val _ = TextIOExtra.printLn ("On port: " ^ (Int.toString port) ^ "\nQueue Length: " ^ (Int.toString queueLength))
    in 
     loop handleIncoming (Socket.listen port queueLength)
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
    in
      startServer json
    end
        
val () = main ()
