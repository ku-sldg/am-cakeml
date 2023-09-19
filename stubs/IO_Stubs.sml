
(** val encodeEvRaw : coq_RawEv -> coq_BS **)

fun encodeEvRaw rawev = BString.empty
  (* failwith "AXIOM TO BE REALIZED" *)

(** val do_asp :
    coq_ASP_PARAMS -> coq_RawEv -> coq_Plc -> coq_Event_ID -> coq_AM_Config
    -> (coq_BS, coq_DispatcherErrors) coq_ResultT **)

fun do_asp params e mpl _ ac =
  let val Coq_mkAmConfig _ aspCb _ _ _ _ = ac in
  aspCb params mpl (encodeEvRaw e) e end

(** val doRemote_uuid :
    coq_Term -> coq_UUID -> coq_RawEv -> (coq_RawEv, coq_CallBackErrors)
    coq_ResultT **)

fun doRemote_uuid t uuid rawEv = 
    let val authEv = []
        val authEt = Coq_mt 
    in 
      Coq_resultC (am_sendReq' t uuid (Coq_evc authEv authEt) rawEv)
    end

  (* failwith "AXIOM TO BE REALIZED" 

  fun am_sendReq' (t : coq_Term) (targUUID : coq_UUID) 
                    (authTok : coq_ReqAuthTok) (ev : (bs list))  =
  
  *)

(** val do_remote :
    coq_Term -> coq_Plc -> coq_EvC -> coq_AM_Config -> (coq_RawEv,
    coq_DispatcherErrors) coq_ResultT **)

fun do_remote t pTo e ac =
  let val remote_uuid_res =
    let val Coq_mkAmConfig _ _ _ plcCb _ _ = ac in plcCb pTo end
  in
  (case remote_uuid_res of
     Coq_errC e0 => Coq_errC e0
   | Coq_resultC uuid =>
     (case doRemote_uuid t uuid (get_bits e) of
        Coq_errC _ => Coq_errC Runtime
      | Coq_resultC v => Coq_resultC v)) end

(** val parallel_vm_thread : coq_Loc -> coq_EvC **)

fun parallel_vm_thread loc = mt_evc
  (* failwith "AXIOM TO BE REALIZED" *)



(*
(** val am_sendReq :
    coq_Term -> coq_Plc -> coq_ReqAuthTok -> coq_RawEv -> coq_RawEv **)

val am_sendReq =
  failwith "AXIOM TO BE REALIZED"

*)

(** val do_start_par_thread :
    coq_Loc -> coq_Core_Term -> coq_RawEv -> unit coq_IO **)

fun do_start_par_thread _ _ _ =
  ret ()

(** val do_wait_par_thread : coq_Loc -> coq_EvC coq_IO **)

fun do_wait_par_thread loc =
  ret (parallel_vm_thread loc)

(** val requester_bound : coq_Term -> coq_Plc -> coq_ReqAuthTok -> bool **)

fun requester_bound t p tok = True
 (* failwith "AXIOM TO BE REALIZED" *)

(** val appraise_auth_tok : coq_AppResultC -> bool **)

fun appraise_auth_tok appres = True
  (* failwith "AXIOM TO BE REALIZED" *)
