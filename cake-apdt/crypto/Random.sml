(* Depends on: crypto/Aes256Ctr.sml, crypto/CryptoFFI.sml *)

fun seed () = Aes256Ctr.init (urand 32) (urand 16)
val aes = seed ()

(* Returns 16 random bytes *)
fun rand () = Aes256Ctr.halfEncr aes
