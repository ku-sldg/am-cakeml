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

fun respondToMsg client = Socket.output client (evalJson (Socket.inputAll client))

fun handleIncoming listener =
    let val client = Socket.accept listener
     in respondToMsg client;
        Socket.close client
    end
    (* TODO: catch each possible exception separately, print informative error
             messages *)
    handle _ => (print "Something went wrong!\n"; ())

fun loop f x = (f x; loop f x; ())

(* TODO: get port num and queue length from command line *)
fun main () = loop handleIncoming (Socket.listen 50000 5)
val _ = main ()
