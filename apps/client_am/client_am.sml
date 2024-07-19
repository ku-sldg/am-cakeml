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
  let val demo_term = AM_CLI_Utils.retrieve_Client_AM_CLI_args ()
      (* TODO:  Maybe someday we refactor args *)
      (* val demo_term : coq_Term = filehash_auth_phrase *)
      val top_plc   : coq_Plc = "TOP_PLC"
      val att_plc   : coq_Plc = "P0" 
      val init_et        : coq_Evidence = Coq_nn O 
      val init_rawev : coq_RawEv = [nonce_bs]
      val attester_addr : coq_UUID = "localhost:5000"
      val appraiser_addr : coq_UUID = "localhost:5003" 
      
      val v = run_demo_client_AM demo_term top_plc att_plc init_et init_rawev attester_addr appraiser_addr in 
      (
      case v of 
        Coq_resultC ((((v'', attReqString), attRespString), appReqString), appRespString) (* (res, (_, (_, (_, _)))) *) =>
          let val _ = print ("\nSent Attestation Request: \n" ^ attReqString ^ "\n\n")
              val _ = print ("Received Attestation Response: \n" ^ attRespString ^ "\n\n")
              val _ = print ("Sent Appraisal Request: \n" ^ appReqString ^ "\n\n")
              val _ = print ("Received Appraisal Response: \n" ^ appRespString ^ "\n\n") in
               (print ("\n\nClient AM SUCCESS:  \n\n" ^ (stringify_AppResultC_json (v''))))
          end
      | Coq_errC s => raise (Exception ("Client AM FAILURE:  " ^ s))
      )
  end
  handle Exception e => TextIO.print_err e 
    | Word8Extra.InvalidHex => TextIO.print_err "BSTRING UNSHOW ERROR"
    | _          => TextIO.print_err "Fatal: unknown error!\n"

val () = main ()


(* val ((((v'', attReqString), attRespString), appReqString), appRespString) = v' *)
(* ("Sent Attestation Request: \n" ^ attReqString ^ "\n") in  *)