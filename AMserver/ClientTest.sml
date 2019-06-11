(* Depends on: SocketFFI.sml, CoplandLang.sml, CommTypes.sml,
               and CommUtil.sml *)

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
