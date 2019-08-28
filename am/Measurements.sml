(* Depends on: CoplandLang.sml, ByteString.sml, crypto/Random.sml, and
   crypto/CryptoFFI.sml*)

val genHash = Crypto.hash o encodeEv

fun readFile filename =
    let val fd = TextIO.openIn filename
        val text = TextIO.inputAll fd
     in TextIO.closeIn fd;
        text
    end

val genFileHash = Crypto.hashStr o readFile

(* Gets a 128 bit (16 byte) nonce *)
val genNonce = rand

val signEv = Crypto.signMsg o encodeEv

fun verifySig g pubMod pubExp =
    case g
      of G _ ev bs => Some (Crypto.sigCheck bs (encodeEv ev) pubMod pubExp)
       | _ => None
