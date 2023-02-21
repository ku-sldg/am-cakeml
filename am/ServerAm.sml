(* Depends on copland/AM, am/Measurements, util/Json,
   copland/json/CoplandToJson, copland/json/JsonToCopland copland/Parser.sml *)

(*
fun strToJson str = Result.okValOf (Json.parse str)
fun jsonToStr js  = Json.stringify js
*)

fun serverSend fd = Socket.output fd o jsonToStr o requestToJson
val serverRcv     = jsonToResponse o strToJson o Socket.inputAll
                        
(* jsonServerAM :: (string, Json.json) map -> Result (jsonPlcMap, string) *)
fun jsonServerAm (json : (string, Json.json) map) =
    case (Map.lookup json "privateKey") of
      None => Err "Private key does not exist in config file"
      | Some jsonPKey =>
        case (Json.toString jsonPKey) of
          None => Err "Private key is malformed in config file"
          | Some keyVal =>
            Ok (extractJsonPlcMap json)
