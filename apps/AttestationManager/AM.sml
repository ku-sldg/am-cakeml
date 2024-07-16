(* 
For handle_AM_request (now extracted from Coq):

When things go well, handle_AM_request returns a string response that holds an 
  encoded JSON object.  This object is either a coq_CvmResponseMessage or a 
  coq_AppraisalResponseMessage (depending on the type of JSON object encoded in 
  the request string:  coq_CvmRequestMessage vs coq_AppraisalRequestMessage). 
When things go wrong, handle_AM_request returns a raw error message string. 
  In the future, we may want to wrap said error messages in JSON as well to make 
  it easier on the client. *)
fun respondToMsg client nonce ac = 
  let val inString  = Socket.inputAll client 
      val _ = print ("\n\nReceived request string: \n" ^ inString ^ "\n")
      (* val jsonTest = case string_to_JSON inString of
              Coq_errC msg => raise (Exception ("Error in JSON conversion " ^ msg))
            | Coq_resultC js => coq_JSON_to_string js
      val _ = print "TEsting json conversion\n"
      val _ = print ("jsonTest: " ^ jsonTest ^ "\n") *)
      val outString = handle_AM_request inString ac nonce
      val _ = print ("\n\nSending response string: \n" ^ outString) 
  in 
    Socket.output client outString
  end
  handle Json.Exn s1 s2 =>
          (TextIO.print_err ("JSON error" ^ s1 ^ ": " ^ s2 ^ "\n"); ())
            
fun handleIncoming (listener_and_ac) =
    let val (listener, ac) = listener_and_ac
        val client = Socket.accept listener
        val _ = TextIOExtra.printLn "Accepted connection\n"
        val nonceval = passed_bs (* BString.fromString "anonce" *) (* TODO: should this be hardcoded here? *)
    in 
      (respondToMsg client nonceval ac);
      Socket.close client
    end
    handle Socket.Err s     => TextIOExtra.printLn_err ("Socket failure: " ^ s)
         | Socket.InvalidFD => TextIOExtra.printLn_err "Invalid file descriptor"


(* coq_AM_Config -> unit *)
fun startServer ac =
    let val queueLength = 5 (* TODO: Hardcoded queuelength *)
        val (Coq_mkAmConfig man _ _ _ uuidCb _) = ac 
        val (Build_Manifest my_plc _ _ _ _ _ _) = man 
        val uuid = case uuidCb my_plc of
                      Coq_resultC u => u
                    | Coq_errC s => raise Exception ("UUID lookup error: Could not find own UUID in AM Config")
        val (ip, port) = decodeUUID uuid
        val _ = TextIOExtra.printLn ("Starting up Server")
        val _ = TextIOExtra.printLn ("On port: " ^ (Int.toString port) ^ "\nQueue Length: " ^ (Int.toString queueLength))
    in 
     loop handleIncoming ((Socket.listen port queueLength), ac)
    end
    handle Socket.Err s => TextIO.print_err ("Socket failure on listener instantiation: " ^ s ^ "\n")
         | Exception s => TextIO.print_err ("EXCEPTION: " ^ s ^ "\n")
         | Json.Exn s1 s2 => TextIO.print_err ("Json Exception: " ^ s1 ^ "\n" ^ s2 ^ "\n")
         | Result.Exn => TextIO.print_err ("Result Exn:\n")
         | Undef => TextIO.print_err ("Undefined Exception:\n")

(* () -> () *)
fun main () =
  let val option_ServerAM_Args = AM_CLI_Utils.retrieve_CLI_args () in
  (
    case option_ServerAM_Args of 
      None => (* CLient Case.  TODO: use something better than option type here *)
      let val demo_term : coq_Term = filehash_auth_phrase
          val top_plc   : coq_Plc = "TOP_PLC"
          val att_plc   : coq_Plc = "P0" 
          val et        : coq_Evidence = Coq_nn O 
          val init_rawev : coq_RawEv = [passed_bs]
          val attester_addr : coq_UUID = "localhost:5000"
          val appraiser_addr : coq_UUID = "localhost:5003" 
          
          val app_result = run_demo_client_AM demo_term top_plc att_plc et init_rawev attester_addr appraiser_addr in 
            ()
      end

      | Some (manifest, am_lib, aspBin, priv_key) => 

        let val ac = manifest_compiler manifest am_lib aspBin
            (* Retrieving implicit self place from manifest here *)
            val (Coq_mkAmConfig man _ _ _ _ _) = ac 
            val (Build_Manifest my_plc _ _ _ _ _ _) = man 
            val _ = print ("My Place (retrieved from Manifest): " ^ my_plc ^ "\n\n")
          in
            startServer ac
        end
        handle Exception e => TextIO.print_err e 
                | Word8Extra.InvalidHex => TextIO.print_err "BSTRING UNSHOW ERROR"
                | _          => TextIO.print_err "Fatal: unknown error!\n"
  )
  end

val () = main ()