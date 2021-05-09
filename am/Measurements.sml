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
                 

(* Hashes a group of bytestrings in an order-agnostic way (by xor-ing them together) *)
(* hashSet -> ByteString.bs list -> Bytestring.bs *)
val hashSet = Crypto.hash o List.foldr (ByteString.xor) ByteString.empty

fun hashDir path exclPath = 
   let val dirEntries  = Meas.readDirNoDot path 
       val files       = List.mapPartial (fn (n,t) => if t = Meas.Reg then Some (path^"/"^n) else None) dirEntries 
       val fileHashes  = List.map Meas.hashFile files
       val subDirs     = List.mapPartial (fn (n,t) => if t = Meas.Dir then Some (path^"/"^n) else None) dirEntries
       val filtSubDirs = List.filter (op <> exclPath) subDirs
    in hashSet (fileHashes @ List.map (flip hashDir exclPath) filtSubDirs)
   end 

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
     in hashSet hashes
    end 

fun findProc name = 
    let fun getProcDir (n,t) = if t = Meas.Dir andalso Option.isSome (Int.fromString n) then Some n else None
        val procDirs = List.mapPartial getProcDir (Meas.readDirNoDot "/proc")
        fun getStat procDir = Some (readFile ("/proc/" ^ procDir ^ "/stat")) handle _ => None
        val stats = List.mapPartial getStat procDirs
        fun parseStat stat = case String.tokens (op = #" ") stat of
              (pid :: name' :: _) => (pid, name')
        fun procMatch (pid, name') = if name' = ("(" ^ name ^ ")") then Some pid else None
     in List.mapPartial (procMatch o parseStat) stats
    end

(* Returns a list of hashes since a proc name may appear multiple times *)
val measProcsByName = List.map measProc o findProc

(* string -> ByteString.bs * string *)
fun newProcHash filepath = (Meas.hashFile filepath, Meas.newProc filepath)

(* USMs *)
fun hashFileUsm args = (case args of
      [fileName] => Meas.hashFile fileName
    | _ => raise USMexpn "hashFileUsm expects a single argument"
) handle Meas.Err x => raise USMexpn ("hashFileUsm failed, possibly failed to find file: " ^ x)

fun hashDirectoryUsm args = (case args of
      [path,excludedPath] => hashDir path excludedPath
    | [path] => hashDir path ""
    | _ => raise USMexpn "hashDirectoryUsm expects 1 or 2 arguments"
) handle Meas.Err x => raise USMexpn ("hashDirectoryUsm failed, possibly failed to find directory: " ^ x)

fun measProcsUsm args = (case args of 
      [name] => List.foldl ByteString.append ByteString.empty (measProcsByName name) 
    | _ => raise USMexpn "measProcsUsm expects a single argument"
) handle Meas.Err x => raise USMexpn ("measProcsUsm failed: " ^ x)

fun checkRestartChild pid filepath = 
    if Meas.childTerminated pid then 
        Some (newProcHash filepath)
    else 
        None

local
    (* Placeholder *)
    val vdtuPath = "/home/grant/lab/am-cakeml-case2/apps/case2/spin"
    val vdtu = Ref (ByteString.empty, "")
    fun getVdtuBinHash () = fst (!vdtu)
    fun getVdtuPid ()     = snd (!vdtu)
in 
    fun startVdtu () = (
        print "Launching VDTU\n";
        vdtu := newProcHash vdtuPath
    )

    fun checkRestartVdtu () = case checkRestartChild (getVdtuPid ()) vdtuPath of
          Some newVdtu => (
              TextIO.print_err "VDTU terminated, restarting\n";
              vdtu := newVdtu
          )
        | _ => ()

    fun measVdtuUsm args = (case args of 
          [] => ByteString.append (getVdtuBinHash ()) (measProc (getVdtuPid ()))
        | _  => raise USMexpn "meas_vdtu expects 0 arguments"
    ) handle Meas.Err x => raise USMexpn ("measVdtuUsm failed: " ^ x)
           | _          => raise USMexpn  "measVdtuUsm failed"
end

val usmMap = Map.fromList id_compare [
    (Id O, hashFileUsm),
    (Id (S O), hashDirectoryUsm),
    (Id (S (S O)), measProcsUsm),
    (Id (S (S (S O))), measVdtuUsm)
]