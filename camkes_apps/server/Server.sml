(* Depends on: util, copland, system/sockets, am/Measurementsm am/CommTypes,
   am/ServerAm extracted/Term_Defs_Core.cml *)

(* 
For handle_AM_request (now extracted from Coq):

When things go well, handle_AM_request returns a string response that holds an 
  encoded JSON object.  This object is either a coq_CvmResponseMessage or a 
  coq_AppraisalResponseMessage (depending on the type of JSON object encoded in 
  the request string:  coq_CvmRequestMessage vs coq_AppraisalRequestMessage). 
When things go wrong, handle_AM_request returns a raw error message string. 
  In the future, we may want to wrap said error messages in JSON as well to make 
  it easier on the client. *)

fun respondToMsg inString = 
    let 
        val ac = ManifestUtils.get_local_amConfig ()
        val nonceval = BString.fromString "anonce" (* TODO: should this be hardcoded here? *)
        val outString = handle_AM_request inString ac am_library nonceval
        val _ = print ("\n\nSending response string: \n" ^ outString)
    in 
        respondToLinux outString
    end
    handle Json.Exn s1 s2 => (TextIO.print_err ("JSON error" ^ s1 ^ ": " ^ s2 ^ "\n"); ())
            
fun handleIncoming () =
    let
        val receivedMessage = recvCoplandReqFromLinux ()
    in
        respondToMsg receivedMessage
    end
    handle
          RPCCallErr s => TextIOExtra.printLn_err ("RPC Call Error: " ^ s ^ "\n")
         | Exception s => TextIO.print_err ("EXCEPTION: " ^ s ^ "\n")

(* () -> () *)
fun startServer () =
    let val queueLength = 5 (* TODO: Hardcoded queuelength *)
        val uuid = ManifestUtils.get_myUUID()
        val (ip, port) = decodeUUID uuid
        val _ = TextIOExtra.printLn ("Starting up Server")
        val _ = TextIOExtra.printLn ("On port: " ^ (Int.toString port) ^ "\nQueue Length: " ^ (Int.toString queueLength))
    in 
    (* loop handleIncoming (Socket.listen port queueLength) *)
        loop handleIncoming ()
    end
    handle 
           (* Socket.Err s => TextIO.print_err ("Socket failure on listener instantiation: " ^ s ^ "\n") *)
          Crypto.Err s => TextIO.print_err ("Crypto error: " ^ s ^ "\n")
         | Exception s => TextIO.print_err ("EXCEPTION: " ^ s ^ "\n")
         | Json.Exn s1 s2 => TextIO.print_err ("Json Exception: " ^ s1 ^ "\n" ^ s2 ^ "\n")
         | Result.Exn => TextIO.print_err ("Result Exn:\n")
         | Undef => TextIO.print_err ("Undefined Exception:\n")

(* () -> () *)
fun main () =
    let 
        val formal_manifest_json = strToJson( FileServer.readFile "FileSystem/FormalManifest_P0.json" )
        val formal_manifest = ManifestJsonConfig.extract_Manifest formal_manifest_json
        (*
        val private_key_string = FileServer.readFile "FileSystem/PrivateKey.txt" 
        *)
        val private_key_string = "79575397755834"
        val private_key = BString.fromString private_key_string 
        val _ = ManifestUtils.setup_and_get_AM_config formal_manifest am_library private_key
        (* Retrieving implicit self place from manifest here *)
        val my_plc = ManifestUtils.get_myPlc()
        val _ = print ("My Place (retrieved from Manifest): " ^ my_plc ^ "\n\n")
    in
        startServer()
    end
    handle 
        Exception e => TextIO.print_err e 
        | ManifestUtils.Excn e => TextIO.print_err ("ManifestUtils Error: " ^ e)
        | ManifestJsonConfig.Excn e => TextIO.print_err ("ManifestUtils Error: " ^ e)
        | Word8Extra.InvalidHex => TextIO.print_err "BSTRING UNSHOW ERROR"
        | _          => TextIO.print_err "Fatal: unknown error!\n"



val () = main ()
