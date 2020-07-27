(* Depends on: util, copland/Instr, system/crypto *)

(* Crypto *)
fun verifySig g pub =
    case g
      of G bs ev => Some (Crypto.sigCheck pub bs (encodeEv ev))
       | _ => None

fun genNonce () = Crypto.urand 16

(* Meas *)
fun readFile filename =
    let val fd = TextIO.openIn filename
        val text = TextIO.inputAll fd
     in TextIO.closeIn fd;
        text
    end

fun hashFileUsm args = (case args of
      [fileName] => Meas.hashFile fileName
    | _ => raise USMexpn "hashFileUsm expects a single argument"
) handle Meas.Err x => raise USMexpn ("hashFileUsm failed, possibly failed to find file: " ^ x)

fun hashDirectoryUSM args = (case args of
      [path,excludedPath] => Meas.hashDir path excludedPath
    | [path] => Meas.hashDir path ""
    | _ => raise USMexpn "hashDirectoryUSM expects 1 or 2 arguments"
) handle Meas.Err x => raise USMexpn ("hashDirectoryUSM failed, , possibly failed to find directory: " ^ x)

val usmMap = Map.fromList id_compare [(Id O, hashFileUsm),((Id (S O)),hashDirectoryUSM)]

val words = String.tokens Char.isSpace
val lines = String.tokens (op = #"\n")

(* Requires root priveleges *)
fun getMaps pid =
    let fun parseAddr str =
            let val [addr1, addr2] = String.tokens (op = #"-") str
             in (addr1, addr2)
            end
        fun parsePerms str =
            (String.sub str 0 = #"r",
             String.sub str 1 = #"w",
             String.sub str 2 = #"x",
             String.sub str 3 = #"p")
        fun parseLine line = case words line of
              [addr, perms, _, _, _, name] =>
                  Some (parseAddr addr, parsePerms perms, name)
            | [addr, perms, _, _, _] =>
                  Some (parseAddr addr, parsePerms perms, "")
            | _ => None
            handle _ => None
        fun parseMaps str = List.mapPartial parseLine (lines str)
     in parseMaps (readFile ("/proc/" ^ pid ^ "/maps"))
    end

fun measProc pid = 
    let fun hashable (_, (r, w, x, _), _) = r andalso not w andalso x
        val sections = List.filter hashable (getMaps pid)
        fun hashSect ((sAddr, eAddr), _, _) = Meas.hashRegion pid sAddr eAddr
        val hashes = List.map hashSect sections
        val xored  = List.foldr (ByteString.xor) ByteString.empty hashes
     in Crypto.hash xored
    end 