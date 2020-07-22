(* Depends on copland, sockets, am *)

(* loop : ('a -> 'b) -> 'a -> 'c *)
fun loop f x = (f x; loop f x)

val dir = "/home/uxas/ex/p2/01_Waterway/"
val hashes = Lseq (Asp (Aspc (Id O) [dir ^ "cfg_WaterwaySearch_GS.xml"])) (
             Lseq (Asp (Aspc (Id O) [dir ^ "Messages/OperatingRegion_336.xml"])) (
             Lseq (Asp (Aspc (Id O) [dir ^ "Messages/tasks/1000_LineSearch_LINE_Waterway_Deschutes.xml"]))
                  (Asp (Aspc (Id O) [dir ^ "Messages/tasks/1001_AutomationRequest_LINE_Waterway_Deschutes.xml"]))))
val term = Lseq hashes (Asp Hsh)

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
            val ev     = (evalTerm am Mt term) handle _ => Mt
            val jsonEv = jsonToStr (evToJson ev)
         in Socket.output uav jsonEv
        end
end


(* mainLoop : string -> () *)
fun mainLoop addr = let fun go () =
        let val uav = Socket.connect addr 5000
         in Socket.output uav "500";
            loop attest uav
        end
        handle Socket.Err err => ()
    in loop go () end
    handle _ => TextIO.print_err "Fatal: unknown error\n"

fun main () =
    let val usage = "Usage: ./groundstation address\ne.g.   ./groundstation 192.168.2.7\n"
     in case CommandLine.arguments () of
              [addr] => mainLoop addr
            | _ => TextIO.print_err usage
    end
val _ = main ()
