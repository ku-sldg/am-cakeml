(* Depends on: CoplandLang.sml, ByteString.sml, crypto/Random.sml, and
   crypto/CryptoFFI.sml*)

val genHash = Crypto.hash o encodeEv

fun readFile filename =
    let val fd = TextIO.openIn filename
        val text = TextIO.inputAll fd
     in TextIO.closeIn fd;
        text
    end

(* val genFileHash = Crypto.hashStr o readFile *)
val genFileHash = Crypto.hashFile

(* fun dooidstring s = Crypto.doidstring s *)


(* val genNonce = rand *)
fun genNonce () = Crypto.urand 16

fun signEv priv = Crypto.signMsg priv o encodeEv

fun verifySig g pub =
    case g
      of G _ ev bs => Some (Crypto.sigCheck pub bs (encodeEv ev))
       | _ => None
