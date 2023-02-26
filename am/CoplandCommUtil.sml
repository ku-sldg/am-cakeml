
exception DispatchErr string

(* coq_Plc -> nsMap -> coq_Plc -> coq_Evidence -> (bs list) -> (bs list) -> coq_Term -> (bs list) *)
fun socketDispatch (fromPl : coq_Plc) (pmap : JsonConfig.PlcMap) (toPl : coq_Plc) (authEt : coq_Evidence) (authEv : (bs list)) (ev : (bs list)) (t : coq_Term) =
    let val (id,ip,port,pubkey) = case (Map.lookup pmap (natToInt toPl)) of
                                    Some m => m
                                    | None => raise DispatchErr ("Place "^ (plToString toPl) ^" not in nameserver map")
        val req  = (REQ fromPl toPl pmap t authEt authEv ev)
        val fd   = Socket.connect ip port
        val (RES _ _ resev) = (serverSend fd req; serverRcv fd)
     in Socket.close fd;
        resev
    end

(* coq_Term -> coq_Plc -> coq_Plc -> coq_Evidence -> (bs list) -> (bs list) -> (bs list) *)
fun am_sendReq (t : coq_Term) (fromPl : coq_Plc) (toPl : coq_Plc) (authEt : coq_Evidence) (authEv : (bs list))  (ev : (bs list)) =
    let val json = JsonConfig.get_json ()
        val (port, queueLength, privKey, plcMap) = JsonConfig.extract_client_config json
        val resev = socketDispatch fromPl plcMap toPl authEt authEv ev t
    in
        (print ("Sent term:\n" ^ termToString t ^
                "\n\nInitial raw evidence (Sent):\n" ^
                rawEvToString ev ^ "\n\nReceived raw evidence result.\n" (* ^
                rawEvToString resev ^ "\n" *) ));
        resev
    end
