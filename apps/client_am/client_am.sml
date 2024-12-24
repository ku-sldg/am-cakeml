
fun read_asp_args (filename : string) =
  let
    val file_text = TextIOExtra.readFile filename
  in
    case (Json.parse file_text) of
      Err c => Coq_errC c
    | Ok js => 
      case (cakeML_JSON_to_coq_JSON js) of
        Coq_errC c => Coq_errC c
      | Coq_resultC js =>
        let val (Build_Jsonifiable _ from_JSON) = concrete_Jsonifiable_ASP_ARGS 
        in
          from_JSON js
        end
  end
  handle TextIO.BadFileName => raise (Exception ("Error parsing global context from file: Filename '" ^ filename ^ "' does not exist\n"))








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
  let val (demo_term, att_sess, model_asp_args_file, system_asp_args_file, provision_bool) = AM_CLI_Utils.retrieve_Client_AM_CLI_args ()
      (* TODO: Maybe someday we refactor args *)
      (* val provision_bool : bool = False *)
      val top_plc   : coq_Plc = "TOP_PLC"
      val att_plc   : coq_Plc = "P0" 
      (* val model_asp_args_file = "/Users/adampetz/Documents/Spring_2023/am-cakeml/tests/DemoFiles/goldenFiles/model_args.json" *) (* List.nth argList (globContInd + 1) *)
      (* val system_asp_args_file = "/Users/adampetz/Documents/Spring_2023/am-cakeml/tests/DemoFiles/goldenFiles/system_args.json" *)
      val model_asp_args_val = 
              case read_asp_args model_asp_args_file of
                Coq_resultC v => v
              | Coq_errC c => raise (Exception ("Error parsing ASP_ARGS file: " ^ c))
      val system_asp_args_val = 
              case read_asp_args system_asp_args_file of
                Coq_resultC v => v
              | Coq_errC c => raise (Exception ("Error parsing ASP_ARGS file: " ^ c))
      (*
      val init_et        : coq_EvidenceT = Coq_mt_evt (* Coq_nonce_evt O  *)
      val init_rawev : coq_RawEv = [] (* [passed_bs] *)
      val attester_addr : coq_UUID = "localhost:5000"
      val appraiser_addr : coq_UUID = "localhost:5003" 
      *)
      
      (* val app_result = run_demo_client_AM demo_term top_plc att_plc init_et att_sess init_rawev attester_addr appraiser_addr  *)
      (* TODO: Current this will do basically NOTHING *)
  in 
  (*
      let val maybe_appsumm = am_client_app_summary
                              att_sess 
                              top_plc 
                              (Coq_evc [] Coq_mt_evt) 
                              demo_term
                              (* example_appTerm  *)
                              att_plc in 

      (* (coq_JSON_to_string (test_app_summary_compute_json appsumm)) *)
    *)

    case provision_bool of 
      True => (
        let val maybe_appsumm = am_client_app_summary
                              att_sess 
                              top_plc 
                              (Coq_evc [] Coq_mt_evt) 
                              (* demo_term *)
                              (micro_appTerm_provision model_asp_args_val system_asp_args_val)
                              (* example_appTerm  *)
                              att_plc in 

          case maybe_appsumm of 
            Coq_resultC appsumm => print (coq_JSON_to_string (test_app_summary_compute_json appsumm)) 
          | Coq_errC errStr => print errStr 
          
        end
      )
    | _ => 
    (
      let val maybe_bool = am_client_do_res 
                            att_sess 
                            top_plc 
                            att_plc 
                            (micro_resolute_model model_asp_args_val system_asp_args_val)
                            micro_resolute_statement 
                            [] in

      (*
      (att_sess : Attestation_Session) (req_plc:Plc) 
  (toPlc:Plc) (M : Model) (r:Resolute) (m:Map TargetT Evidence)
  *)
      case maybe_bool of 
        Coq_resultC b => print ("Resolute Policy check:  " ^ (if(b) then "SUCCESS" else "FAILED")) 
      | Coq_errC errStr => print errStr 
    end (* end let val maybe_bool ... *)

    )
  end (* end let val (demo_term ... *)
  handle Exception e => TextIO.print_err e 
          | Word8Extra.InvalidHex => TextIO.print_err "BSTRING UNSHOW ERROR"
          | _          => TextIO.print_err "Fatal: unknown error!\n"

val () = main ()