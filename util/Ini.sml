
local
    (* Import definitions *)
    val pure  = Parser.pure
    val bind  = Parser.bind
    val bind_ = Parser.seq

    (* (char, char) parser *)
    val identChar = Parser.choice [Parser.alphaNum, Parser.char #"_", Parser.char #"-", Parser.char #"'"]

    (* (string, char) parser *)
    val ident = 
        bind Parser.letter (fn c =>
        bind (Parser.many identChar) (fn cs =>
        pure (String.implode (c :: cs))
        ))

    (* (string, char) parser *)
    val identifier = Parser.token ident

    (* (char, char) parser -> (string, char) parser *)
    fun implodeMany p = Parser.map String.implode (Parser.many p)
in
    (* ((), char) parser *)
    val commentP = Parser.token (
        bind_ (Parser.symbol ";") (
        bind_ (Parser.many (Parser.notChar #"\n")) (
        pure ()
        ))
    )

    (* (string * string, char) parser *)
    val keyValP = 
        bind  identifier (fn k =>
        bind_ (Parser.symbol "=") (
        bind  (Parser.token (implodeMany (Parser.notChar #"\n"))) (fn v =>
        pure (k, StringExtra.dropWhileEnd Char.isSpace v)
        )))

    (* (string, char) parser *)
    val sectionP = Parser.token (
        Parser.between (Parser.symbol "[") (Parser.symbol "]")
            (implodeMany (Parser.notChar #"]")))

    (* ((string * string) list, char) parser *)
    (* for some reason, we get a value restriction error if explicit type annotation
     * is not present.
     *)
    val keyValBlockP : ((string * string) list, char) Parser.parser =
        Parser.map ListExtra.filterSome (Parser.many (Parser.choice [
            Parser.map OptionExtra.some keyValP,
            Parser.return None commentP
        ]))

    (* ((string * string) list, char) parser *)
    val sectionBlockP = 
        bind sectionP (fn sec =>
        bind keyValBlockP (fn alist =>
        pure (List.map (Pair.map (fn key => sec ^ "." ^ key) id) alist)
        ))

    (* ((string, string) map, char) parser *)
    val iniP = 
        bind_ Parser.spaces (
        bind  keyValBlockP (fn noSec =>
        bind  (Parser.map List.concat (Parser.many sectionBlockP)) (fn secs =>
        pure  (Map.fromList String.compare (noSec @ secs))
        )))

    (* string -> ((string, string) map, string) result *)
    fun parseIniFile file = 
        let val ini = Parser.parse iniP (TextIOExtra.readFile file)
         in Result.mapErr (op ^ "Parsing error: ") ini
        end handle TextIO.BadFileName => Err "Bad file name"
                 | TextIO.InvalidFD   => Err "Invalid file descriptor"

fun parseJsonFile file =
    Result.mapErr (op ^ "Parsing error: ") (Json.parse (TextIOExtra.readFile file))
    handle 
        TextIO.BadFileName => Err "Bad file name"
        | TextIO.InvalidFD   => Err "Invalid file descriptor"

(* Gets the Json configuration file, defaults to NULL if we encounter an error
    : _ -> Json.json *)
fun get_json _ = 
    let val name  = CommandLine.name ()
        val usage = ("Usage: " ^ name ^ " configurationFile\n"
                     ^ "e.g.   " ^ name ^ " config.json\n")

    in case CommandLine.arguments () of
           [fileName] => (
            case parseJsonFile fileName of
                Err e  =>  let val _ = TextIOExtra.printLn_err e in
                               Json.null
                           end
              | Ok json => json
        )
    end


(* Convert the Json config into a mapping 
    : Json.json -> (string, Json.json) map *)
fun json_config_to_map (json : Json.json) =
    case Json.toMap json of
      None => Map.empty String.compare
      | Some v => v

(*****
 Json Config File Extraction Functions 
 *****)


(* Convert a json blob that represent the json plc map into an actual JsonPlcMap 
  : Json.json -> jsonPlcMap *)
fun jsonBlob_to_JsonPlcMap (jsonBlob : Json.json) =
    case (Json.toMap jsonBlob) of
      None =>   Map.empty String.compare
    | Some jsonMap => (* We should have a (id, json) map here *)
        let fun mappify' (v : Json.json) =
                case (Json.toString v) of
                  None => "ERROR"
                  | Some v' => v'
            fun mappify (v : Json.json) = 
                case (Json.toMap v) of
                  None => Map.empty String.compare
                | Some map' => 
                  Map.map mappify' map'
        in (Map.map mappify jsonMap)
        end

(* Extracts the jsonPlcMap from the overally json config mapping
    : (string, Json.json) map -> jsonPlcMap *)
fun extractJsonPlcMap (jsonMap : (string, Json.json) map) =
    case (Map.lookup jsonMap "plcs") of
      None =>  Map.empty String.compare
    | Some v => (* We have our "plcs" map as json 'v' *)
        jsonBlob_to_JsonPlcMap v

(* Attempts to lookup "key" in jsonMap
  if found, returns value after a post processor fn is applied,
  if not found, returns default value *)
fun jsonLookupValueOrDefault (jsonMap : (string, Json.json) map) (key : string) def =
    case (Map.lookup jsonMap key) of
      None => def
      | Some v => 
          case (Json.toString v) of
            None => def
            | Some v => v



fun get_ini _ =
    let val name  = CommandLine.name ()
        val usage = ("Usage: " ^ name ^ " configurationFile\n"
                     ^ "e.g.   " ^ name ^ " config.ini\n")

    in case CommandLine.arguments () of
           [fileName] => (
            case parseIniFile fileName of
                Err e  =>  let val _ = TextIOExtra.printLn_err e in
                               Map.empty String.compare
                           end
              | Ok ini => ini
        )
    end
          
        
                                             
(* fun get_ini_hexbytes s :: string -> BString 

   This function looks for the input key string (s) in the input ini map 
   (ini) If found, it converts the hex string representation to 
   a bytestring and returns it.
*)
fun get_ini_hexbytes ini s =
    let val opt_key_string = Map.lookup ini s
        val key_bytes = case opt_key_string of
                            Some v => BString.unshow v
                          | _ =>
                            let val _ = TextIOExtra.printLn_err ("\nError:  no '" ^ s ^ "' field configured for ini\n\n")
                            in BString.empty
                            end
    in key_bytes
    end


end
