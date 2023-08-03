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
fun respondToMsg client = 
  let val inString  = Socket.inputAll client 
      val outString = handle_AM_request inString in 
    Socket.output client outString
  end
  handle Json.Exn s1 s2 =>
          (TextIO.print_err ("JSON error" ^ s1 ^ ": " ^ s2 ^ "\n"); ())
  (*| USMexpn s => (TextIO.print_err (String.concat ["USM error: ", s, "\n"]);
            "USM failure")   *)
            
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
  (* let val auth_phrase = ssl_sig_parameterized coq_P0
      val kim_phrase = Coq_att coq_P1 (kim_meas dest_plc kim_meas_targid)
      val cert_phrase = cert_style *)
  let val auth_phrase = ssl_sig_parameterized coq_P0
      val (concreteMan, privKey) = ManifestJsonConfig.retrieve_CLI_args () 
      val (concrete, privKey, aspDisp, plcDisp, pubKeyDisp, uuidDisp) = ManifestUtils.setup_and_get_AM_config formal_manifest am_library concreteMan privKey auth_phrase
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