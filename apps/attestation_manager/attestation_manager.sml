(* 
For handle_AM_request (now extracted from Coq):

When things go well, handle_AM_request returns a string response that holds an 
  encoded JSON object.  This object is either a coq_CvmResponseMessage or a 
  coq_AppraisalResponseMessage (depending on the type of JSON object encoded in 
  the request string:  coq_CvmRequestMessage vs coq_AppraisalRequestMessage). 
When things go wrong, handle_AM_request returns a raw error message string. 
  In the future, we may want to wrap said error messages in JSON as well to make 
  it easier on the client. *)
fun respondToMsg ammconf client nonce = 
  let val inString  = Socket.read client 
      val _ = print ("\n\nReceived request string: \n" ^ inString ^ "\n")
      val time = timestamp ()
      val _ = TextIOExtra.printLn ("Time: " ^ Int.toString time)
      (* val jsonTest = case string_to_JSON inString of
              Coq_errC msg => raise (Exception ("Error in JSON conversion " ^ msg))
            | Coq_resultC js => coq_JSON_to_string js
      val _ = print "TEsting json conversion\n"
      val _ = print ("jsonTest: " ^ jsonTest ^ "\n") *)
      val outString = handle_AM_request ammconf inString nonce
      val _ = print ("\n\nSending response string: \n" ^ outString) 
      val num_written = Socket.write client outString
  in 
    ()
  end
  handle Json.Exn s1 s2 =>
          (TextIO.print_err ("JSON error" ^ s1 ^ ": " ^ s2 ^ "\n"); ())
            
fun handleIncoming (listener_and_ammconf) =
    let val (listener, ammconf) = listener_and_ammconf
        val client = Socket.accept listener
        val _ = TextIOExtra.printLn "Accepted connection\n"
        val nonceval = passed_bs (* BString.fromString "anonce" *) (* TODO: should this be hardcoded here? *)
        val _ = respondToMsg ammconf client nonceval
        val _ = print "Responded to message\n"
    in 
      ()
      (* (respondToMsg ammconf client nonceval);
      Socket.close client *)
    end
    handle Socket.Err s     => TextIOExtra.printLn_err ("Socket failure: " ^ s)
         (* | Socket.InvalidFD => TextIOExtra.printLn_err "Invalid file descriptor" *)


(* coq_AM_Config -> unit *)
fun startServer ammconf =
    let val queueLength = 5 (* TODO: Hardcoded queuelength *)
        val (Coq_mkAM_Man_Conf man aspBin uuidStr) = ammconf
        val (ip, port) = decodeUUID uuidStr
        val _ = TextIOExtra.printLn ("Starting up Server")
        val _ = TextIOExtra.printLn ("On port: " ^ (Int.toString port) ^ "\nQueue Length: " ^ (Int.toString queueLength))
    in 
     loop handleIncoming ((Socket.listen port queueLength), ammconf)
    end
    handle Socket.Err s => TextIO.print_err ("Socket failure on listener instantiation: " ^ s ^ "\n")
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