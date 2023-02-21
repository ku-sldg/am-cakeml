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


(* TODO: I really am not sure how good a concept it is to have this, we should rather just raise an error IMO *)
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
