(* 
For handle_AM_request (now extracted from Coq):

When things go well, handle_AM_request returns a string response that holds an 
  encoded JSON object.  This object is either a coq_CvmResponseMessage or a 
  coq_AppraisalResponseMessage (depending on the type of JSON object encoded in 
  the request string:  coq_CvmRequestMessage vs coq_AppraisalRequestMessage). 
When things go wrong, handle_AM_request returns a raw error message string. 
  In the future, we may want to wrap said error messages in JSON as well to make 
  it easier on the client. *)
fun respondToMsg ammconf socket nonce = 
  let val inString  = SocketFFI.recv socket 
      val _ = print ("\n\nReceived request string: \n" ^ inString ^ "\n")
      val time = timestamp ()
      val _ = TextIOExtra.printLn ("Time: " ^ Int.toString time)
      val outString = handle_AM_request ammconf inString nonce
      val _ = print ("\n\nSending response string: \n" ^ outString) 
      val num_sent = SocketFFI.send socket outString
      val _ = print ("Response sent")
  in 
    ()
  end
  handle Json.Exn s1 s2 =>
          (TextIO.print_err ("JSON error" ^ s1 ^ ": " ^ s2 ^ "\n"); ())
            
fun handleIncoming (socket_and_ammconf) =
    let val (socket, ammconf) = socket_and_ammconf
        val _ = TextIOExtra.printLn "Waiting for request\n"
        val nonceval = passed_bs (* BString.fromString "anonce" *) (* TODO: should this be hardcoded here? *)
        val _ = respondToMsg ammconf socket nonceval
        val _ = print "Responded to message\n"
    in 
      ()
    end
    handle SocketFFI.Exception s     => TextIOExtra.printLn_err ("Socket failure: " ^ s)


(* coq_AM_Config -> unit *)
fun startServer ammconf =
    let val (Coq_mkAM_Man_Conf man aspBin uuidStr) = ammconf
        val (ip, port) = decodeUUID uuidStr
        val _ = TextIOExtra.printLn ("Starting up Server")
        val _ = TextIOExtra.printLn ("On port: " ^ (Int.toString port))
        val _ = SocketFFI.init ()
        val socket = SocketFFI.listen port
        val _ = TextIOExtra.printLn ("Server listening on socket")
    in 
     loop handleIncoming (socket, ammconf)
    end
    handle SocketFFI.Exception s => TextIO.print_err ("Socket failure on server startup: " ^ s ^ "\n")
         | Exception s => TextIO.print_err ("EXCEPTION: " ^ s ^ "\n")
         | Json.Exn s1 s2 => TextIO.print_err ("Json Exception: " ^ s1 ^ "\n" ^ s2 ^ "\n")
         | Result.Exn => TextIO.print_err ("Result Exn:\n")
         | Undef => TextIO.print_err ("Undefined Exception:\n")

(* () -> () *)
fun main () =
  let val ammconf = AM_CLI_Utils.retrieve_Server_AM_CLI_args ()
  in
    startServer ammconf
  end
  handle Exception e => TextIO.print_err e 
          | Word8Extra.InvalidHex => TextIO.print_err "BSTRING UNSHOW ERROR"
          | _          => TextIO.print_err "Fatal: unknown error!\n"

val () = main ()