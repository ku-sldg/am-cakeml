
exception DispatchErr string



fun sendCoplandReq fd = Socket.output fd o jsonToStr o requestToJson
val receiveCoplandResp = jsonToResponse o strToJson o Socket.inputAll

fun decodeUUID (u : coq_UUID) = 
  (* Splits at ";" character, into (ip, port) *)
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

(* coq_Plc -> nsMap -> coq_Plc -> coq_ReqAuthTok -> (bs list) -> coq_Term -> (bs list) *)
fun socketDispatch (target : coq_UUID) (authTok : coq_ReqAuthTok) (ev : (bs list)) (t : coq_Term) =
    let val (ip, port) = decodeUUID target
        val req  = (REQ t authTok ev)
        val _ = print ("Dispatching Request Term: \n'" ^ (termToString t) ^ "'\nTo address: " ^ ip ^ ":" ^ (Int.toString port) ^ "\n")
        val fd   = Socket.connect ip port
        val (RES resev) = (sendCoplandReq fd req; receiveCoplandResp fd)
     in Socket.close fd;
        resev
    end

(* coq_Term -> coq_UUID coq_ReqAuthTok -> (bs list) -> (bs list) *)
fun am_sendReq (t : coq_Term) (targUUID : coq_UUID) (authTok : coq_ReqAuthTok) (ev : (bs list))  =
    let val _ = TextIO.print ("Received Request to Dispatch term to UUID: '" ^ targUUID ^ "'\n\n")
        val resev = socketDispatch targUUID authTok ev t
    in
        (print ("Sent term:\n" ^ termToString t ^
                "\n\nInitial raw evidence (Sent):\n" ^
                rawEvToString ev ^ "\n\nReceived raw evidence result.\n"  ^
                rawEvToString resev ^ "\n" ));
        resev
    end
