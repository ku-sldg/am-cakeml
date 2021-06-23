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
        (* toplineParser: (string * string * string, char) parser
         * Parse the topline of an HTTP query.
         *)
        val toplineParser =
            Parser.bind
                (Parser.map
                    String.implode
                    (Parser.manyTill Parser.anyChar (Parser.char #" ")))
                (fn first =>
                    Parser.bind
                        (Parser.map
                            String.implode
                            (Parser.manyTill Parser.anyChar (Parser.char #" ")))
                        (fn second =>
                            Parser.map
                                (fn thirds => (first, second, String.implode thirds))
                                (Parser.manyTill Parser.anyChar Parser.crlf)))
        (* headerParser: (string * string, char) parser
         * Parses a header line of an HTTP query
         *)
        val headerParser =
            Parser.bind
                (Parser.map
                    String.implode
                    (Parser.manyTill
                        Parser.anyChar
                        (Parser.seq
                            (Parser.char #":")
                            (Parser.many (Parser.char #" ")))))
                (fn field =>
                    Parser.map
                        (fn values => (field, String.implode values))
                        (Parser.manyTill Parser.anyChar Parser.crlf))
        (* httpParser: (string * string * string * (string * string) list * string, char) parser
         * Parses an HTTP query.
         *)
        val httpParser =
            Parser.bind
                toplineParser
                (fn (first, second, third) =>
                    Parser.bind
                        (Parser.manyTill
                            headerParser
                            (Parser.choice [Parser.crlf, Parser.return #"\n" Parser.eof]))
                        (fn headers =>
                            Parser.map
                                (fn messages =>
                                    (first, second, third, headers, String.implode messages))
                                (Parser.choice [
                                    Parser.return [] Parser.eof,
                                    Parser.many Parser.anyChar
                                ])))
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

        (* responseFromString : string -> (response, string) result
         * Parses an HTTP response from a string.
         *)
        fun responseFromString str =
            case (Parser.result (Parser.parse httpParser str)) of
              Err msg => Err msg
            | Ok (version, statusCode, statusPhrase, headerPairs, message) =>
                Ok (Response version statusCode statusPhrase headerPairs message)
        (* requestFromString : string -> (request, string) result
         * Parses out an HTTP request from a string.
         *)
        fun requestFromString str =
            case (Parser.result (Parser.parse httpParser str)) of
              Err msg => Err msg
            | Ok (verb, url, version, headerPairs, message) =>
                if message = ""
                then Ok (Request verb url version headerPairs None)
                else Ok (Request verb url version headerPairs (Some message))
    end
end
(* testing code
val req1 = Http.Request "GET" "/" "HTTP/1.1" [("Host", "127.0.0.1:8543"), ("Content-Length", "0")] None
val req1Str = Http.requestToString req1
val req2 = Http.Request "GET" "/" "HTTP/1.1" [("Host", "127.0.0.1:8543"), ("Content-Length", "4")] (Some "null")
val req2Str = Http.requestToString req2
exception Exn string
fun okValOf xr =
    case xr of
      Ok x => x
    | Err msg => raise Exn msg
val _ =
    (print (String.concat [Http.print_request req1, "\n"]);
    print (String.concat [Http.print_request req2, "\n"]);
    print (String.concat [Http.print_request (okValOf (Http.requestFromString req1Str)), "\n"]);
    print (String.concat [Http.print_request (okValOf (Http.requestFromString req2Str)), "\n"]))
    handle Exn msg =>
            TextIO.print_err (String.concat [msg, "\n"]) *)
