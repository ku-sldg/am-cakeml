(* 
For handle_AM_request (now extracted from Coq):

When things go well, handle_AM_request returns a string response that holds an 
  encoded JSON object.  This object is either a coq_CvmResponseMessage or a 
  coq_AppraisalResponseMessage (depending on the type of JSON object encoded in 
  the request string:  coq_CvmRequestMessage vs coq_AppraisalRequestMessage). 
When things go wrong, handle_AM_request returns a raw error message string. 
  In the future, we may want to wrap said error messages in JSON as well to make 
  it easier on the client. *)

(* () -> () *)
fun main () =
  let val _ = AM_CLI_Utils.retrieve_Client_AM_CLI_args ()
      (* Maybe someday we tak args *)
      val demo_term : coq_Term = filehash_auth_phrase
      val top_plc   : coq_Plc = "TOP_PLC"
      val att_plc   : coq_Plc = "P0" 
      val et        : coq_Evidence = Coq_nn O 
      val init_rawev : coq_RawEv = [passed_bs]
      val attester_addr : coq_UUID = "localhost:5000"
      val appraiser_addr : coq_UUID = "localhost:5003" 
      
      val app_result = run_demo_client_AM demo_term top_plc att_plc et init_rawev attester_addr appraiser_addr 
  in 
    ()
  end
  handle Exception e => TextIO.print_err e 
          | Word8Extra.InvalidHex => TextIO.print_err "BSTRING UNSHOW ERROR"
          | _          => TextIO.print_err "Fatal: unknown error!\n"

val () = main ()