(** val am_check_auth_tok :
    coq_Term -> coq_Plc -> coq_ReqAuthTok -> coq_AppResultC coq_AM **)

fun am_check_auth_tok t fromPl authTok = case authTok of
  Coq_evc auth_ev auth_et =>
  bind
    (case requester_bound t fromPl authTok of
       True => gen_appraise_AM auth_et auth_ev
     | False => am_failm (Coq_am_error errStr_requester_bound)) ret

(** val am_serve_auth_tok_req :
    coq_Term -> coq_Plc -> coq_Plc -> coq_ReqAuthTok -> coq_RawEv ->
    coq_AM_Config -> coq_RawEv coq_AM **)

fun am_serve_auth_tok_req t fromPl myPl authTok init_ev ac =
  bind (am_check_auth_tok t fromPl authTok) (fn v =>
    (let val _ = (print "\n\nGot past am_check_auth_tok in am_serve_auth_tok_req\n\n") in 
      case appraise_auth_tok v of
        True =>
        (case privPolicy coq_Eq_Class_ID_Type fromPl t of
          True => 
            (let val resev = (run_cvm_rawEv t myPl init_ev ac) 
                 val _ = print ("\nCVM rawev result: " ^ (rawEvToString resev)) in 
                  ret (resev)
              end)
        | False => am_failm (Coq_am_error errStr_privPolicy))
      | False => am_failm (Coq_am_error errStr_app_auth_tok)
    end))

(** val run_am_server_auth_tok_req :
    coq_Term -> coq_Plc -> coq_Plc -> coq_ReqAuthTok -> coq_RawEv ->
    coq_AM_Config -> coq_RawEv **)

fun run_am_server_auth_tok_req t fromPlc myPl authTok init_ev ac =
  run_am_app_comp (am_serve_auth_tok_req t fromPlc myPl authTok init_ev ac)
    [] True

(** val do_cvm_session :
    coq_CvmRequestMessage -> coq_AM_Config -> coq_CvmResponseMessage **)

fun do_cvm_session req ac =
  let val REQ t tok ev = req in
  run_am_server_auth_tok_req t default_place default_place tok ev ac end

(** val do_appraisal_session :
    coq_AppraisalRequestMessage -> coq_AppraisalResponseMessage **)

fun do_appraisal_session appreq = case appreq of
  REQ_APP t p et ev =>
  let val expected_et = eval t p et in
  let val comp = gen_appraise_AM expected_et ev in
  run_am_app_comp comp Coq_mtc_app True end end

(** val handle_AM_request : coq_StringT -> coq_AM_Config -> coq_StringT **)

fun handle_AM_request s ac =
  let val js = strToJson s in
  let val am_req = jsonToAmRequest js in
  let val json_resp =
    case am_req of
      CVM_REQ r =>
      let val cvm_resp = do_cvm_session r ac in responseToJson cvm_resp end
    | APP_REQ appreq =>
      let val app_resp = do_appraisal_session appreq in
      appResponseToJson app_resp end
  in
  jsonToStr json_resp end end end
