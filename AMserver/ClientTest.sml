(* Depends on: SocketFFI.sml, Json.sml, JsonToCopland.sml, CoplandToJson.sml,
               and CoplandLang.sml *)

fun serverSend fd =
    let fun jsonToStr j = Json.print_json j 0
     in Socket.output fd
      o jsonToStr
      o CoplandToJson.apdtToJson
    end

val serverRcv =
    let fun strToJson str = List.hd (fst (Json.parse ([], str)))
     in JsonToCopland.jsonToEvidence
      o strToJson
      o Socket.inputAll
    end

fun serverEval fd copTerm = Some (serverSend fd copTerm; serverRcv fd)
    handle Socket.Err     => (TextIO.print_err "Socket error\n"; None)
         | Json.ERR s1 s2 => (TextIO.print_err ("JSON error: "^s1^": "^s2^"\n"); None)


val copTerm = NONCE

(* This version, which uses serverRcv, gives the JSON error:
   "JsonToEvidence: APDT Evidence does not begin as an AList"
   It seems this is because of the last string in the "data" list,
   which is the string "Mt" when it should be an evidence Json thing.
   This means the problem is actually in the server-side json conversion. *)
(* fun main () =
    let val fd = Socket.connect "127.0.0.1" 50000
        fun printEv ev = print ((evToString ev)^"\n")
     in Option.map printEv (serverEval fd copTerm);
        Socket.close fd
    end
    handle Socket.Err       => TextIO.print_err "Socket failure on connection\n"
         | Socket.InvalidFD => TextIO.print_err "Invalid file descriptor\n"
         | _                => TextIO.print_err "Fatal: unknown error\n" *)

fun main () =
    let val fd = Socket.connect "127.0.0.1" 50000
     in serverSend fd copTerm;
        print ((Socket.inputAll fd)^"\n");
        Socket.close fd
    end
    handle Socket.Err       => TextIO.print_err "Socket failure on connection\n"
         | Socket.InvalidFD => TextIO.print_err "Invalid file descriptor\n"
         | _                => TextIO.print_err "Fatal: unknown error\n"

val _ = main ()
