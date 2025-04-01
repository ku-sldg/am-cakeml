

fun print_list ls = 
  case ls of 
    [] => (print "")
  | x :: ls' => let val _ = print x in (print_list ls') end

fun stringify_one_targmap_entry (x: (string * Json.json)) = 
  let val x' = (snd x) in
    case x' of 
      Json.Bool b => 
        let val s = 
          case b of 
            True => "PASSED" 
          | _ => "FAILED" in 
        String.concat ["\t", (fst x), ": ", s, "\n"] 
        end
    | _ => "" 
  end

fun list_stringify_targmap (tmap:Json.json) = 
  case tmap of 
    Json.Object (ls: (string * Json.json) list) => (List.map stringify_one_targmap_entry ls) : string list 
  | _ => []

(* tmap :: Json.json~~(Json.Object (string * Json.json) list) -> string *)
fun stringify_targmap (tmap:Json.json) = 
  let val ls = list_stringify_targmap tmap in 
    String.concat ls 
  end

fun list_stringify_appsumm (appsumm_coq_json : coq_JSON) = 
  let val appsumm_cakeml_json = (coq_JSON_to_CakeML_JSON appsumm_coq_json : (Json.json)) in
      (* val s =  *)
        case appsumm_cakeml_json of 
          Json.Object (ls : (string * Json.json) list) => (List.map (fn ((k:string), (v:Json.json)) => String.concat [k, ": ", "\n", (stringify_targmap v)]) ls) : (string list)
        | _ => [] (* TextIO.print_err "AppraisalSummary not correct JSON type\n" *)
  end

fun print_appraisal_summary (appsumm_pair : (coq_AppraisalSummary * bool)) = 
  let val (Build_Jsonifiable to_JSON _) = concrete_Jsonifiable_AppraisalSummary 
      val appsumm = fst appsumm_pair 
      val appsumm_bool = snd appsumm_pair
      val overall_string = 
        case appsumm_bool of 
          True => "PASSED"
        | _ =>    "FAILED" in 
    (
      print (String.concat ["\nAppraisal Summary: ", overall_string, "\n\n"]) ;
      print (String.concat (list_stringify_appsumm (to_JSON appsumm)));
      print "\n"
    )
  end


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
  let val (demo_term, att_sess, do_appr) = AM_CLI_Utils.retrieve_Client_AM_CLI_args ()
      (* TODO: Maybe someday we refactor args *)
      val top_plc   : coq_Plc = "TOP_PLC"
      val att_plc   : coq_Plc = "P0" 
      val init_et        : coq_EvidenceT = Coq_mt_evt (* Coq_nonce_evt O  *)
      val init_rawev : coq_RawEv = []
      val attester_addr : coq_UUID = "localhost:5000"
      val appraiser_addr : coq_UUID = "localhost:5003"
      
      (* val app_result = run_demo_client_AM demo_term top_plc att_plc init_et att_sess init_rawev attester_addr appraiser_addr  *)
      (* TODO: Current this will do basically NOTHING *)
  in 
    if do_appr 
    then
      (let val maybe_appsumm = am_client_app_summary
                              att_sess 
                              top_plc 
                              (Coq_evc [] Coq_mt_evt) 
                              demo_term
                              att_plc in 
      case maybe_appsumm of 
        Coq_resultC (appsumm, appsumm_bool) => print_appraisal_summary (appsumm, appsumm_bool)
      | Coq_errC errStr => print errStr
      end)
    else
      (case (am_sendReq att_sess top_plc (Coq_evc [] Coq_mt_evt) demo_term att_plc) of
          Coq_errC msg => 
            let 
              val _ = print "ERROR: Phrase Execution Failed!\n\n" 
              val _ = print msg
            in
              ()
            end
        | Coq_resultC rawev =>
          (* We finished correctly, print out the result evidence *)
          let 
            val _ = print "SUCCESS: Copland Phrase Executed Successfully!\n"
          in
            ()
          end)
  end
  handle Exception e => TextIO.print_err e 
          | Word8Extra.InvalidHex => TextIO.print_err "BSTRING UNSHOW ERROR"
          | _          => TextIO.print_err "Fatal: unknown error!\n"

val () = main ()