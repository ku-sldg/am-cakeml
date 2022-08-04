(* Depends on: util, copland, system/sockets, am/Measurements, am/CommTypes,
   am/ServerAm *)

(* val priv = BString.unshow "2E5773B2A19A2CB05FEE44650D8DC877B3D806F74C199043657C805288CD119B" *)

(* TODO: When things go well, this returns a JSON evidence string. When they go
   wrong, it returns a raw error message string. In the future, we may want to
   wrap said error messages in JSON as well to make it easier on the client. *)
(* evalJson: am -> string -> string
 * `evalJson am input`
 * Evaluates the `input` as a stringified JSON representation of a Copland
 * phrase. Returns the stringified JSON representation of the evidence
 * generated.
 *)
fun evalJson am s =
    let val (REQ pl1 pl2 map t ev) = jsonToRequest (strToJson s)
        val ev' = evalTerm am ev t
        val response = RES pl2 pl1 ev'
     in jsonToStr (responseToJson response)
    end
    handle Json.Exn s1 s2 =>
            (TextIO.print_err (String.concat ["JSON error ", s1, ": ", s2, "\n"]);
            "Invalid JSON/Copland term")
        | USMexpn s =>
            (TextIO.print_err (String.concat ["USM error: ", s, "\n"]);
            "USM failure")

(* handleIncoming: am -> Socket.sockfd -> ()
 * `handleIncoming am listener`
 * Handles of incoming connections to the attestation manager.
 *)
fun handleIncoming am listener =
    let val client = Socket.accept listener
    in
        Socket.output client (evalJson am (Socket.inputAll client));
        Socket.close client
    end
    handle Socket.Err s     => TextIO.print_err (String.concat ["Socket failure: ", s, "\n"])
        | Socket.InvalidFD => TextIO.print_err "Invalid file descriptor\n"

(* startServer: (string, string) map -> unit
 * `startServer globalMap`
 * Starts an attestation manager service using the configuration values in 
 * `globalMap`.
 *)
fun startServer globalMap =
    let
        val porto = Option.mapPartial Int.fromString (Map.lookup globalMap "port")
        val qLeno = Option.mapPartial Int.fromString (Map.lookup globalMap "queueLength")
        val amr = iniServerAm globalMap
    in
        case (porto, qLeno, amr) of
          (None, _, _) =>
            TextIO.print_err "Could not find port number to bind on.\n"
        | (_, None, _) =>
            TextIO.print_err "Could not find queue length to use.\n"
        | (_, _, Err msg) =>
            TextIO.print_err (String.concatWith "\n" ["Error creating attestation manager object:", msg, ""])
        | (Some port, Some qLen, Ok am) =>
            loop (handleIncoming am) (Socket.listen port qLen)
    end
    handle Socket.Err s => TextIO.print_err ("Socket failure on listener instantiation: " ^ s ^ "\n")
         | Crypto.Err s => TextIO.print_err ("Crypto error: " ^ s ^ "\n")
         | _          => TextIO.print_err "Fatal: unknown error\n"

fun main () =
    let val name  = CommandLine.name ()
        val usage = String.concat ["Usage: ", name, " iniConfigFile\n",
                                    "e.g.   ", name, " config.ini\n"]
     in case CommandLine.arguments () of
          [iniFileName] => (
            (case parseIniFile iniFileName of
              Err msg =>
                TextIO.print_err (String.concat ["Error parsing ini file: ", msg, "\n"])
            | Ok configMap => startServer configMap))
        | _ => TextIO.print_err usage
    end
val _ = main ()
