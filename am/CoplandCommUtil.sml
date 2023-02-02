
exception DispatchErr string
(* coq_Plc -> nsMap -> coq_Plc -> coq_Evidence -> (bs list) -> coq_Term -> (bs list) *)
fun socketDispatch fromPl nsMap toPl et ev t =
    let val addr = case Map.lookup nsMap toPl of
              Some a => a
            | None => raise DispatchErr ("Place "^ plToString toPl ^" not in nameserver map")
        val req  = (REQ fromPl toPl nsMap t et ev)
        val port =
            case toPl of
                (S O) => 5000
              | (S (S O)) => 5002
              | _ => 5000 (* TODO: fix this hard-coding... *)
        val fd   = Socket.connect addr port
        val (RES _ _ resev) = (serverSend fd req; serverRcv fd)
     in Socket.close fd;
        resev
    end


(* coq_Term -> coq_Plc -> coq_Plc -> coq_Evidence -> (bs list) -> (bs list) *)
fun am_sendReq t fromPl toPl et evv =
    let (* val fromPl = O *)
        val myini = get_ini ()
        val nsMap = get_ini_nsMap myini
        val resev = socketDispatch fromPl nsMap toPl et evv t
    in
        (print ("Sent term:\n" ^ termToString t ^
                "\n\nInitial raw evidence (Sent):\n" ^
                rawEvToString evv ^ "\n\nReceived raw evidence result.\n" (* ^
                rawEvToString resev ^ "\n" *) ));
        resev
    end
