(* Depends on: util, copland, system/sockets, am/Measurementsm am/CommTypes,
   am/ServerAm extracted/Term_Defs_Core.cml *)

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


                                                       

(* (string, string) map -> (string -> 'a option) -> ('a -> string) -> string -> 'a -> 'a *)
fun lookupOrDefault ini read write k default =
    case Map.lookup ini k of
      None => (
          TextIOExtra.printLn ("No field \"" ^ k ^ "\", defaulting to " ^ write default ^ ".");
          default
      )
    | Some v => (
        case read v of
          None => (
              TextIOExtra.printLn ("Cannot read \"" ^ k ^ "\", defaulting to " ^ write default ^ ".");
              default
          )
        | Some r => r
      )

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
     in case jsonServerAm json of 
          Err e => TextIOExtra.printLn_err e
        | Ok _ => (
            (TextIOExtra.printLn ("Starting up")); 
            (TextIOExtra.printLn (String.concat ["On port: ", portStr, "\nQueue Length: ", qLenStr]));
            loop handleIncoming (Socket.listen portInt qLenInt)
            )
    end
    handle Socket.Err s => TextIO.print_err ("Socket failure on listener instantiation: " ^ s ^ "\n")
         | Crypto.Err s => TextIO.print_err ("Crypto error: " ^ s ^ "\n")
         | _          => TextIO.print_err ("Fatal: unknown error\n")

(* () -> () *)
fun main () =
    let val json = get_json () 
        val jsonMap = json_config_to_map json
      in
        startServer jsonMap
    end

val () = main ()
