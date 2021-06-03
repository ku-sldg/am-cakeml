(* Depends on copland, sockets, am, protocol *)

datatype logType = Info | Debug | Error

(* logType -> String -> () *)
fun log lType msg = case lType of
      Info  => TextIO.print (msg ^ "\n")
    | Debug => TextIO.print ("DEBUG: " ^ msg ^ "\n")
    | Error => TextIO.print_err (msg ^ "\n")

local
    (* Placeholder value. *)
    val priv = (ByteString.toRawString o ByteString.fromHexString)
               "2E5773B2A19A2CB05FEE44650D8DC877B3D806F74C199043657C805288CD119B"
    val am = serverAm priv emptyNsMap
in
    (* attest : Socket.fd -> () *)
    (* loops unless timeout *)
    fun attestLoop heliAM = (case Socket.inputAllTimeout heliAM of
          None => log Info "Socket read timeout"
        | Some input => (
            log Info ("Input: " ^ (ByteString.show (ByteString.fromRawString input)));
            let val nonce = N (Id O) (ByteString.fromRawString input) Mt
                val golden = ByteString.unshow (List.hd goldenHashes)
                val initEv = SS (H golden) nonce
                val ev = (evalTerm am initEv (Asp Sig))
                    handle USMexpn err => (log Error ("Usm err: " ^ err); Mt)
                         | _           => (log Error "Unknown error in protocol evaluation"; Mt)
                val jsonEv = jsonToStr (evToJson ev)
                           ^ (String.str (Char.chr 0)) (* append explicit null-byte *)
             in log Info ("Sending evidence: " ^ evToString ev);
                Socket.output heliAM jsonEv;
                attestLoop heliAM
            end
        )
    ) handle Socket.InvalidFD => log Error "Socket error: invalid file descriptor. (Connection may have been closed server-side.)"
           | Socket.Err err   => log Error ("Socket error: " ^ err)
end

(* mainLoop : string -> int -> () *)
fun mainLoop addr port = (
    (* checkRestartDtu (); *)
    whenSome (Socket.connect addr port) (fn heliAM => (
        log Info "Connected to HeliAM";
        attestLoop heliAM;
        log Info "Closing connection.";
        Socket.close heliAM
    ));
    mainLoop addr port
) handle Socket.Err err => log Error ("Socket error: " ^ err)
       | _              => log Error "Fatal: unknown error"

fun init addr port = (
    (* startDtu (); *)
    mainLoop addr port
)

fun main () =
    let val name  = CommandLine.name ()
        val usage = "Usage: " ^ name ^ " address port\n"
                  ^ "e.g.   " ^ name ^ " 192.168.2.7 5000\n"
     in (case CommandLine.arguments () of
              ["--provision"] => provisionMain ()
            | [addr, portStr] => (
                case Int.fromNatString portStr of
                  Some port => init addr port
                | None      => TextIO.print_err "Invalid port\n")
            | _ => TextIO.print usage
        ) handle _ => TextIO.print_err "Fatal: unknown error\n"
    end
val _ = main ()
