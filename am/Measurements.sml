(* Depends on: copland/Instr.sml, crypto/CryptoFFI.sml*)

fun readFile filename =
    let val fd = TextIO.openIn filename
        val text = TextIO.inputAll fd
     in TextIO.closeIn fd;
        text
    end

(* fun dooidstring s = Crypto.doidstring s *)

fun genNonce () = Crypto.urand 16

fun hashFileUsm args = case args of
      [fileName] => Crypto.hashFile fileName
    | _ => raise USMexpn "hashFileUsm expects a single argument"

val usmMap = Map.fromList id_compare [(Id O, hashFileUsm)]

(* Appraisal *)
fun verifySig g pub =
    case g
      of G bs ev => Some (Crypto.sigCheck pub bs (encodeEv ev))
       | _ => None
