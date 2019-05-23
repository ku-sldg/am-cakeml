(* Depends on: SocketFFI.sml, Json.sml, JsonToCopland.sml, CoplandToJson.sml,
               Comm.sml, and Eval.sml *)

(* string -> string, where strings are json representations *)
fun evalJson p ev = jsonToStr
                  o CoplandToJson.evidenceToJson
                  o eval p ev
                  o JsonToCopland.jsonToApdt
                  o strToJson

fun respondToMsg client = Socket.output client (
    (evalJson O Mt (Socket.inputAll client))
    handle Json.ERR s1 s2 => (TextIO.print_err ("JSON error"^s1^": "^s2^"\n");
                              "Invalid JSON/Copland term")
    )

fun handleIncoming listener =
    let val client = Socket.accept listener
     in respondToMsg client;
        Socket.close client
    end
    handle Socket.Err       => TextIO.print_err "Socket failure\n"
         | Socket.InvalidFD => TextIO.print_err "Invalid file descriptor\n"

fun startServer port qLen =
    let fun loop f x = (f x; loop f x)
     in loop handleIncoming (Socket.listen port qLen)
    end
    handle Socket.Err => TextIO.print_err "Socket failure on listener instantiation\n"
         | _          => TextIO.print_err "Fatal: unknown error\n"

fun main () =
    let val usage = "Usage: ./server portNumber queueLength\ne.g.   ./server 50000 5\n"
     in case CommandLine.arguments ()
          of [portStr, qLenStr] => (
             case (Int.fromString portStr, Int.fromString qLenStr)
               of (Some port, Some qLen) => startServer port qLen
                | _ => TextIO.print_err usage)
           | _ => TextIO.print_err usage
    end

val _ = main ()
