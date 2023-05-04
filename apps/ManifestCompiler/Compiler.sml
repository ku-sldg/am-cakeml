(* Depends on: util, copland, system/sockets, am/Measurementsm am/CommTypes,
   am/ServerAm extracted/Term_Defs_Core.cml *)

(* NOTE: Hardcoding of implicit place here *)
val server_formal_manifest = 
  Build_Manifest "0" ["testASP"] ["testPlc"] [(BString.unshow "3082010a0282010100c822fb2b7842e61fa6a779a48f2164793e21d640687146b48ac4e977a4a69f90383c94f3ea5e5336052b728f0a83151603edef890b2a6099376ae87a384a6b236ed51c7f19d94c8b4acb9b00de6cb1c6fc40ff9fec7967ebdbc48cd9b15103411a3b8978d93e59988a7baa21dd3e6fa220359e228f847b81be77bf2467bea40496135a8d06a42c3416bffec3646c8fda7eee19a74275fa2b21bfaa5c8b0dc8e82511b2d8b9a7b760b1d0ae0be03cd98615f3e6c2bc51b1ab11f5b87aad9b44264a2470f26a3a55e4dbd1fa6ea52e66093b4a3eae73bcd7237f07b1ea394a9f893b32d6da15a46f5d7e77c5a6b12ebf41cc7743f4cc241266e58566645dfbbd210203010001")] True

val server_aspMapping = (Map.fromList coq_ID_Type_ordering []) : ((coq_ASP_ID, coq_CakeML_ASPCallback) coq_MapC)

val server_plcMapping = (Map.fromList coq_ID_Type_ordering [("testPlc", "UUID!")]) : ((coq_Plc, coq_UUID) coq_MapC)

val server_pubKeyMapping = (Map.fromList coq_ID_Type_ordering []) : ((coq_Plc, coq_PublicKey) coq_MapC)

val server_aspServerPair = (Coq_pair "aspServer" (fn _ => fn _ => fn _ => fn _ => passed_bs)) : ((coq_ASP_Address, coq_CakeML_ASPCallback) prod)

val server_pubKeyServerPair = (Coq_pair "pubKeyServer" (fn _ => BString.unshow "3082010a0282010100c822fb2b7842e61fa6a779a48f2164793e21d640687146b48ac4e977a4a69f90383c94f3ea5e5336052b728f0a83151603edef890b2a6099376ae87a384a6b236ed51c7f19d94c8b4acb9b00de6cb1c6fc40ff9fec7967ebdbc48cd9b15103411a3b8978d93e59988a7baa21dd3e6fa220359e228f847b81be77bf2467bea40496135a8d06a42c3416bffec3646c8fda7eee19a74275fa2b21bfaa5c8b0dc8e82511b2d8b9a7b760b1d0ae0be03cd98615f3e6c2bc51b1ab11f5b87aad9b44264a2470f26a3a55e4dbd1fa6ea52e66093b4a3eae73bcd7237f07b1ea394a9f893b32d6da15a46f5d7e77c5a6b12ebf41cc7743f4cc241266e58566645dfbbd210203010001")) : ((coq_ASP_Address, coq_CakeML_PubKeyCallback) prod)

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
         

(* () -> () *)
fun main () =
  let val (concreteManifest, aspDisp, plcDisp, pubKeyDisp, uuidDisp) = ManifestUtils.setup_and_get_AM_config server_formal_manifest server_am_library
      val json = JsonConfig.get_json () 
      (* Retrieving implicit self place from manifest here *)
      val my_plc = ManifestUtils.get_myPlc()
      val _ = print ("My Place (retrieved from Manifest): " ^ my_plc ^ "\n\n")
  in
    startServer json
  end
  handle Exception e => TextIO.print_err e 
          | ManifestUtils.Excn e => TextIO.print_err ("ManifestUtils Error: " ^ e)
          | _          => TextIO.print_err "Fatal: unknown error!\n"

fun makeCmakeFile am_library_path = "cmake_minimum_required(VERSION 3.10.2)
get_files(client_src ${server_am_src_tpm}" ^ am_library_path ^ "client/Client.sml)
build_posix_am_tpm(\"COMPILED_AM\" ${client_src})"


val () = main ()
