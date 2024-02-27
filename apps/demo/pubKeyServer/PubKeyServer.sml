(* Depends on: util, copland, system/sockets, am/Measurementsm am/CommTypes,
   am/ServerAm extracted/Term_Defs_Core.cml *)

(* NOTE: Hardcoding of source place is here now *)
val formal_manifest = 
  (Build_Manifest 
    "0" 
    [ssl_sig_aspid] 
    [ssl_sig_aspid]
    ["0", "1", "2"]
    ["0", "1", "2"]
    []
    True
  ) : coq_Manifest
  

val aspMapping = (mapC_from_pairList []) : ((coq_ASP_ID, coq_CallBackErrors coq_ASPCallback) coq_MapC)

val appAspMapping = (mapC_from_pairList []) : (((coq_Plc, coq_ASP_ID) prod, coq_CallBackErrors coq_ASPCallback) coq_MapC)


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

val aspServer_cb = (fn aspServerAddr => fn aspParams => fn plc => fn bs => fn rawEv => do_asp aspServerAddr aspParams rawEv) : (coq_ASP_Address -> coq_CallBackErrors coq_ASPCallback)

val pubKeyServer_cb = (fn _ => fn _ => (Coq_resultC (BString.unshow "OUTPUT_PUBKEY"))) :  (coq_ASP_Address -> coq_PubKeyCallback)

val plcServer_cb = (fn _ => fn _ => (Coq_resultC "OUTPUT_UUID")) : (coq_ASP_Address ->  coq_PlcCallback)

val uuidServer_cb = (fn _ => fn _ => (Coq_resultC "OUTPUT_PLC")) : (coq_ASP_Address -> coq_UUIDCallback)

val client_am_library = 
  (Build_AM_Library 
    aspServer_cb pubKeyServer_cb plcServer_cb uuidServer_cb
    
    "ASP_SERVER:5000" "PubKeyServer:5000" "PlcServer:5000" "UUIDServer:5000"

    aspMapping
    appAspMapping
    (mapD_from_pairList [("0", "localhost:5000"),("1", "localhost:5001"),("2", "localhost:5002")])

    (mapD_from_pairList [("0", (BString.unshow "3082010a0282010100c822fb2b7842e61fa6a779a48f2164793e21d640687146b48ac4e977a4a69f90383c94f3ea5e5336052b728f0a83151603edef890b2a6099376ae87a384a6b236ed51c7f19d94c8b4acb9b00de6cb1c6fc40ff9fec7967ebdbc48cd9b15103411a3b8978d93e59988a7baa21dd3e6fa220359e228f847b81be77bf2467bea40496135a8d06a42c3416bffec3646c8fda7eee19a74275fa2b21bfaa5c8b0dc8e82511b2d8b9a7b760b1d0ae0be03cd98615f3e6c2bc51b1ab11f5b87aad9b44264a2470f26a3a55e4dbd1fa6ea52e66093b4a3eae73bcd7237f07b1ea394a9f893b32d6da15a46f5d7e77c5a6b12ebf41cc7743f4cc241266e58566645dfbbd210203010001")),("1", (BString.unshow "3082010a0282010100c822fb2b7842e61fa6a779a48f2164793e21d640687146b48ac4e977a4a69f90383c94f3ea5e5336052b728f0a83151603edef890b2a6099376ae87a384a6b236ed51c7f19d94c8b4acb9b00de6cb1c6fc40ff9fec7967ebdbc48cd9b15103411a3b8978d93e59988a7baa21dd3e6fa220359e228f847b81be77bf2467bea40496135a8d06a42c3416bffec3646c8fda7eee19a74275fa2b21bfaa5c8b0dc8e82511b2d8b9a7b760b1d0ae0be03cd98615f3e6c2bc51b1ab11f5b87aad9b44264a2470f26a3a55e4dbd1fa6ea52e66093b4a3eae73bcd7237f07b1ea394a9f893b32d6da15a46f5d7e77c5a6b12ebf41cc7743f4cc241266e58566645dfbbd210203010001")), ("2", (BString.unshow "3082010a0282010100c822fb2b7842e61fa6a779a48f2164793e21d640687146b48ac4e977a4a69f90383c94f3ea5e5336052b728f0a83151603edef890b2a6099376ae87a384a6b236ed51c7f19d94c8b4acb9b00de6cb1c6fc40ff9fec7967ebdbc48cd9b15103411a3b8978d93e59988a7baa21dd3e6fa220359e228f847b81be77bf2467bea40496135a8d06a42c3416bffec3646c8fda7eee19a74275fa2b21bfaa5c8b0dc8e82511b2d8b9a7b760b1d0ae0be03cd98615f3e6c2bc51b1ab11f5b87aad9b44264a2470f26a3a55e4dbd1fa6ea52e66093b4a3eae73bcd7237f07b1ea394a9f893b32d6da15a46f5d7e77c5a6b12ebf41cc7743f4cc241266e58566645dfbbd210203010001"))])
    ) : coq_AM_Library

