(* Depends on copland/AM, am/Measurements, util/Json,
   copland/json/CoplandToJson, copland/json/JsonToCopland copland/Parser.sml *)

fun strToJson str = Result.okValOf (Json.parse str)
fun jsonToStr js  = Json.stringify js

fun serverSend fd = Socket.output fd o jsonToStr o requestToJson
val serverRcv     = jsonToResponse o strToJson o Socket.inputAll

(*
exception DispatchErr string
(* coq_Plc -> nsMap -> coq_Plc -> (bs list) -> coq_Term -> (bs list) *)
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
*)


(*
        
(* key -> nsMap -> am *)
fun serverAm privKey nsMap = Am
    O
    (socketDispatch O nsMap)
    usmMap
    privKey
    Crypto.signMsg
    Crypto.hash
*)



        

(* (string, string) map -> am result *)
(* fun iniServerAm ini = 
    let fun lookup m x = Result.fromOption (Map.lookup m x)
                ("No value given for \"" ^ x ^ "\"")
        fun iniNsMap m = MapExtra.mapPartial nat_compare (fn k => fn v =>
                case String.tokens ((op =) #".") k of
                  ["place", ident, "ip"] => 
                      OptionExtra.bind (Result.toOption (Parser.run peanoP ident)) (fn key =>
                      OptionExtra.bind (Map.lookup m ("place." ^ ident ^ ".port")) (fn portStr =>
                      OptionExtra.bind (Int.fromString portStr) (fn port =>
                      Some (key, (v, port))
                      )))
                | _ => None
            ) m
     in Result.bind (lookup ini "privateKey") (fn key =>
        Result.bind ((Ok (BString.unshow key)) handle _ =>
                Err "Could not parse private key") (fn key =>
        Ok (serverAm key (iniNsMap ini))
        ))
    end *)



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
