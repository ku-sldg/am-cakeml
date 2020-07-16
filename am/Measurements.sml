(* Depends on: copland/Instr.sml, crypto/CryptoFFI.sml*)

fun readFile filename =
    let val fd = TextIO.openIn filename
        val text = TextIO.inputAll fd
     in TextIO.closeIn fd;
        text
    end

(* fun dooidstring s = Crypto.doidstring s *)

fun genNonce () = Crypto.urand 16

fun hashFileUsm args = (case args of
      [fileName] => Crypto.hashFile fileName
    | _ => raise USMexpn "hashFileUsm expects a single argument"
) handle Crypto.Err => raise USMexpn "hashFileUsm failed"

fun hashDirectoryUSM args = (case args of
      [path,excludedPath] => Crypto.hashDir path excludedPath
    | [path] => Crypto.hashDir path ""
    | _ => raise USMexpn "hashDirectoryUSM expects 1 or 2 arguments"
) handle Crypto.Err => raise USMexpn "hashDirectoryUSM failed"

val usmMap = Map.fromList id_compare [(Id O, hashFileUsm),((Id (S O)),hashDirectoryUSM)]



(* Appraisal *)
fun verifySig g pub =
    case g
      of G bs ev => Some (Crypto.sigCheck pub bs (encodeEv ev))
       | _ => None
