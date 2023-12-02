(*
Top Level file for dispatch functions
Some platform-dependent functions implemented in PosixCommUtil.sml and seL4CommUtil.sml
*)
exception DispatchErr string

(* coq_Term -> coq_UUID -> coq_ReqAuthTok -> (bs list) -> (bs list) *)
fun am_sendReq' (t : coq_Term) (targUUID : coq_UUID) (authTok : coq_ReqAuthTok) (ev : (bs list))  =
    let val _ = TextIO.print ("Received Request to Dispatch term to UUID: '" ^ targUUID ^ "'\n\n")
        val resev = networkDispatch targUUID authTok ev t
    in
        (print ("Sent term:\n" ^ termToString t ^
                "\n\nInitial raw evidence (Sent):\n" ^
                rawEvToString ev ^ "\n\nReceived raw evidence result.\n"  ^
                rawEvToString resev ^ "\n" ));
        resev
    end

(* coq_Term -> coq_Plc -> coq_ReqAuthTok -> (bs list) -> (bs list) *)
fun am_sendReq (t : coq_Term) (targPlc : coq_Plc) (authTok : coq_ReqAuthTok) (ev : (bs list)) =
  let val res_uuid = ManifestUtils.get_PlcCallback() targPlc in 
    case res_uuid of 
        Coq_errC e => [] (* raise Excn ("get_PlcCallback() error")  *)
      | Coq_resultC uuid => am_sendReq' t uuid authTok ev 
  end

(* coq_UUID -> coq_Term -> coq_Plc -> coq_Evidence -> coq_RawEv -> coq_AppResultC *)
fun am_sendReq'_app (targUUID : coq_UUID) (t : coq_Term) (p:coq_Plc) (et:coq_Evidence) (ev : coq_RawEv)  =
    let val _ = TextIO.print ("Received Request to Dispatch Appraisal term to UUID: '" ^ targUUID ^ "'\n\n")
        val resapp = networkDispatchApp targUUID t p et ev 
    in
        (print ("Sent Appraisal term:\n" ^ termToString t ^
                "\n\nInitial raw evidence (Sent):\n" ^
                rawEvToString ev ^ "\n\nReceived AppRes result:\n"  ^
                (evidenceCToString resapp) ^ "\n" ));
        resapp
    end

(* coq_Term -> coq_Plc -> coq_Evidence -> coq_RawEv -> coq_AppResultC *)
fun am_sendReq_app (t : coq_Term) (targPlc:coq_Plc) (et:coq_Evidence) (ev : coq_RawEv) =
  let val res_uuid = ManifestUtils.get_PlcCallback() targPlc
      val _ = print "\n\n EXECUTING am_sendReq_app \n\n" in 
      case res_uuid of 
        Coq_errC e => Coq_mtc_app (* raise Excn ("get_PlcCallback() error")  *)
      | Coq_resultC uuid => am_sendReq'_app uuid t targPlc et ev
  end

(*

(** fun am_sendReq_app :
    coq_Term -> coq_Plc -> coq_Evidence -> coq_RawEv -> coq_AppResultC **)

fun am_sendReq_app t p et ev = am_sendReq_app t p et ev 

*)
