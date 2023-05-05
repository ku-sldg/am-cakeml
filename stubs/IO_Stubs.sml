(* Dependencies:  extracted/Term_Defs_Core.cml, extracted/Term_Defs.cml, 
     stubs/BS.sml, stubs, Example_Phrases_Demo_Admits.sml, 
     am/CoplandCommUtil.sml, ... (TODO: more IO dependencies?) *)

fun do_asp ps e = 
  let val asp_cb = ManifestUtils.get_ASPCallback()
      val my_plc = ManifestUtils.get_myPlc()
  in
    (* Need BS *)
    asp_cb ps my_plc (encode_RawEv e) e
  end
(* 
fun do_asp ps e =
    let val _ = print ("Running ASP with params: \n" ^ (aspParamsToString ps) ^ "\n")
        val res = 
            case ps of Coq_asp_paramsC aspid args tpl tid =>
              case (aspid = cal_ak_aspid) of    
                  True => cal_ak_asp_stub ps e              
                | _ => 
                  case (aspid = get_data_aspid) of
                      True => get_data_asp_stub ps e                
                    | _ =>
                      case (aspid = tpm_sig_aspid) of
                          True => tpm_sig_asp_stub ps e
                        | _ =>
                          case (aspid = ssl_enc_aspid) of
                              True => ssl_enc_asp_stub ps e                  
                            | _ =>
                              case (aspid = pub_bc_aspid) of
                                  True => pub_bc_asp_stub ps e                          
                                | _ => 
                                  case (aspid = store_clientData_aspid) of
                                      True => store_clientData_asp_stub ps e

                                    | _ => 
                                      case (aspid = ssl_sig_aspid) of
                                          True => ssl_sig_asp_stub ps e
                                        | _ => 
                                          case (aspid = kim_meas_aspid) of
                                              True => kim_meas_asp_stub ps e
                                            | _ =>                     
                                              (print ("Matched OTHER aspid:  " ^ aspid ^ "\n");
                                               BString.fromString "v")
    in
        res
    end *)
(* failwith "AXIOM TO BE REALIZED" *)

(** val doRemote_session : coq_Term -> coq_UUID -> coq_EvC -> coq_EvC **)

fun doRemote_session t targUUID e =
    let val _ = print ("Running doRemote_session\n") in
      Coq_evc (am_sendReq t targUUID (Coq_evc [] Coq_mt) (get_bits e)) Coq_mt
    end
  (* TODO:  Is the dummy Evidence Type value (Coq_mt) ok here? *)
  (* failwith "AXIOM TO BE REALIZED" *)

(** val parallel_vm_thread : coq_Loc -> coq_EvC **)

fun parallel_vm_thread loc = mt_evc
  (* failwith "AXIOM TO BE REALIZED" *)

(** val do_asp' : coq_ASP_PARAMS -> coq_RawEv -> coq_BS coq_IO **)

fun do_asp' params e =
  ret (do_asp params e)

(** val doRemote_session' :
    coq_Term -> coq_Plc -> coq_EvC -> coq_EvC coq_IO **)

fun doRemote_session' t pTo e =
  ret (doRemote_session t pTo e)

(** val do_start_par_thread :
    coq_Loc -> coq_Core_Term -> coq_RawEv -> unit coq_IO **)

fun do_start_par_thread _ _ _ =
  ret ()

(** val do_wait_par_thread : coq_Loc -> coq_EvC coq_IO **)

fun do_wait_par_thread loc =
    ret (parallel_vm_thread loc)


(** val requester_bound : coq_Term -> coq_Plc -> coq_ReqAuthTok -> bool **)

fun requester_bound t p tok = True

(** val appraise_auth_tok : coq_AppResultC -> bool **)

fun appraise_auth_tok appres = True
