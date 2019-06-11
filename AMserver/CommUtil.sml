(* Depends on: SocketFFI.sml, Json.sml, CommTypes.sml, JsonToCopland.sml,
               CoplandToJson.sml, and CoplandLang.sml *)

fun strToJson str = List.hd (fst (Json.parse ([], str)))
fun jsonToStr js  = Json.print_json js 0

fun serverSend fd = Socket.output fd o jsonToStr o CoplandToJson.requestToJson

val serverRcv = JsonToCopland.jsonToResponse o strToJson o Socket.inputAll

fun serverEval fd req = Some (serverSend fd req; serverRcv fd)
    handle Socket.Err     => (TextIO.print_err "Socket error\n"; None)
         | Json.ERR s1 s2 => (TextIO.print_err ("JSON error: "^s1^": "^s2^"\n"); None)


exception DispatchErr string

fun dispatchAt req =
    let val (REQ _ pl map _ _) = req
        val addr = case Map.lookup map pl
                     of Some a => a
                      | None => raise DispatchErr ("No address associated with place "^(plToString pl))
        val fd = Socket.connect addr 50000
        val (RES _ _ ev) = (serverSend fd req; serverRcv fd)
     in Socket.close fd;
        ev
    end
