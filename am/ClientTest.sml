(* Depends on: CoplandLang.sml, Eval.sml, and SocketFFI.sml *)

(* val map  = Map.insert emptyNsMap O "129.237.122.162" *)
val map  = Map.insert emptyNsMap O "127.0.0.1"
(*
val nonce = N O 0 (genNonce ()) Mt
*)
val nonce = N O 0 (ByteString.fromRawString "27") Mt
val term  = AT O (LN HSH SIG)
(*val term  = AT O (LN (USM (Id O) ["hashTest.txt"]) SIG)*)

fun demoGrabSig ev =
    case ev
        of Mt => ""
        | U _ _ _ _ _ => ""
        | K _ _ _ _ _ _ => ""
        | G p e' bs => ByteString.toRawString bs
        | H _ _ => ""
        | N _ _ _ _ => ""
        | SS _ _ => ""
        | PP _ _ => ""

fun demoGrabHash ev =
    case ev
        of Mt => ""
        | U _ _ _ _ _ => ""
        | K _ _ _ _ _ _ => ""
        | G _ ev _  => ByteString.toRawString( encodeEv ev )
        | H _ _  => ""
        | N _ _ _ _ => ""
        | SS _ _ => ""
        | PP _ _ => ""

fun main () =
    let val ev = eval map nonce term
        val dSig = demoGrabSig ev
        val dHash = demoGrabHash ev
        val sHash = ByteString.toRawString (hashStr dHash)
        val pubMod = readFile "/usr/share/myKeys/thisPubMod"
        val pubExp = readFile "/usr/share/myKeys/thisPubExp"
        val payload = dSig ^ sHash ^ pubMod ^ ":" ^ pubExp ^ ":" 
        val sigResult = sigCheck payload 
     in
        print (
        (* 
        evToString ev ^ "\n" ^ 
        *)
        "Signature Check: " ^ (ByteString.show sigResult) ^ "\n"
              )
    end
    handle Socket.Err       => TextIO.print_err "Socket failure on connection\n"
         | Socket.InvalidFD => TextIO.print_err "Invalid file descriptor\n"
         | _                => TextIO.print_err "Fatal: unknown error\n"

val _ = main ()
