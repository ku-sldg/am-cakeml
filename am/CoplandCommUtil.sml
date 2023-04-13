
exception DispatchErr string



fun sendCoplandReq fd = Socket.output fd o jsonToStr o requestToJson
val receiveCoplandResp = jsonToResponse o strToJson o Socket.inputAll

(* coq_Plc -> nsMap -> coq_Plc -> coq_ReqAuthTok -> (bs list) -> coq_Term -> (bs list) *)
fun socketDispatch (fromPl : coq_Plc) (pmap : JsonConfig.PlcMap) (toPl : coq_Plc) (authTok : coq_ReqAuthTok) (ev : (bs list)) (t : coq_Term) =
    let val (id,ip,port,pubkey) = case (Map.lookup pmap toPl) of
                                    Some m => m
                                    | None => raise DispatchErr ("Place "^ (plToString toPl) ^" not in nameserver map")
        val req  = (REQ fromPl toPl t authTok ev)
        val _ = print ("Dispatching Request Term: \n'" ^ (termToString t) ^ "'\nTo address: " ^ ip ^ ":" ^ (Int.toString port) ^ "\n")
        val fd   = Socket.connect ip port
        val (RES _ _ resev) = (sendCoplandReq fd req; receiveCoplandResp fd)
     in Socket.close fd;
        resev
    end

(* coq_Term -> coq_Plc -> coq_Plc -> coq_ReqAuthTok -> (bs list) -> (bs list) *)
fun am_sendReq (t : coq_Term) (fromPl : coq_Plc) (toPl : coq_Plc) (authTok : coq_ReqAuthTok) (ev : (bs list)) =
    let val json = JsonConfig.get_json ()
        val (port, queueLength, privKey, plcMap) = JsonConfig.extract_client_config json
        val resev = socketDispatch fromPl plcMap toPl authTok ev t
    in
        (print ("Sent term:\n" ^ termToString t ^
                "\n\nInitial raw evidence (Sent):\n" ^
                rawEvToString ev ^ "\n\nReceived raw evidence result.\n"  ^
                rawEvToString resev ^ "\n" ));
        resev
    end
