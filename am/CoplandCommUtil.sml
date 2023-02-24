
exception DispatchErr string

(* coq_Plc -> coq_Plc -> Json.json -> coq_Evidence -> (bs list) -> coq_Term -> (bs list) *)
fun socketDispatch (fromPl : coq_Plc) (toPl : coq_Plc) (json : Json.json) (et : coq_Evidence) (ev : (bs list)) (t : coq_Term) =
    let val (port, queueLength, privateKey, plcMap) = JsonConfig.extract_server_config json
        val toPlInt = (natToInt toPl) : int
        val (plc, ip, port, pubkey) = case (Map.lookup plcMap toPlInt) of
                                        None => raise DispatchErr ("Place "^ (plToString toPl) ^" not in nameserver map")
                                        | Some m => m
        val req  = (REQ fromPl toPl t et ev)
        val fd   = Socket.connect ip port
        val (RES _ _ resev) = (serverSend fd req; serverRcv fd)
     in Socket.close fd;
        resev
    end

(* coq_Term -> coq_Plc -> coq_Plc -> coq_Evidence -> (bs list) -> (bs list) *)
fun am_sendReq (t : coq_Term) (fromPl : coq_Plc) (toPl : coq_Plc) (et : coq_Evidence) (evv : (bs list)) =
    let val myJson = JsonConfig.get_json ()
        val resev = socketDispatch fromPl toPl myJson et evv t
    in
        (print ("Sent term:\n" ^ termToString t ^
                "\n\nInitial raw evidence (Sent):\n" ^
                rawEvToString evv ^ "\n\nReceived raw evidence result.\n" (* ^
                rawEvToString resev ^ "\n" *) ));
        resev
    end