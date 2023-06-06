(* Depends on: util, copland, system/sockets, am/Measurementsm am/CommTypes,
   am/ServerAm extracted/Term_Defs_Core.cml *)

(* NOTE: Hardcoding of source place is here now *)
val server_formal_manifest = 
  (Build_Manifest 
    "0" 
    [ssl_sig_aspid] 
    ["0", "1", "2"]
    ["0", "1", "2"]
    True
  ) : coq_Manifest
  
val aspMapping = (mapC_from_pairList []) : ((coq_ASP_ID, coq_CakeML_ASPCallback) coq_MapC)


(** val do_asp : coq_ASP_Address -> coq_ASP_PARAMS -> coq_RawEv -> coq_BS **)
fun do_asp asp_server_addr ps e =
    let val _ = print ("Running ASP with params: \n" ^ (aspParamsToString ps) ^ "\n")
        val res = 
            case ps of Coq_asp_paramsC aspid args tpl tid =>
              case (aspid = cal_ak_aspid) of    
                  True => cal_ak_asp_stub ps e              
                | _ => 
                  case (aspid = get_data_aspid) of
                      True => get_data_asp_stub ps e                
                    | _ =>
                      case (aspid = tpm_sig_aspid) of
                          True => tpm_sig_asp_stub ps e
                        | _ =>
                          case (aspid = ssl_enc_aspid) of
                              True => ssl_enc_asp_stub ps e                  
                            | _ =>
                              case (aspid = pub_bc_aspid) of
                                  True => pub_bc_asp_stub ps e
                                | _ => 
                                  case (aspid = store_clientData_aspid) of
                                      True => store_clientData_asp_stub ps e
                                    | _ => 
                                      case (aspid = ssl_sig_aspid) of
                                          True => ssl_sig_asp_stub ps e
                                        | _ => 
                                          case (aspid = kim_meas_aspid) of
                                              True => kim_meas_asp_stub ps e
                                            | _ =>                     
                                              (print ("Matched OTHER aspid:  " ^ aspid ^ "\n");
                                                raise (Exception ("TODO: Dispatch this request to ASP server at '" ^ asp_server_addr ^ "'\n")))
    in
        res
    end

val aspServer_cb = (fn aspServerAddr => fn aspParams => fn plc => fn bs => fn rawEv => do_asp aspServerAddr aspParams rawEv) : (coq_ASP_Address -> coq_CakeML_ASPCallback)

val pubKeyServer_cb = (fn _ => fn _ => BString.unshow "OUTPUT_PUBKEY") :  (coq_ASP_Address -> coq_CakeML_PubKeyCallback)

val plcServer_cb = (fn _ => fn _ => "OUTPUT_UUID") : (coq_ASP_Address ->  coq_CakeML_PlcCallback)

val uuidServer_cb = (fn _ => fn _ => "OUTPUT_PLC") : (coq_ASP_Address -> coq_CakeML_uuidCallback)

val server_am_library = 
  (Build_AM_Library 
    aspServer_cb pubKeyServer_cb plcServer_cb uuidServer_cb
    
    "ASP_SERVER:5000" "PubKeyServer:5000" "PlcServer:5000" "UUIDServer:5000"

    aspMapping
    (mapD_from_pairList [("0", "localhost:5000"),("1", "localhost:5001"),("2", "localhost:5002")])

    (mapD_from_pairList [("0", (BString.unshow "3082010a0282010100c822fb2b7842e61fa6a779a48f2164793e21d640687146b48ac4e977a4a69f90383c94f3ea5e5336052b728f0a83151603edef890b2a6099376ae87a384a6b236ed51c7f19d94c8b4acb9b00de6cb1c6fc40ff9fec7967ebdbc48cd9b15103411a3b8978d93e59988a7baa21dd3e6fa220359e228f847b81be77bf2467bea40496135a8d06a42c3416bffec3646c8fda7eee19a74275fa2b21bfaa5c8b0dc8e82511b2d8b9a7b760b1d0ae0be03cd98615f3e6c2bc51b1ab11f5b87aad9b44264a2470f26a3a55e4dbd1fa6ea52e66093b4a3eae73bcd7237f07b1ea394a9f893b32d6da15a46f5d7e77c5a6b12ebf41cc7743f4cc241266e58566645dfbbd210203010001")),("1", (BString.unshow "3082010a0282010100c822fb2b7842e61fa6a779a48f2164793e21d640687146b48ac4e977a4a69f90383c94f3ea5e5336052b728f0a83151603edef890b2a6099376ae87a384a6b236ed51c7f19d94c8b4acb9b00de6cb1c6fc40ff9fec7967ebdbc48cd9b15103411a3b8978d93e59988a7baa21dd3e6fa220359e228f847b81be77bf2467bea40496135a8d06a42c3416bffec3646c8fda7eee19a74275fa2b21bfaa5c8b0dc8e82511b2d8b9a7b760b1d0ae0be03cd98615f3e6c2bc51b1ab11f5b87aad9b44264a2470f26a3a55e4dbd1fa6ea52e66093b4a3eae73bcd7237f07b1ea394a9f893b32d6da15a46f5d7e77c5a6b12ebf41cc7743f4cc241266e58566645dfbbd210203010001")), ("2", (BString.unshow "3082010a0282010100c822fb2b7842e61fa6a779a48f2164793e21d640687146b48ac4e977a4a69f90383c94f3ea5e5336052b728f0a83151603edef890b2a6099376ae87a384a6b236ed51c7f19d94c8b4acb9b00de6cb1c6fc40ff9fec7967ebdbc48cd9b15103411a3b8978d93e59988a7baa21dd3e6fa220359e228f847b81be77bf2467bea40496135a8d06a42c3416bffec3646c8fda7eee19a74275fa2b21bfaa5c8b0dc8e82511b2d8b9a7b760b1d0ae0be03cd98615f3e6c2bc51b1ab11f5b87aad9b44264a2470f26a3a55e4dbd1fa6ea52e66093b4a3eae73bcd7237f07b1ea394a9f893b32d6da15a46f5d7e77c5a6b12ebf41cc7743f4cc241266e58566645dfbbd210203010001"))])
    ) : coq_AM_Library

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
  let val (concreteMan, privKey, _) = ManifestJsonConfig.retrieve_CLI_args () 
      val auth_phrase = ssl_sig_parameterized coq_P0
      val (concrete, privKey, aspDisp, plcDisp, pubKeyDisp, uuidDisp) = ManifestUtils.setup_and_get_AM_config server_formal_manifest server_am_library concreteMan privKey auth_phrase
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
