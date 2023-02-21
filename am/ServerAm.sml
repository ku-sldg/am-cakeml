(* Depends on copland/AM, am/Measurements, util/Json,
   copland/json/CoplandToJson, copland/json/JsonToCopland copland/Parser.sml *)

(*
fun strToJson str = Result.okValOf (Json.parse str)
fun jsonToStr js  = Json.stringify js
*)

fun serverSend fd = Socket.output fd o jsonToStr o requestToJson
fun serverSend_json fd = Socket.output fd o jsonToStr o requestToJson_json
val serverRcv     = jsonToResponse o strToJson o Socket.inputAll

fun lookup m x = Result.fromOption (Map.lookup m x)
                                   ("No value given for \"" ^ x ^ "\"")

(* CLEANUP (JSON): 
When we convert to JSON vs. INI, then we can 
get rid of all the INI stuff *)
fun iniNsMap m =
    MapExtra.mapPartial nat_compare
                        (fn k => fn v =>
                            case String.tokens ((op =) #".") k of
                                ["place", ident, "ip"] => 
                                Option.map (fn x => (x, v))
                                           (Result.toOption (Parser.parse numeralP ident))
                              | _ => None
                        ) m


                        
(* iniServerAM :: ini -> Result (nsMap, string) *)
fun iniServerAm ini =
    Result.bind (lookup ini "privateKey")
                (fn key =>
                    Result.bind ((Ok (BString.unshow key)) handle _ => Err "Could not parse private key")
                                (fn key => Ok (iniNsMap ini)))


fun get_ini_nsMap ini =
    case (iniServerAm ini) of
        Err e => let val _ = O in
                     (TextIOExtra.printLn_err e);
                     (Map.empty nat_compare)
                 end
      | Ok v => v
