(* Depends on: util, copland, system/sockets, am/Measurementsm am/CommTypes,
   am/ServerAm extracted/Term_Defs_Core.cml *)

(* NOTE: Hardcoding of source place is here now *)
val formal_manifest = 
  (Build_Manifest 
    "10" 
    "localhost:5000" 
    (BString.unshow "308204bf020100300d06092a864886f70d0101010500048204a9308204a50201000282010100c822fb2b7842e61fa6a779a48f2164793e21d640687146b48ac4e977a4a69f90383c94f3ea5e5336052b728f0a83151603edef890b2a6099376ae87a384a6b236ed51c7f19d94c8b4acb9b00de6cb1c6fc40ff9fec7967ebdbc48cd9b15103411a3b8978d93e59988a7baa21dd3e6fa220359e228f847b81be77bf2467bea40496135a8d06a42c3416bffec3646c8fda7eee19a74275fa2b21bfaa5c8b0dc8e82511b2d8b9a7b760b1d0ae0be03cd98615f3e6c2bc51b1ab11f5b87aad9b44264a2470f26a3a55e4dbd1fa6ea52e66093b4a3eae73bcd7237f07b1ea394a9f893b32d6da15a46f5d7e77c5a6b12ebf41cc7743f4cc241266e58566645dfbbd2102030100010282010100bbe1bb116ff0bdc070df401ef00f55174cf0cf05e006976ddde845948009bc39d3d16bb4200d34e8bda9affe00cc55fb38ed21b5f1b972bde37c858a5755e5867a01aea2d34d5fc25411180e94c04d94943320c6ad64bbde7b8de4fc68adb8f461000b6a5be7608d075458bf39c7e75cb8081dd02c131f2f09f3b88920aba3a4d014cbd13a9ef985ef6be664366ae8b21c4198f582567a5b9fb751bdcd3b4e7a6e160e00a9f5aae2d80755f323fa95fff5aebc8d59b3f093efa4c28a9c42fa2628bd9d8dc19b70b396f7c26a17cb97c3bec9d482b9ae9df425c042c4d4b85d913d2b6ed72c15adccb9f0bc8f1dc6439738db75669f336e1600d4a81b05793e9102818100f61761715d8cc06b4ce8579301f083503a312be0bcc98697ba798fbcb6296cbb064e9d325f780d43ad3aebbcc64cf49b4c8a4bef9c00a72e254e7d3ed22a3e4a7afe46a1599af045a9cb0247b69763c1057b0823cec7fff3f2c9df19936a76c22e03a343b14baac0729751dbe4af83a82c9200b4e711110841cfbc6e6ad3d00b02818100d031ea9a4f7f186943de2fc4ba8050428bc23ff33f4da0d264595257ef26c980bca0a5dfe837335fa1a0bc5b57dca546e0fc584830ac12dc42842b9313865df33b55dfb461f4da95291797429a03e0e9edaf4f4166eb41543fb60a516406ff24fa750a11142720c705fed12a4675351e9304c6e0ac2900d4c40de7f1aa70070302818100eedfcd1f5cbe667d013f3adaa0f454928899f84c83145f4862a2e2ea3c2c43b5db2e6e1a5a5f4f08d55b2f3ea38249a1818f709c5a62abe4f82393216aa1c4ab496e0f2349b642ea6c2179ca20ac1d115cff8aec2f2926032735db10996eab6e5b79fe7d93d8ae1b765ff9fea7a1d2fb68a0247d7519b4ddbdfc269d4ba6e4f702818100b6f3064b6f8c29f166983ab5cf85ae01ac3a9863b2bf0e91936902790f48b04d96743d0f134a5eb4ac9d48a7a3ffdaa4fc540367fc8d594d808e10947fd5d57d4628e219eaf2759a19b00755996dcb1905aac6249cc222785c3c25b8fc0341f646b8ce8dcf7dcac9d9b4e02d1c192702a502cf98e2f06d308ad0058051db7bed0281807fc3b60f0319ff7b6339995b2286ef4fa7559c50383f2cf8af7f9c74af69b172dcb2770ec78e75e06edce4f71d1228c7a9ca5c6603f66d68577a7c9b5756e24eae64371f1ee2bbbd39ded225024f19015ace20b9715af05050a1ed1d16796c01a179656780eb58ded60dd830f872a8d3d94a91cd6c149beb1974339a833a54e3") 
    ["testASP"] 
    ["testPlc"] 
    [BString.unshow "3082010a0282010100c822fb2b7842e61fa6a779a48f2164793e21d640687146b48ac4e977a4a69f90383c94f3ea5e5336052b728f0a83151603edef890b2a6099376ae87a384a6b236ed51c7f19d94c8b4acb9b00de6cb1c6fc40ff9fec7967ebdbc48cd9b15103411a3b8978d93e59988a7baa21dd3e6fa220359e228f847b81be77bf2467bea40496135a8d06a42c3416bffec3646c8fda7eee19a74275fa2b21bfaa5c8b0dc8e82511b2d8b9a7b760b1d0ae0be03cd98615f3e6c2bc51b1ab11f5b87aad9b44264a2470f26a3a55e4dbd1fa6ea52e66093b4a3eae73bcd7237f07b1ea394a9f893b32d6da15a46f5d7e77c5a6b12ebf41cc7743f4cc241266e58566645dfbbd210203010001"] 
    True
    "ASP_SERVER:5000"
    "PubKeyServer:5000"
    "PlcServer:5000"
    "UUIDServer:5000"
    (Map.fromList String.compare [("1", "localhost:5001"), ("2", "localhost:5002")])
    (Map.fromList String.compare [("1", (BString.unshow "3082010a0282010100c822fb2b7842e61fa6a779a48f2164793e21d640687146b48ac4e977a4a69f90383c94f3ea5e5336052b728f0a83151603edef890b2a6099376ae87a384a6b236ed51c7f19d94c8b4acb9b00de6cb1c6fc40ff9fec7967ebdbc48cd9b15103411a3b8978d93e59988a7baa21dd3e6fa220359e228f847b81be77bf2467bea40496135a8d06a42c3416bffec3646c8fda7eee19a74275fa2b21bfaa5c8b0dc8e82511b2d8b9a7b760b1d0ae0be03cd98615f3e6c2bc51b1ab11f5b87aad9b44264a2470f26a3a55e4dbd1fa6ea52e66093b4a3eae73bcd7237f07b1ea394a9f893b32d6da15a46f5d7e77c5a6b12ebf41cc7743f4cc241266e58566645dfbbd210203010001")), ("2", (BString.unshow "3082010a0282010100c822fb2b7842e61fa6a779a48f2164793e21d640687146b48ac4e977a4a69f90383c94f3ea5e5336052b728f0a83151603edef890b2a6099376ae87a384a6b236ed51c7f19d94c8b4acb9b00de6cb1c6fc40ff9fec7967ebdbc48cd9b15103411a3b8978d93e59988a7baa21dd3e6fa220359e228f847b81be77bf2467bea40496135a8d06a42c3416bffec3646c8fda7eee19a74275fa2b21bfaa5c8b0dc8e82511b2d8b9a7b760b1d0ae0be03cd98615f3e6c2bc51b1ab11f5b87aad9b44264a2470f26a3a55e4dbd1fa6ea52e66093b4a3eae73bcd7237f07b1ea394a9f893b32d6da15a46f5d7e77c5a6b12ebf41cc7743f4cc241266e58566645dfbbd210203010001"))])
    ) : coq_Manifest

val aspMapping = (Map.fromList coq_ID_Type_ordering []) : ((coq_ASP_ID, coq_CakeML_ASPCallback) coq_MapC)


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

val client_am_library = 
  (Build_AM_Library 
    aspMapping aspServer_cb pubKeyServer_cb plcServer_cb uuidServer_cb) : coq_AM_Library

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
        val concreteMan = ManifestJsonConfig.retrieve_concrete_manifest () 
        val (concrete, aspDisp, plcDisp, pubKeyDisp, uuidDisp) = ManifestUtils.setup_and_get_AM_config formal_manifest client_am_library concreteMan
        val (Build_ConcreteManifest plc uuid privateKey plcMap pubKeyMap aspServer_addr pubKeyServer_addr plcServer_addr uuidServer_addr) = concrete
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
