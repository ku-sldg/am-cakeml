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
        
        (* dechunk: (string list, char) parser *)
        val dechunk =
            Parser.manyTill
                (Parser.bind
                    (Parser.manyTill Parser.hexDigit Parser.crlf)
                    (fn chars =>
                        let
                            val hexStr = BString.unshow (String.implode chars)
                            val chunkLen = BString.toInt BString.BigEndian hexStr
                        in
                            Parser.bind
                                (Parser.count chunkLen Parser.anyChar)
                                (fn msgChars =>
                                    Parser.return (String.implode msgChars) Parser.crlf)
                        end))
                (Parser.string (String.concat ["0", crlf, crlf]))

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
            | Ok (version, statusCode, statusPhrase, headers, message) =>
                Ok (Response version statusCode statusPhrase headers message)

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
        
        (* responseExtractMessage: response -> (string list -> 'a) -> ('a, string) result
         *)
        fun responseExtractMessage (Response _ _ _ headers message) chunkFunc =
            if Alist.every
                (fn (field, value) =>
                    field <> "Transfer-Encoding" orelse
                    not (String.isSubstring "chunked" value))
                headers
            then Ok (chunkFunc [message])
            else Result.map chunkFunc (Parser.result (Parser.parse dechunk message))
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
(* chunked example
val chunkedEx = String.concatWith Http.crlf [
    "HTTP/1.1 200 OK",
    "Content-Type: application/json",
    "Date: Mon, 20 Sep 2021 21:51:29 GMT",
    "Transfer-Encoding: chunked",
    "",
    "d27",
    "{\"jsonrpc\":\"2.0\",\"id\":3,\"result\":\"0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000034000000000000000000000000000000000000000000000000000000000000002c47b226170707261697365724964223a20223034364442414633394445414343434235463435393439423337363942313232383446313841394446423442393135454633444436324337304632334637354439374430373332344538444539454233423933384233354345384136384446434542394237464639393341454437323646424431354631304545314132413343222c2022706872617365223a207b22636f6e7374727563746f72223a2022417474222c202264617461223a205b312c207b22636f6e7374727563746f72223a20224c736571222c202264617461223a205b7b22636f6e7374727563746f72223a2022417370222c202264617461223a205b7b22636f6e7374727563746f72223a202241737063222c202264617461223a205b312c205b2274657374446972225d5d7d5d7d2c207b22636f6e7374727563746f72223a2022417370222c202264617461223a205b7b22636f6e7374727563746f72223a2022536967227d5d7d5d7d5d7d2c2022726573756c74223a20747275652c20227369676e6174757265223a20224242464542394136443030464538314433453444334144354532333739304233333936463643333032303336443731324146313536363839454346433039383438354546463941304334313241443235393139333231424132313245393844373337324137353436463533353843343533373132303242393630393646443030222c20227461726765744964223a20223639353444463031373431374144383533433333463334343342384134334242463037343033413543334233334541414539354538343330303739413936333630433242414333463343423432303439354643314630353245453737353545434332383841323832333434323537304437423334463731323043363339344337222c202274696d657374616d70223a20313633323137343238313334383832377d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c47b226170707261697365724964223a20223034364442414633394445414343434235463435393439423337363942313232383446313841394446423442393135454633444436324337304632334637354439374430373332344538444539454233423933384233354345384136384446434542394237464639393341454437323646424431354631304545314132413343222c2022706872617365223a207b22636f6e7374727563746f72223a2022417474222c202264617461223a205b312c207b22636f6e7374727563746f72223a20224c736571222c202264617461223a205b7b22636f6e7374727563746f72223a2022417370222c202264617461223a205b7b22636f6e7374727563746f72223a202241737063222c202264617461223a205b312c205b2274657374446972225d5d7d5d7d2c207b22636f6e7374727563746f72223a2022417370222c202264617461223a205b7b22636f6e7374727563746f72223a2022536967227d5d7d5d7d5d7d2c2022726573756c74223a20747275652c20227369676e6174757265223a20224636454635373431454135374136334239453939413435324441314541354430304642313745363143343332393739314332453344443932324332383231423532434344433945423639453741414244373244353245343733393436363841383442383243353932364533433637303132393337393543363832433941463039222c20227461726765744964223a20223639353444463031373431374144383533433333463334343342384134334242463037343033413543334233334541414539354538343330303739413936333630433242414333463343423432303439354643314630353245453737353545434332383841323832333434323537304437423334463731323043363339344337222c202274696d657374616d70223a20313633323137343239393837363330387d00000000000000000000000000000000000000000000000000000000\"}",
    "",
    "0",
    "", ""]
*)
