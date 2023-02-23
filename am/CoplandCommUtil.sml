
exception DispatchErr string

(* coq_Plc -> nsMap -> coq_Plc -> coq_Evidence -> (bs list) -> coq_Term -> (bs list) *)
fun socketDispatch (fromPl : coq_Plc) (jsonPlcMap : jsonPlcMap) (toPl : coq_Plc) (et : coq_Evidence) (ev : (bs list)) (t : coq_Term) =
    let val plc_specific_mapping = case (Map.lookup jsonPlcMap (plToString toPl)) of
                                    Some m => m
                                    | None => raise DispatchErr ("Place "^ (plToString toPl) ^" not in nameserver map")
        val req  = (REQ fromPl toPl jsonPlcMap t et ev)
        val addr = case (Map.lookup plc_specific_mapping "ip") of
                     Some ip => ip
                     | None => raise DispatchErr ("Place "^ (plToString toPl) ^" does not have a corresponding address in the map")
        val port = case (Map.lookup plc_specific_mapping "port") of
                    Some port => 
                        case (Int.fromString port) of
                            Some pNum => pNum
                            | None => raise DispatchErr ("Place "^ (plToString toPl) ^" has a corresponding port, but it is malformed")
                    | None =>  raise DispatchErr ("Place "^ (plToString toPl) ^" does not have a corresponding port in the map")
        val fd   = Socket.connect addr port
        val (RES _ _ resev) = (serverSend fd req; serverRcv fd)
     in Socket.close fd;
        resev
    end

(* coq_Term -> coq_Plc -> coq_Plc -> coq_Evidence -> (bs list) -> (bs list) *)
fun am_sendReq (t : coq_Term) (fromPl : coq_Plc) (toPl : coq_Plc) (et : coq_Evidence) (evv : (bs list)) =
    let val myJson = JsonConfig.get_json ()
        val jsonMap = json_config_to_map myJson
        val jsonPMap = extractJsonPlcMap jsonMap
        val resev = socketDispatch fromPl jsonPMap toPl et evv t
    in
        (print ("Sent term:\n" ^ termToString t ^
                "\n\nInitial raw evidence (Sent):\n" ^
                rawEvToString evv ^ "\n\nReceived raw evidence result.\n" (* ^
                rawEvToString resev ^ "\n" *) ));
        resev
    end