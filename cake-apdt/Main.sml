(* Examples *)

(*
Hashing test based on the first example provided by NIST in their document
"Descriptions of SHA-256, SHA-384, and SHA-512", which can be accessed here:
    http://csrc.nist.gov/groups/STM/cavp/documents/shs/sha256-384-512.pdf
Or if the government shutdown is still going on when you read this and the NIST
website is still unavailable due to the lapse in funding, you can access it
via the wayback machine:
    https://web.archive.org/web/20130526224224/http://csrc.nist.gov/groups/STM/cavp/documents/shs/sha256-384-512.pdf
*)

val message =
    let
        val arr = Word8Array.array 3 (Word8.fromInt 0)
    in
        Word8Array.copyVec "abc" 0 3 arr 0;
        arr
    end
val evidence = H O message

fun main () = print ("Hash test: " ^ (evToString (eval O evidence HSH)) ^ "\n")
val _ = main ()
