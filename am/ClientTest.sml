(* Depends on: CoplandLang.sml, Eval.sml, and SocketFFI.sml *)

val map   = Map.insert emptyNsMap O "127.0.0.1"
val nonce = N O 0 (genNonce ()) Mt
val term  = AT O (LN (USM (Id O) ["hashTest.txt"]) SIG)

val ev = eval map nonce term

fun main () = print (evToString ev ^ "\n")
    handle Socket.Err       => TextIO.print_err "Socket failure on connection\n"
         | Socket.InvalidFD => TextIO.print_err "Invalid file descriptor\n"
         | _                => TextIO.print_err "Fatal: unknown error\n"

val _ = main ()
