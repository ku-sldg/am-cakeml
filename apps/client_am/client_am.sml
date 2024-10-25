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
  let val (demo_term, att_sess) = AM_CLI_Utils.retrieve_Client_AM_CLI_args ()
      (* TODO: Maybe someday we refactor args *)
      val top_plc   : coq_Plc = "TOP_PLC"
      val att_plc   : coq_Plc = "P0" 
      val init_et        : coq_EvidenceT = Coq_nonce_evt O 
      val init_rawev : coq_RawEv = [passed_bs]
      val attester_addr : coq_UUID = "localhost:5000"
      val appraiser_addr : coq_UUID = "localhost:5003" 
      
      (* val app_result = run_demo_client_AM demo_term top_plc att_plc init_et att_sess init_rawev attester_addr appraiser_addr  *)
      (* TODO: Current this will do basically NOTHING *)
  in 
      let val maybe_appsumm = am_client_app_summary
                              att_sess 
                              top_plc 
                              (Coq_evc [] Coq_mt_evt) 
                              example_appTerm 
                              att_plc in 
      case maybe_appsumm of 
        Coq_resultC appsumm => print (coq_JSON_to_string (test_app_summary_compute_json appsumm)) 
      | Coq_errC errStr => print errStr 
    end
  end
  handle Exception e => TextIO.print_err e 
          | Word8Extra.InvalidHex => TextIO.print_err "BSTRING UNSHOW ERROR"
          | _          => TextIO.print_err "Fatal: unknown error!\n"

val () = main ()