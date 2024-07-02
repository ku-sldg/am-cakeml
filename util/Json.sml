structure Json =
struct
    datatype json =
          Null
        | Int int
        | Float Word64.word
        | Bool bool
        | String string
        | Array (json list)
        | Object ((string * json) list)
    local
        (* trueParser: (json, char) parser
         * Parses the JSON boolean literal `true`.
         *)
        val trueParser =
            Parser.map (const (Bool True)) (Parser.string "true")
        (* falseParser: (json, char) parser
         * Parses the JSON boolean literal `false`.
         *)
        val falseParser =
            Parser.map (const (Bool False)) (Parser.string "false")
        (* nullParser: (json, char) parser
         * Parses the JSON object literal `null`.
         *)
        val nullParser =
            Parser.map (const Null) (Parser.string "null")
        (* signParser: (char, char) parser
         * Parses an optional numeric sign '+' or '-', defaulting to '+'.
         *)
        val signParser =
            Parser.option #"+" (Parser.oneOf [#"+", #"-"])
        (* signFunc: char -> string -> string
         * `signFunc c str`
         * If `c` is '+', then return `str`. Otherwise return `"-" ^ str`.
         *)
        fun signFunc signChr numStr =
            if signChr = #"+" then numStr else String.concat ["-", numStr]
        (* digit1_9 : (string, char) parser
         * Parses a non-zero decimal digit and turns it into a string.
         *)
        val digit1_9 =
            Parser.map
                String.str
                (Parser.satisfy (fn c => Char.<= #"1" c andalso Char.<= c #"9"))
        (* intPartParser: (string, char) parser
         * Parses the unsigned integer part of a number which has no leading
         * zeros.
         *)
        val intPartParser =
            Parser.label
                "Error parsing integer part of a JSON number."
                (Parser.choice [
                    Parser.bind
                        digit1_9
                        (fn d =>
                            Parser.map
                                (fn ds => String.concat [d, String.implode ds])
                                (Parser.many Parser.digit)),
                    Parser.map String.str (Parser.char #"0")
                ])
        (* exponPartParser: string -> (string, char) parser
         * Takes the mantissa part of a number, and returns a parser that
         * consumes an optional exponential part.
         *)
        fun exponPartParser mantissa =
            Parser.label "Error parsing exponential part of a JSON number"
                (Parser.map
                    (fn expon => String.concat [mantissa, "e", expon])
                    (Parser.seq
                        (Parser.oneOf [#"e", #"E"])
                        (Parser.bind signParser
                            (fn signChar =>
                                Parser.map
                                    (fn exponChars =>
                                        signFunc signChar (String.implode exponChars))
                                    (Parser.many1 Parser.digit)))))
        (* fracPartParser: string -> ((string, string) result, char) parser
         * Parses the fractional part and exponential part of a number, i.e.
         * the part starting with '.' or 'e'/'E'. The given string is the
         * integer part of the number. The result returned upon a successful
         * parse is either a string representation of a float wrapped as an Ok
         * value or an a string representation of an integer wrapped as an Err
         * value.
         *)
        fun fracPartParser intPart =
            Parser.label "Error parsing fractional part of a JSON number."
                (Parser.map
                    (fn number => Ok number)
                    (Parser.choice [
                        Parser.seq (Parser.char #".")
                            (Parser.bind
                                (Parser.map String.implode (Parser.many Parser.digit))
                                (fn fracPart =>
                                    let
                                        val mantissa = String.concat [intPart, ".", fracPart]
                                    in
                                        Parser.option mantissa
                                            (exponPartParser mantissa)
                                    end)),
                        exponPartParser intPart
                    ]))
        (* numberParser: (json, char) parser
         * Parses a JSON number value without backtracking by first consuming
         * any integer part and then splitting into a result datatype depending
         * upon the occurrence of '.', 'e', or 'E'.
         *)
        val numberParser =
            let
                fun toJson numr =
                    case numr of
                      Ok doubleStr =>
                        Ok (Float (Double.toWord (Double.fromString doubleStr)))
                    | Err intStr =>
                        case Int.fromString intStr of
                          None => Err "Error reading integer."
                        | Some n => Ok (Int n)
            in
                Parser.bindResult toJson
                    (Parser.bind (Parser.option #"+" (Parser.char #"-"))
                        (fn signChar =>
                            (Parser.label "Error reading a JSON number" (Parser.choice [
                                Parser.bind intPartParser
                                    (fn intPart =>
                                        Parser.option (Err (signFunc signChar intPart))
                                            (fracPartParser (signFunc signChar intPart))),
                                Parser.map
                                    (fn fracPart =>
                                        Ok (signFunc signChar fracPart))
                                    (Parser.seq (Parser.char #".")
                                        (Parser.bind
                                            (Parser.map String.implode (Parser.many1 Parser.digit))
                                            (fn fracPart =>
                                                let
                                                    val mantissa = String.concat [".", fracPart]
                                                in
                                                    Parser.option mantissa
                                                            (exponPartParser mantissa)
                                                end)))
                            ]))))
            end
        (* quoteParser: (char, char) parser
         * Parses the '"' character.
         *)
        val quoteParser = Parser.char #"\""
        (* backslash: char; the '/' character *)
        val backslash = Char.chr 92
        (* bslashParser: (char, char) parser
         * Parses the backslash character.
         *)
        val bslashParser = Parser.char backslash
        (* hexits4: (string, char) parser
         * Parses four hexadecimal numerals.
         *)
        val hexits4 =
            Parser.label
                "Error parsing hex numerals of control character in a JSON string value."
                (Parser.map String.implode (Parser.count 4 Parser.hexDigit))
        (* controlCharParser: (string, char) parser
         * Parses control characters from JSON string literals.
         *)
        val controlCharParser =
            Parser.label
                "Error parsing control character in a JSON string value."
                (Parser.seq bslashParser 
                    (Parser.choice [
                        Parser.map (const "\"") quoteParser,
                        Parser.map (const (String.str backslash)) bslashParser,
                        Parser.map (const "/") (Parser.char #"/"),
                        Parser.map
                            (const (String.str (Char.chr 8)))
                            (Parser.char #"b"),
                        Parser.map
                            (const (String.str (Char.chr 9)))
                            (Parser.char #"t"),
                        Parser.map 
                            (const (String.str (Char.chr 10)))
                            (Parser.char #"n"),
                        Parser.map 
                            (const (String.str (Char.chr 12)))
                            (Parser.char #"f"),
                        Parser.map 
                            (const (String.str (Char.chr 13)))
                            (Parser.char #"r"),
                        Parser.map
                            (fn hexits => String.concat ["\\u", hexits])
                            (Parser.seq (Parser.char #"u") hexits4)
                    ]))
        (* stringCharParser: (string, char) parser
         * Parses a character in a JSON string literal
         *)
        val stringCharParser =
            Parser.label
                "Error parsing character in a JSON string value."
                (Parser.choice [
                    Parser.map String.str (Parser.noneOf [#"\"", backslash]),
                    controlCharParser
                ])
        (* stringParserHelper: (string, char) parser
         * Parses a JSON string.
         *)
        val stringParserHelper =
            Parser.map (fn strs => String.concat strs)
                (Parser.between quoteParser quoteParser
                    (Parser.many stringCharParser))
        (* stringParser: (json, char) parser
         * Parses a JSON string literal.
         *)
        val stringParser =
            Parser.map (fn str => String str) stringParserHelper
        (* jsonParser: (json, char) parser
         * Parses a JSON value.
         *)
        fun jsonParser stream =
            Parser.label "Error parsing JSON value."
                (Parser.seq (Parser.spaces)
                    (Parser.bind
                        (Parser.choice [
                            trueParser, falseParser, nullParser,
                            Parser.label "Error parsing JSON number value." numberParser,
                            Parser.label "Error parsing JSON string value." stringParser,
                            Parser.label "Error parsing JSON array value." arrayParser,
                            Parser.label "Error parsing JSON object value." objParser])
                        (fn json => Parser.return json Parser.spaces)))
                stream
        (* arrayParser: (json, char) parser
         * Parses a JSON array literal.
         *)
        and arrayParser stream =
            Parser.map (fn jsons => Array jsons)
                (Parser.between
                    (Parser.seq (Parser.char #"[") Parser.spaces)
                    (Parser.char #"]")
                    (Parser.sepBy jsonParser (Parser.char #",")))
                stream
        (* keyValParser: ((string, json), string) parser
         * Parses a JSON key-value pair.
         *)
        and keyValParser stream =
            Parser.bind stringParserHelper
                (fn key => Parser.seq
                            (Parser.seq Parser.spaces (Parser.char #":"))
                            (Parser.map (fn value => (key, value))
                                jsonParser))
                stream
        (* objParser: (json, char) parser
         * Parses a JSON object literal.
         *)
        and objParser stream =
            Parser.map
                (fn strJsons => Object strJsons)
                (Parser.between
                    (Parser.seq (Parser.char #"{") Parser.spaces)
                    (Parser.char #"}")
                    (Parser.sepBy
                        keyValParser
                        (Parser.seq (Parser.char #",") Parser.spaces)))
                stream
        (* parseSingleton: (json, char) parser
         * Parses exactly one JSON object.
         *)
        val parseSingleton =
            Parser.bind jsonParser
                (fn js => Parser.return js Parser.eof)
        (* parseMultiple: (json list, char) parser
         * Parsers zero or more JSON objects.
         *)
        val parseMultiple =
            Parser.bind (Parser.many jsonParser)
                (fn jss => Parser.return jss Parser.eof)
    in
        (* parse: string -> (json, string) result
         * Parses a JSON value from the given string. Expects exactly one JSON
         * value.
         *)
        fun parse str = Parser.parse parseSingleton str
        (* parseMany: string -> (json list, string) result
         * Parses zero or more JSON values from the given string.
         *)
        fun parseMany str = Parser.parse parseMultiple str
    end
    (* stringify: json -> string
     * Converts the given JSON value to its string representation.
     *)
    fun stringify xJson =
        let
            fun escFn c =
                case Char.ord c of
                   8 => "\\b"
                |  9 => "\\t"
                | 10 => "\\n"
                | 12 => "\\f"
                | 13 => "\\r"
                | 34 => "\\\""
                | _ => String.str c
            fun escapeString str =
                String.concat (List.map escFn (String.explode str))
        in
            case xJson of
            Null => "null"
            | Bool b => if b then "true" else "false"
            | Int n =>
                if n >= 0
                then Int.toString n
                else String.concat ["-", Int.toString (~n)]
            | Float r => Double.toString (Double.fromWord r)
            | String str => String.concat ["\"", escapeString str, "\""]
            | Array jsons =>
                let
                    val body = String.concatWith "," (List.map stringify jsons)
                in
                    String.concat ["[", body, "]"]
                end
            | Object strJsons =>
                let
                    val fields =
                        List.map
                            (fn (str, json) =>
                                String.concat ["\"", escapeString str,
                                                "\":", stringify json])
                            strJsons
                    val body = String.concatWith "," fields
                in
                    String.concat ["{", body, "}"]
                end
        end
    (* null: json
     * JSON `null` value.
     *)
    val null = Null
    (* fromBool: bool -> json
     * Converts a boolean to its corresponding JSON value
     *)
    fun fromBool b = Bool b
    (* fromInt: int -> json
     * Converts an integer to its corresponding JSON value.
     *)
    fun fromInt n = Int n
    (* fromDouble: Word64.word -> json
     * Converts a double to its corresponding JSON value.
     *)
    fun fromDouble r = Float r
    (* fromString: string -> json
     * Converts a string to its corresponding JSON value.
     *)
    fun fromString str = String str
    (* fromList: json list -> json
     * Converts a list of JSON values
     *)
    fun fromList xs = Array xs
    (* fromPairList: (string * json) list -> json
     * Converts a list of pairs of strings and json values into a JSON value.
     *)
    fun fromPairList xys = Object xys
    (* isNull: json -> bool
     * Determines whether the JSON value is a null.
     *)
    fun isNull xJson =
        case xJson of
          Null => True
        | _ => False
    (* toBool: json -> bool option
     * Tries to convert a JSON to a boolean.
     *)
    fun toBool xJson =
        case xJson of
          Bool b => Some b
        | _ => None
    (* toInt: json -> int option
     * Tries to convert a JSON to a integer.
     *)
    fun toInt xJson =
        case xJson of
          Int n => Some n
        | _ => None
    (* toDouble: json -> Word64.word option
     * Tries to convert a JSON to a double.
     *)
    fun toDouble xJson =
        case xJson of
          Float d => Some d
        | _ => None
    (* toString: json -> string option
     * Tries to convert a JSON value to a string.
     *)
    fun toString json =
        case json of
          String str => Some str
        | _ => None
    (* toList: json -> (json list) option
     * Tries to convert a JSON to a list of JSON values.
     *)
    fun toList xJson =
        case xJson of
          Array xJsons => Some xJsons
        | _ => None
    (* toPairList: json -> ((string * json) list) option
     * Tries to convert a JSON to a list of pairs of strings and JSON values.
     *)
    fun toPairList xJson =
        case xJson of
          Object xJsonm => Some xJsonm
        | _ => None



    (* lookup: string -> json -> json option
     * `lookup str json`
     * Tries to lookup the key `str` in the JSON value `json`.
     *)
    fun lookup key xJson =
      let fun lookup_aux key jsons = case jsons of
                                      [] => None
                                    | (k, v) :: t =>
                                            if (key = k)
                                            then Some v
                                            else lookup_aux key t
      in
        case xJson of
          Object xJsonm => lookup_aux key xJsonm
        | _ => None
      end
    
    fun insert xJson key value =
        case xJson of
          Object xJsonm => Some (Object ((key, value) :: xJsonm))
        | _ => None
    exception Exn string string
end

(* val emptyObject = Json.Object (Map.empty String.compare)
val jsonNulls = ["null", " null", "  null", "null ", "\nnull\n"]
val jsonBools = ["true", "false"]
val jsonInts = ["0", "-1", "2"]
val jsonFloats = ["0.0", "1.", "-.1", "2e2", "3.14e-2", "4.5E+6"]
val jsonStrings = ["\"hello\"", "\"\\\\\"", "\"\n\"", "\"\\t\"", "\"\\u0000\"", "\"😈\""]
val jsonArrays = ["[]", "[ ]", "[ 0 , null, []]"]
val jsonObjs = ["{}", "{ }", "{ \"id\" : 1, \"result\": {} }"]
fun parseValidJson xStr xJson =
    case Json.parse xStr of
      Err msg => print
                    (String.concatWith "\n"
                        ["Error parsing the following string:", xStr, msg, ""])
    | Ok yJson =>
        if xJson = yJson
        then print (String.concatWith "\n"
                        ["Parsed the following string correctly.",
                        Json.stringify xJson, ""])
        else print (String.concatWith "\n"
                        ["Parsed the following string incorrectly.", xStr,
                        " was parsed as ", Json.stringify yJson,
                        " but expected ", Json.stringify xJson, ""])
fun parseValidJsons strs jsons =
    case (strs, jsons) of
      ([], []) => ()
    | ([], json::jsons') => print "Not enough strings to parse.\n"
    | (str::strs', []) => print "Too many strings to parse.\n"
    | (str::strs', json::jsons') =>
        (parseValidJson str json; parseValidJsons strs' jsons')
fun main () =
    (parseValidJsons jsonNulls (List.genlist (const Json.null) 5);
    parseValidJsons jsonBools (List.map Json.fromBool [True, False]);
    parseValidJsons jsonInts (List.map Json.fromInt [0, ~1, 2]);
    parseValidJsons jsonFloats (List.map (Json.fromDouble o Double.fromString) jsonFloats);
    parseValidJsons jsonStrings (List.map Json.fromString
                                    ["hello", String.str (Char.chr 92),
                                    String.str (Char.chr 10),
                                    String.str (Char.chr 9),
                                    "\\u0000", "😈"]);
    parseValidJson "[]" (Json.fromList []);
    parseValidJsons jsonArrays ([Json.fromList [], Json.fromList [], Json.fromList [Json.fromInt 0, Json.null, Json.fromList []]]);
    parseValidJsons jsonObjs ([emptyObject, emptyObject, Json.fromPairList [("id", Json.fromInt 1), ("result", emptyObject)]]))

val _ = main () *)
