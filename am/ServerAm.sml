(* Depends on copland/AM, am/Measurements, util/Json,
   copland/json/CoplandToJson, copland/json/JsonToCopland copland/Parser.sml *)

(*
fun strToJson str = Result.okValOf (Json.parse str)
fun jsonToStr js  = Json.stringify js
*)

fun serverSend fd = Socket.output fd o jsonToStr o requestToJson
val serverRcv     = jsonToResponse o strToJson o Socket.inputAll
