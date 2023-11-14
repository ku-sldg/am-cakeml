
exception DispatchErr string

fun decodeUUID (u : coq_UUID) = 
  (* Splits at ":" character, into (ip, port) *)
  let val colonInt = 
        case (String.findi (fn c => (Char.chr 58) = c) 0 u) of
          None => raise Exception "Unable to decode UUID, no splitting ':' found"
          | Some v => v
      val ip = String.substring u 0 colonInt
      (* This is retrieving the rest of the string *)
      val port = String.extract u (colonInt + 1) None
      val port' = case Int.fromString port of
                    Some v => v
                    | None => raise Exception "Unable to decode UUID, port not integer"
  in
    (ip, port')
  end

fun sendCoplandReq fd req = 
  let val jsonReq = requestToJson req
      val strJsonReq = jsonToStr jsonReq
      val _ = print ("\n\n" ^ "JSON CVM request string (sendCoplandReq): \n" ^ strJsonReq ^ "\n\n") in 
        Socket.output fd strJsonReq
  end (* Socket.output fd o jsonToStr o requestToJson *)

fun receiveCoplandResp fd = 
  let val inStr = Socket.inputAll fd 
      val _ = print ("\n\n" ^ "String received (receievCoplandResp): \n" ^ inStr ^ "\n\n")
      val inStrJson = strToJson inStr 
      val resp = jsonToResponse inStrJson in 
        resp 
  end (* jsonToResponse o strToJson o Socket.inputAll *)

fun sendCoplandAppReq fd req = 
  let val jsonReq = appRequestToJson req
      val strJsonReq = jsonToStr jsonReq
      val _ = print ("\n\n" ^ "JSON APP request string (sendCoplandAppReq): \n" ^ strJsonReq ^ "\n\n") in 
        Socket.output fd strJsonReq
  end

fun receiveCoplandAppResp fd = 
  let val inStr = Socket.inputAll fd 
      val _ = print ("\n\n" ^ "String received (receievCoplandAppResp): \n" ^ inStr ^ "\n\n")
      val inStrJson = strToJson inStr 
      val resp = jsonToAppResponse inStrJson in 
        resp 
  end

(* coq_Plc -> nsMap -> coq_Plc -> coq_ReqAuthTok -> (bs list) -> coq_Term -> (bs list) *)
fun socketDispatch (target : coq_UUID) (authTok : coq_ReqAuthTok) (ev : (bs list)) (t : coq_Term) =
    let val (ip, port) = decodeUUID target
        val req  = (REQ t authTok ev)
        val _ = print ("Dispatching Request Term: \n'" ^ (termToString t) ^ "'\nTo address: " ^ ip ^ ":" ^ (Int.toString port) ^ "\n")
        val fd   = Socket.connect ip port
        val resev = (sendCoplandReq fd req; receiveCoplandResp fd)
     in Socket.close fd;
        resev
    end

(* coq_UUID -> coq_Term -> coq_Plc -> coq_Evidence -> coq_RawEv -> coq_AppResultC *)
fun socketDispatchApp (target : coq_UUID) (t : coq_Term) (p:coq_Plc) (et:coq_Evidence) (ev : coq_RawEv)  =
    let val (ip, port) = decodeUUID target
        val req  = (REQ_APP t p et ev)
        val _ = print ("Dispatching Appraisal Request Term: \n'" ^ (termToString t) ^ "'\nTo address: " ^ ip ^ ":" ^ (Int.toString port) ^ "\n")
        val fd   = Socket.connect ip port
        val resapp = (sendCoplandAppReq fd req; receiveCoplandAppResp fd)
     in Socket.close fd;
        resapp
    end
