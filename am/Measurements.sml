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

val signEv = signMsg o encodeEv

(* Placeholder *)
fun verifySigFFI msg sign pubKey = True

fun verifySig g pubKey =
    case g
      of G _ ev bs => Some (verifySigFFI (encodeEv ev) bs pubKey)
       | _ => None
