(* Depends on: SocketFFI.sml, Json.sml, JsonToCopland.sml, CoplandToJson.sml,
               and Eval.sml *)

(* string -> string, where strings are json representations *)
val evalJson =
    let fun strToJson str = List.hd (fst (Json.parse ([], str)))
        fun jsonToStr j   = Json.print_json j 0
     in jsonToStr
      o CoplandToJson.evidenceToJson
      o (eval O Mt)
      o JsonToCopland.jsonToApdt
      o strToJson
    end

fun respondToMsg client = Socket.output client (
    (evalJson (Socket.inputAll client))
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

(* TODO: get port num and queue length from command line *)
fun main () =
    let fun loop f x = (f x; loop f x; ())
     in loop handleIncoming (Socket.listen 50000 5)
    end
    handle Socket.Err => TextIO.print_err "Socket failure on listener instantiation\n"
         | _          => TextIO.print_err "Fatal: unknown error\n"

val _ = main ()
