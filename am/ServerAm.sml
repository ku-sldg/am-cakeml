(* Depends on copland/AM, am/Measurements, util/Json,
   copland/json/CoplandToJson, copland/json/JsonToCopland *)

fun strToJson str = List.hd (fst (Json.parse ([], str)))
fun jsonToStr js  = Json.print_json js 0

fun serverSend fd = Socket.output fd o jsonToStr o requestToJson
val serverRcv     = jsonToResponse o strToJson o Socket.inputAll

exception DispatchErr string
(* pl -> nsMap -> pl -> copEval *)
fun socketDispatch me nsMap pl ev t =
    let val addr = case Map.lookup nsMap pl of
              Some a => a
            | None => raise DispatchErr ("Place "^ plToString pl ^" not in nameserver map")
        val req  = (REQ pl me nsMap t ev)
        val fd   = Socket.connect addr 5000
        val (RES _ _ ev) = (serverSend fd req; serverRcv fd)
     in Socket.close fd;
        ev
    end

(* key -> nsMap -> am *)
fun serverAm privKey nsMap = Am
    O
    (socketDispatch O nsMap)
    usmMap
    privKey
    Crypto.signMsg
    Crypto.hash
