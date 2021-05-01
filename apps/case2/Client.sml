(* Depends on copland, sockets, am *)

(* loop : ('a -> 'b) -> 'a -> 'c *)
fun loop f x = (f x; loop f x)

datatype logType = Info | Debug | Error

(* logType -> String -> () *)
(* Add timestamp? *)
fun log lType msg = case lType of
      Info  => TextIO.print (msg ^ "\n")
    | Debug => TextIO.print (msg ^ "\n")
    | Error => TextIO.print_err (msg ^ "\n")


val protocol = Asp Sig

local
    (* Placeholder value. *)
    (* good key *)
    val priv = (ByteString.toRawString o ByteString.fromHexString)
               "2E5773B2A19A2CB05FEE44650D8DC877B3D806F74C199043657C805288CD119B"
    (* bad key *)
    (*
    val priv = (ByteString.toRawString o ByteString.fromHexString)
               "2F5773B2A19A2CB05FEE44650D8DC877B3D806F74C199043657C805288CD119B"
    *)
    val am = serverAm priv emptyNsMap
in
    (* attest : Socket.fd -> () *)
    fun attest heliAM =
        let val nonce  = N (Id O) (ByteString.fromRawString (Socket.inputAll heliAM)) Mt
            val ev     = (evalTerm am nonce protocol) handle _ => (log Error "Protocol evaluation failed"; Mt)
            val jsonEv = jsonToStr (evToJson ev)
                       ^ (String.str (Char.chr 0)) (* append explicit null-byte *)
         in log Info ("Sending evidence: " ^ evToString ev);
            Socket.output heliAM jsonEv
        end
end


(* mainLoop : string -> () *)
fun mainLoop addr port =
    let fun go () =
        let val heliAM = Socket.connect addr port
         in log Info "Connected to heliAM";
            (* Is socket connection sufficient? Or do we send an empty message? *)
            (* Socket.output heliAM ""; *)
            loop attest heliAM
        end
        handle Socket.Err err => ()
    in loop go () end
    handle _ => log Error "Fatal: unknown error"

fun main () =
    let val name  = CommandLine.name ()
        val usage = "Usage: " ^ name ^ " address port\n"
                  ^ "e.g.   " ^ name ^" 192.168.2.7 5000"
     in (case CommandLine.arguments () of
              [addr, portStr] => case Int.fromNatString portStr of
                Some port => mainLoop addr port
              | None      => TextIO.print usage
            | _ => TextIO.print usage)
         handle _ => TextIO.print usage
    end
val _ = main ()
