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

(* Json.json -> () *)
fun startServer (json : Json.json) =
    let val (port, queueLength, privateKey, plcMap) = JsonConfig.extract_pubkeyserver_config json
        val _ = TextIOExtra.printLn ("Starting up")
        val _ = TextIOExtra.printLn ("On port: " ^ (Int.toString port) ^ "\nQueue Length: " ^ (Int.toString queueLength))
    in 
      loop handleIncoming (Socket.listen port queueLength)
    end
    handle Socket.Err s => TextIO.print_err ("Socket failure on listener instantiation: " ^ s ^ "\n")
         | Crypto.Err s => TextIO.print_err ("Crypto error: " ^ s ^ "\n")
         | JsonConfig.Excn s => TextIO.print_err ("JsonConfig Error: " ^ s ^ "\n")
         | Exception s => TextIO.print_err ("EXCEPTION: " ^ s ^ "\n")
         | _          => TextIO.print_err ("Fatal: unknown error\n")

(* () -> () *)
fun main () =
    let val json = JsonConfig.get_json () 
    in
      startServer json
    end

val () = main ()
