(* Depends on copland, sockets, am *)

(* loop : ('a -> 'b) -> 'a -> 'c *)
fun loop f x = (f x; loop f x)

(* TODO: add timestamp *)
fun log s = print (s^"\n")

val dir      = "/home/uxas/ex"
val exclDir  = "/home/uxas/ex/p2/01_Waterway/RUNDIR_WaterwaySearch_GS"
val dirMeas  = Asp (Aspc (Id (S O)) [dir,exclDir])
val procMeas = Asp (Aspc (Id (S (S O))) ["uxas"])
val term = Lseq dirMeas (Lseq procMeas (Asp Sig))

local
    (* This is obviously a placeholder value. In a real system, we'd want to
       define this key in a local configuration file. *)
    val priv = (ByteString.toRawString o ByteString.fromHexString)
               "2E5773B2A19A2CB05FEE44650D8DC877B3D806F74C199043657C805288CD119B"
    val am = serverAm priv emptyNsMap
in
    (* attest : Socket.fd -> () *)
    fun attest uav =
        let val nonce  = N (Id O) (ByteString.fromRawString (Socket.inputAll uav)) Mt
            val ev     = (evalTerm am nonce term) handle _ => Mt
            val jsonEv = jsonToStr (evToJson ev)
         in log ("Send evidence: " ^ evToString ev);
            Socket.output uav jsonEv
        end
end


(* mainLoop : string -> () *)
fun mainLoop addr =
    let fun go () =
        let val uav = Socket.connect addr 5000
         in log "Connected to uav";
            Socket.output uav "500";
            loop attest uav
        end
        handle Socket.Err err => ()
    in loop go () end
    handle _ => TextIO.print_err "Fatal: unknown error\n"

fun main () =
    let val name  = CommandLine.name ()
        val usage = "Usage: " ^ name ^ " address\n"
                  ^ "e.g.   " ^ name ^" 192.168.2.7\n"
     in case CommandLine.arguments () of
              [addr] => mainLoop addr
            | _ => TextIO.print_err usage
    end
val _ = main ()
