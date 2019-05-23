(* Depends on: SocketFFI.sml, Json.sml, JsonToCopland.sml, CoplandToJson.sml,
               Comm.sml, and CoplandLang.sml *)

fun serverSend fd = Socket.output fd o jsonToStr o CoplandToJson.apdtToJson

val serverRcv = JsonToCopland.jsonToEvidence o strToJson o Socket.inputAll

fun serverEval fd copTerm = Some (serverSend fd copTerm; serverRcv fd)
    handle Socket.Err     => (TextIO.print_err "Socket error\n"; None)
         | Json.ERR s1 s2 => (TextIO.print_err ("JSON error: "^s1^": "^s2^"\n"); None)


val copTerm = NONCE

fun main () =
    let val fd = Socket.connect "127.0.0.1" 50000
        fun printEv ev = print ((evToString ev)^"\n")
     in Option.map printEv (serverEval fd copTerm);
        Socket.close fd
    end
    handle Socket.Err       => TextIO.print_err "Socket failure on connection\n"
         | Socket.InvalidFD => TextIO.print_err "Invalid file descriptor\n"
         | _                => TextIO.print_err "Fatal: unknown error\n"

val _ = main ()
