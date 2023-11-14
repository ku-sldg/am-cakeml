
exception DispatchErr string

(* same as in SocketCommUtil *)
(* such entries as "localhost:5000" *)
fun decodeUUID (u : coq_UUID) = 
  (* Splits at ":" character, into (ip, port) *)
  let val colonInt = 
        case (String.findi (fn c => (Char.chr 58) = c) 0 u) of
          None => raise DispatchErr "Unable to decode UUID, no splitting ':' found"
          | Some v => v
      val ip = String.substring u 0 colonInt
      (* This is retrieving the rest of the string *)
      val port = String.extract u (colonInt + 1) None
      val port' = case Int.fromString port of
                    Some v => v
                    | None => raise DispatchErr "Unable to decode UUID, port not integer"
  in
    (ip, port')
  end

(*
    These are the two functions we need to export
    They must match, in signature, the samely named functions in SocketCommUtil
    We'll use these misnomers ("socket") here, for historical reasons :smirk:
*)

(* coq_Plc -> nsMap -> coq_Plc -> coq_ReqAuthTok -> (bs list) -> coq_Term -> (bs list) *)
fun socketDispatch (target : coq_UUID) (authTok : coq_ReqAuthTok) (ev : (bs list)) (t : coq_Term) =
    let 
        val (ip, port) = decodeUUID target
        val req  = (REQ t authTok ev)
        val _ = print ("Dispatching Request Term: \n'" ^ (termToString t) ^ "'\nTo address: " ^ ip ^ ":" ^ (Int.toString port) ^ "\n")
        val resev = sendCoplandReq req ip port
     in 
        resev
    end

(* coq_UUID -> coq_Term -> coq_Plc -> coq_Evidence -> coq_RawEv -> coq_AppResultC *)
fun socketDispatchApp (target : coq_UUID) (t : coq_Term) (p:coq_Plc) (et:coq_Evidence) (ev : coq_RawEv)  =
    let
        val (ip, port) = decodeUUID target
        val req  = (REQ_APP t p et ev)
        val _ = print ("Dispatching Appraisal Request Term: \n'" ^ (termToString t) ^ "'\nTo address: " ^ ip ^ ":" ^ (Int.toString port) ^ "\n")
        val resapp = sendCoplandAppReq req ip port
     in 
        resapp
    end

