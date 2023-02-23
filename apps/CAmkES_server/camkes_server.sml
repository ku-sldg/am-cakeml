(* Depends on: util, copland, system/sockets, am/Measurementsm am/CommTypes,
   am/ServerAm extracted/Term_Defs_Core.cml *)

(* term_policy_check_good :: Coq_Term (extracted/Term_Defs_Core.cml/) -> bool *)
fun term_policy_check_good p termIn = privPolicy p termIn (* TODO: invoke policy code here *)

(* When things go well, this returns a JSON evidence string. When they go wrong,
   it returns a raw error message string. In the future, we may want to wrap
   said error messages in JSON as well to make it easier on the client. *)
fun evalJson s =       (* jsonToStr (responseToJson (RES O O [])) *)
    let val (REQ pl1 pl2 map t et ev') = jsonToRequest (strToJson s)
        val ev = ev'
        val resev = run_am_serve_auth_tok_req t pl1 pl2 ev' et
    in jsonToStr (responseToJson (RES pl2 pl1 resev))
    end
    handle Json.Exn s1 s2 =>
           (TextIO.print_err (String.concat ["JSON error", s1, ": ", s2, "\n"]);
            "Invalid JSON/Copland term")

fun respondToMsg client = Socket.output client (evalJson (Socket.inputAll client))

fun handleIncoming listener =
    let val client = Socket.accept listener
     in respondToMsg client;
        Socket.close client
    end
    handle Socket.Err s     => TextIOExtra.printLn_err ("Socket failure: " ^ s)
         | Socket.InvalidFD => TextIOExtra.printLn_err "Invalid file descriptor"

(* (string, string) map -> () *)
fun startServer (json : (string, Json.json) map) =
    let val portStr = jsonLookupValueOrDefault json "port" "5000"
        val portInt = case Int.fromString portStr of
                        Some pVal => pVal
                        | None => raise Undef (* TODO *)
                          (* raise (Undef "Port is not a integer") *)
        val qLenStr = jsonLookupValueOrDefault json "queueLength" "5"
        val qLenInt = case Int.fromString qLenStr of
                        Some qval => qval
                        | None => raise Undef
                        (* raise (Undef "Queue Length is not a integer") *)
     in case jsonServerAm json  of 
          Err e => TextIOExtra.printLn_err e
        | Ok _ => loop handleIncoming (Socket.listen portInt qLenInt)
    end
    handle Socket.Err s => TextIO.print_err ("Socket failure on listener instantiation: " ^ s ^ "\n")
         | Crypto.Err s => TextIO.print_err ("Crypto error: " ^ s ^ "\n")
         | Exception s => TextIO.print_err ("EXCEPTION: " ^ s ^ "\n")
         | _          => TextIO.print_err "Fatal: unknown error\n"

fun example_server () = "" ^
"{\n" ^
"  \"port\": \"5000\",\n" ^
"  \"queueLength\": \"5\",\n" ^
"  \"privateKey\": \"308204bf020100300d06092a864886f70d0101010500048204a9308204a5" ^
"0201000282010100c822fb2b7842e61fa6a779a48f2164793e21d640687146b48ac4e977a4a69f90" ^
"383c94f3ea5e5336052b728f0a83151603edef890b2a6099376ae87a384a6b236ed51c7f19d94c8b" ^
"4acb9b00de6cb1c6fc40ff9fec7967ebdbc48cd9b15103411a3b8978d93e59988a7baa21dd3e6fa2" ^
"20359e228f847b81be77bf2467bea40496135a8d06a42c3416bffec3646c8fda7eee19a74275fa2b" ^
"21bfaa5c8b0dc8e82511b2d8b9a7b760b1d0ae0be03cd98615f3e6c2bc51b1ab11f5b87aad9b4426" ^
"4a2470f26a3a55e4dbd1fa6ea52e66093b4a3eae73bcd7237f07b1ea394a9f893b32d6da15a46f5d" ^
"7e77c5a6b12ebf41cc7743f4cc241266e58566645dfbbd2102030100010282010100bbe1bb116ff0" ^
"bdc070df401ef00f55174cf0cf05e006976ddde845948009bc39d3d16bb4200d34e8bda9affe00cc" ^
"55fb38ed21b5f1b972bde37c858a5755e5867a01aea2d34d5fc25411180e94c04d94943320c6ad64" ^
"bbde7b8de4fc68adb8f461000b6a5be7608d075458bf39c7e75cb8081dd02c131f2f09f3b88920ab" ^
"a3a4d014cbd13a9ef985ef6be664366ae8b21c4198f582567a5b9fb751bdcd3b4e7a6e160e00a9f5" ^
"aae2d80755f323fa95fff5aebc8d59b3f093efa4c28a9c42fa2628bd9d8dc19b70b396f7c26a17cb" ^
"97c3bec9d482b9ae9df425c042c4d4b85d913d2b6ed72c15adccb9f0bc8f1dc6439738db75669f33" ^
"6e1600d4a81b05793e9102818100f61761715d8cc06b4ce8579301f083503a312be0bcc98697ba79" ^
"8fbcb6296cbb064e9d325f780d43ad3aebbcc64cf49b4c8a4bef9c00a72e254e7d3ed22a3e4a7afe" ^
"46a1599af045a9cb0247b69763c1057b0823cec7fff3f2c9df19936a76c22e03a343b14baac07297" ^
"51dbe4af83a82c9200b4e711110841cfbc6e6ad3d00b02818100d031ea9a4f7f186943de2fc4ba80" ^
"50428bc23ff33f4da0d264595257ef26c980bca0a5dfe837335fa1a0bc5b57dca546e0fc584830ac" ^
"12dc42842b9313865df33b55dfb461f4da95291797429a03e0e9edaf4f4166eb41543fb60a516406" ^
"ff24fa750a11142720c705fed12a4675351e9304c6e0ac2900d4c40de7f1aa70070302818100eedf" ^
"cd1f5cbe667d013f3adaa0f454928899f84c83145f4862a2e2ea3c2c43b5db2e6e1a5a5f4f08d55b" ^
"2f3ea38249a1818f709c5a62abe4f82393216aa1c4ab496e0f2349b642ea6c2179ca20ac1d115cff" ^
"8aec2f2926032735db10996eab6e5b79fe7d93d8ae1b765ff9fea7a1d2fb68a0247d7519b4ddbdfc" ^
"269d4ba6e4f702818100b6f3064b6f8c29f166983ab5cf85ae01ac3a9863b2bf0e91936902790f48" ^
"b04d96743d0f134a5eb4ac9d48a7a3ffdaa4fc540367fc8d594d808e10947fd5d57d4628e219eaf2" ^
"759a19b00755996dcb1905aac6249cc222785c3c25b8fc0341f646b8ce8dcf7dcac9d9b4e02d1c19" ^
"2702a502cf98e2f06d308ad0058051db7bed0281807fc3b60f0319ff7b6339995b2286ef4fa7559c" ^
"50383f2cf8af7f9c74af69b172dcb2770ec78e75e06edce4f71d1228c7a9ca5c6603f66d68577a7c" ^
"9b5756e24eae64371f1ee2bbbd39ded225024f19015ace20b9715af05050a1ed1d16796c01a17965" ^
"6780eb58ded60dd830f872a8d3d94a91cd6c149beb1974339a833a54e3\",\n" ^
"  \"plcs\": {\n" ^
"    \"1\": {\n" ^
"      \"id\": \"1\",\n" ^
"      \"ip\": \"127.0.0.1\",\n" ^
"      \"port\": \"5000\",\n" ^
"      \"publicKey\": \"3082010a0282010100c822fb2b7842e61fa6a779a48f2164793e21d64" ^
"0687146b48ac4e977a4a69f90383c94f3ea5e5336052b728f0a83151603edef890b2a6099376ae87" ^
"a384a6b236ed51c7f19d94c8b4acb9b00de6cb1c6fc40ff9fec7967ebdbc48cd9b15103411a3b897" ^
"8d93e59988a7baa21dd3e6fa220359e228f847b81be77bf2467bea40496135a8d06a42c3416bffec" ^
"3646c8fda7eee19a74275fa2b21bfaa5c8b0dc8e82511b2d8b9a7b760b1d0ae0be03cd98615f3e6c" ^
"2bc51b1ab11f5b87aad9b44264a2470f26a3a55e4dbd1fa6ea52e66093b4a3eae73bcd7237f07b1e" ^
"a394a9f893b32d6da15a46f5d7e77c5a6b12ebf41cc7743f4cc241266e58566645dfbbd210203010" ^
"001\"\n" ^
"    },\n" ^
"    \"2\": {\n" ^
"      \"id\": \"2\",\n" ^
"      \"ip\": \"127.0.0.1\",\n" ^
"      \"port\": \"5002\",\n" ^
"      \"publicKey\": \"3082010a0282010100c822fb2b7842e61fa6a779a48f2164793e21d64" ^
"0687146b48ac4e977a4a69f90383c94f3ea5e5336052b728f0a83151603edef890b2a6099376ae87" ^
"a384a6b236ed51c7f19d94c8b4acb9b00de6cb1c6fc40ff9fec7967ebdbc48cd9b15103411a3b897" ^
"8d93e59988a7baa21dd3e6fa220359e228f847b81be77bf2467bea40496135a8d06a42c3416bffec" ^
"3646c8fda7eee19a74275fa2b21bfaa5c8b0dc8e82511b2d8b9a7b760b1d0ae0be03cd98615f3e6c" ^
"2bc51b1ab11f5b87aad9b44264a2470f26a3a55e4dbd1fa6ea52e66093b4a3eae73bcd7237f07b1e" ^
"a394a9f893b32d6da15a46f5d7e77c5a6b12ebf41cc7743f4cc241266e58566645dfbbd210203010" ^
"001\"\n" ^
"    }\n" ^
"  }\n" ^
"}\n" ^
"";

(* () -> () *)
fun main () =
    let val json = case (parseJsonText (example_server ())) of
                    Err e => let val _ = TextIOExtra.printLn_err e in
                                json.null
                             end
                    | Ok json => json
        val jsonMap = json_config_to_map json
      in
        startServer jsonMap
    end
        
val () = main ()