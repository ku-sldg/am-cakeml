(* Depends on: CoplandLang.sml, ByteString.sml, crypto/Random.sml, and
   crypto/CryptoFFI.sml*)

val genHash = hash o encodeEv

fun readFile filename =
    let val fd = TextIO.openIn filename
        val text = TextIO.inputAll fd
     in TextIO.closeIn fd;
        text
    end

val genFileHash = hashStr o readFile

(* Gets a 128 bit (16 byte) nonce *)
val genNonce = rand
(* fun genNonce = urand 16 *)

val signEv = signMsg o encodeEv
