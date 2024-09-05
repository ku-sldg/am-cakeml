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
  let val (demo_term, att_sess, attester_UUID, appraiser_UUID, from_plc, to_plc) = AM_CLI_Utils.retrieve_Client_AM_CLI_args ()
      (* TODO: Maybe someday we refactor args *)
      (* Defaults:
          attester_UUID = "localhost:5000"
          appraiser_UUID = "localhost:5003"
          from_plc = "TOP_PLC"
          to_plc = "P0"
      *)
      val init_et        : coq_Evidence = Coq_nn O 
      val init_rawev : coq_RawEv = [passed_bs]
      
      val app_result = run_demo_client_AM 
                        demo_term 
                        from_plc 
                        to_plc 
                        init_et 
                        att_sess 
                        init_rawev 
                        attester_UUID 
                        appraiser_UUID
  in 
    ()
  end
  handle Exception e => TextIO.print_err e 
          | Word8Extra.InvalidHex => TextIO.print_err "BSTRING UNSHOW ERROR"
          | _          => TextIO.print_err "Fatal: unknown error!\n"

val () = main ()