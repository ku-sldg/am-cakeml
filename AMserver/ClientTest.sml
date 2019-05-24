(* Depends on: SocketFFI.sml, Json.sml, JsonToCopland.sml, CoplandToJson.sml,
               Comm.sml, and CoplandLang.sml *)

fun serverSend fd = Socket.output fd o jsonToStr o CoplandToJson.requestToJson

val serverRcv = JsonToCopland.jsonToResponse o strToJson o Socket.inputAll

fun serverEval fd req = Some (serverSend fd req; serverRcv fd)
    handle Socket.Err     => (TextIO.print_err "Socket error\n"; None)
         | Json.ERR s1 s2 => (TextIO.print_err ("JSON error: "^s1^": "^s2^"\n"); None)


val copTerm = NONCE
val req = REQ O O emptyNsMap copTerm Mt

fun main () =
    let val fd = Socket.connect "127.0.0.1" 50000
        fun printEv (RES _ _ ev) = print ((evToString ev)^"\n")
     in Option.map printEv (serverEval fd req);
        Socket.close fd
    end
    handle Socket.Err       => TextIO.print_err "Socket failure on connection\n"
         | Socket.InvalidFD => TextIO.print_err "Invalid file descriptor\n"
         | _                => TextIO.print_err "Fatal: unknown error\n"

val _ = main ()