(* string -> option (plc (as string)) *)
fun json_extractPlc s =
    case (Json.parse s) of
      Err e => Err "Unable to parse JSON request"
    | Ok mapVal =>
      case (Json.lookup "plc" mapVal) of
        Some plc => Ok (Json.stringify plc)
      | None => Err "Malformed JSON request - Missing 'plc' field"

fun lookup_pubkey pubKeyMap plc = 
    (case (Json.lookup plc pubKeyMap) of
      Some pubKeyJson => 
        (case Json.lookup "pubKey" pubKeyJson of
          Some pubKey => Ok pubKey
        | None => Err ("Unable to find corresponding public key for plc: '" ^ plc ^ "'")
        )
    | None => Err ("Unable to find entry for plc: '" ^ plc ^ "'")
    )

fun handle_json_request jsonReqStr = 
    (case (json_extractPlc jsonReqStr) of
      Err e     => Err e
    | Ok plc  => 
      let val jsonFile = (TextIOExtra.readFile "Stubbed_Json.json") in
      (case (Json.parse jsonFile) of
        Err e => Err ("Server Error: Cannot parse JSON database - " ^ e)
      | Ok map =>
          (case (lookup_pubkey map plc) of
            Err e => Err e
          | Ok pubKey => 
              (case (Json.toString pubKey) of
                None => Err "Cannot convert public key to string"
              | Some pubKeyVal => Ok pubKeyVal
              )
          )
        )
      end)

fun handle_overall_json jsonReqStr = 
    let val req_result = handle_json_request jsonReqStr 
      in
        (case (req_result) of
          Ok pubKey => ("{ pubKey: " ^ pubKey ^ "}")
        | Err e => "{ error: '" ^ e ^ "' }"
        )
      end
      
fun respondToMsg client = Socket.output client (handle_overall_json (Socket.inputAll client))

fun handleIncoming listener =
    let val client = Socket.accept listener
     in respondToMsg client;
        Socket.close client
    end
    handle Socket.Err s     => TextIOExtra.printLn_err ("Socket failure: " ^ s)
         | Socket.InvalidFD => TextIOExtra.printLn_err "Invalid file descriptor"

(* () -> () *)
fun startServer () =
    let val queueLength = 5 (* TODO: Hardcoded queue length *)
        val auth_phrase = ssl_sig_parameterized coq_P0
        val (manFilename, privKey, _, _) = ManifestJsonConfig.retrieve_CLI_args () 
        val _ = ManifestUtils.setup_and_get_AM_config formal_manifest client_am_library privKey
        val uuid = ManifestUtils.get_myUUID()
        val (ip, port) = decodeUUID uuid
        val _ = TextIOExtra.printLn ("Starting up")
        val _ = TextIOExtra.printLn ("On port: " ^ (Int.toString port) ^ "\nQueue Length: " ^ (Int.toString queueLength))
    in 
      loop handleIncoming (Socket.listen port queueLength)
    end
    handle Socket.Err s => TextIO.print_err ("Socket failure on listener instantiation: " ^ s ^ "\n")
          | Crypto.Err s => TextIO.print_err ("Crypto error: " ^ s ^ "\n")
          | Exception s => TextIO.print_err ("EXCEPTION: " ^ s ^ "\n")
          | ManifestUtils.Excn e => TextIO.print_err ("ManifestUtils Error: " ^ e)
          | ManifestJsonConfig.Excn e => TextIO.print_err ("ManifestUtils Error: " ^ e)
          | Word8Extra.InvalidHex => TextIO.print_err "BSTRING UNSHOW ERROR"
          | _          => TextIO.print_err ("Fatal: unknown error\n")

(* () -> () *)
fun main () = startServer ()

val () = main ()
