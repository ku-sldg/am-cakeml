(* Depends on copland/AM, am/Measurements, util/Json,
   copland/json/CoplandToJson, copland/json/JsonToCopland copland/Parser.sml *)

fun strToJson str = Result.okValOf (Json.parse str)
fun jsonToStr js  = Json.stringify js

fun serverSend fd = Socket.output fd o jsonToStr o requestToJson
val serverRcv     = jsonToResponse o strToJson o Socket.inputAll

(* iniServerAM :: ini -> Result (nsMap, string) *)
fun iniServerAm ini = 
    let fun lookup m x = Result.fromOption (Map.lookup m x)
                ("No value given for \"" ^ x ^ "\"")
        fun iniNsMap m = MapExtra.mapPartial nat_compare (fn k => fn v =>
                case String.tokens ((op =) #".") k of
                  ["place", ident, "ip"] => 
                      Option.map (fn x => (x, v))
                      (Result.toOption (Parser.parse numeralP ident))
                | _ => None
            ) m
     in Result.bind (lookup ini "privateKey") (fn key =>
        Result.bind ((Ok (BString.unshow key)) handle _ =>
                Err "Could not parse private key") (fn key =>
        (* Ok (serverAm key (iniNsMap ini)) *)
          Ok (iniNsMap ini)))
    end
