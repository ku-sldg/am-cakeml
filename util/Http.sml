(* Dependencies:
 * * Extra.sml
 *)
structure Http =
struct
    val crlf = String.concat [String.str (Char.chr 13), "\n"]

    (* Request verb url httpVersion headers message *)
    datatype request = Request string string string ((string * string) list) (string option)
    (* Response httpVersion statusCode respPhrase headers message *)
    datatype response = Response string string string ((string * string) list) string

    local
        (* topline: string -> string -> string -> string
         * Forms the topline of an HTTP message from the first three
         * components.
         *)
        fun toplineToString first second third = String.concatWith " " [first, second, third]
        (* header : (string * string) -> string
         * From a pair of strings that form a header in an HTTP message.
         *)
        fun headerToString (field, value) = String.concat [field, ": ", value]
        (* generalRequestToString: string -> Request -> string
         * `generalRequestToString nl req`
         * With lines ending in `nl`, convert an HTTP request to a string.
         *)
        fun generalRequestToString nl (Request verb url version headers msgo) =
            let
                val reqLine = toplineToString verb url version
                val headerLines = String.concatWith crlf (List.map headerToString headers)
            in
                case msgo of
                  Some msg  =>
                    String.concatWith nl [reqLine, headerLines, "", msg]
                | None =>
                    String.concatWith nl [reqLine, headerLines, ""]
            end
        (* generalResponseToString: string -> reponse -> string
         * `generalResponseToString nl req`
         * With lines ending in `nl`, convert an HTTP response to a string.
         *)
        fun generalResponseToString nl (Response verb url version headers msg) =
            let
                val reqLine = toplineToString verb url version
                val headerLines = String.concatWith crlf (List.map headerToString headers)
            in
                String.concatWith nl [reqLine, headerLines, "", msg]
            end
        (* toplineFromStrings : string list -> ((string * string * string) option) * (string list)
         * From a list of lines from an HTTP preamble, parse out the top line of
         * the message and seperate it from the header lines.
         *)
        fun toplineFromStrings strs =
            case strs of
              [] => (None, [])
            | top::strs' =>
                case (String.fields (op = #" ") top) of
                  [first, second, third] => (Some (first, second, third), strs')
                | _ => (None, strs')
        (* headerFromString : string -> (string * string) option
         * From an HTTP header line, parse out the field name and value.
         *)
        fun headerFromString header =
            case (String.fields (op = #":") header) of
              [] => None
            | field::values => Some (field, snd (String.split (op = #" ") (String.concatWith ":" values)))
        (* httpFromString : string -> (string * string * string * ((string * string) list) * string) option
         * From a string, parse out an entire HTTP message.
         *)
        fun httpFromString str =
            let
                val (preamble, msgs) =
                    Pair.map id List.tl (ListExtra.span (op <> "") (StringExtra.crlfLines str))
                val message = String.concatWith crlf msgs
                val (topo, headers) = toplineFromStrings preamble
                fun accumHeaders header accumo =
                    case (headerFromString header, accumo) of
                      (_, None) => None
                    | (None, _) => None
                    | (Some (field, value), Some accum) => Some ((field, value)::accum)
            in
                case (topo, List.foldr accumHeaders (Some []) headers) of
                  (None, _) => None
                | (_, None) => None
                | (Some (first, second, third), Some hdrPairs) =>
                    Some (first, second, third, hdrPairs, message)
            end
    in
        (* requestToString: request -> string
        * Properly formats an HTTP request as a string with newlines being
        * "\r\n".
        *)
        val requestToString = generalRequestToString crlf
        (* print_request: request -> string
        * Formats an HTTP request as a string with newlines begin "\n".
        *)
        val print_request = generalRequestToString "\n"
        (* responseToString: response -> string
        * Properly formats an HTTP response as a string with newlines being
        * "\r\n".
        *)
        val responseToString = generalResponseToString crlf
        (* print_response: response -> string
        * Formats an HTTP response as a string with newlines begin "\n".
        *)
        val print_response = generalResponseToString "\n"

        (* responseFromString : string -> response option
         * Parses an HTTP response from a string.
         *)
        fun responseFromString str =
            case (httpFromString str) of
              None => None
            | Some (version, statusCode, statusPhrase, headerPairs, message) =>
                Some (Response version statusCode statusPhrase headerPairs message)
        (* requestFromString : string -> request option
         * Parses out an HTTP request from a string.
         *)
        fun requestFromString str =
            case (httpFromString str) of
              None => None
            | Some (verb, url, version, headerPairs, message) =>
                if message = ""
                then Some (Request verb url version headerPairs None)
                else Some (Request verb url version headerPairs (Some message))
    end
end
(* brief code for testing
val req1 = Http.Request "GET" "/" "HTTP/1.1" [("Host", "127.0.0.1:8543")] None
val req1Str = Http.requestToString req1
val req2 = Http.Request "GET" "/" "HTTP/1.1" [("Host", "127.0.0.1:8543")] (Some "null")
val req2Str = Http.requestToString req2
val _ =
    print (String.concat [Http.print_request req1, "\n"]);
    print (String.concat [Http.print_request req2, "\n"]);
    print (String.concat [Http.print_request (Option.valOf (Http.requestFromString req1Str)), "\n"]);
    print (String.concat [Http.print_request (Option.valOf (Http.requestFromString req2Str)), "\n"]);
*)
