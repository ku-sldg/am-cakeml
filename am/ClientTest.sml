(* Depends on: CoplandLang.sml, Eval.sml, and SocketFFI.sml *)

val map  = Map.insert emptyNsMap O "127.0.0.1"
val term = AT O HSH

fun main () = print (evToString (eval map Mt term) ^ "\n")
    handle Socket.Err       => TextIO.print_err "Socket failure on connection\n"
         | Socket.InvalidFD => TextIO.print_err "Invalid file descriptor\n"
         | _                => TextIO.print_err "Fatal: unknown error\n"

val _ = main ()
