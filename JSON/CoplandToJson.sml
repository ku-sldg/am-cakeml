
(* ******************************* *)

structure CoplandToJson =
struct

fun intToJson n = Json.Number (Json.Int n)

fun stringToJson s = Json.String s

fun stringListToJsonList args  =  Json.List (List.map stringToJson args)

fun byteStringToJson bs = Json.String (ByteString.toString  bs)

fun aspidToJson (Id a) = Json.Number (Json.Int (natToInt a))

fun placeToJson pl = Json.Number (Json.Int (natToInt pl))

fun spPairToJson (sp1, sp2) = Json.List [ Json.String  (spToString sp1), Json.String (spToString sp2)]

fun noArgConstructor cName = Json.AList [("name", stringToJson cName )]

fun constructorWithArgs cName arglist = Json.AList [("name", stringToJson cName ),
                                                    ("data", Json.List arglist)]

fun apdtToJson term =
    case term
     of KIM aspid pl args => constructorWithArgs "KIM" [ aspidToJson aspid, placeToJson pl, stringListToJsonList args]
      | USM aspid args => constructorWithArgs "USM"  [ aspidToJson aspid, stringListToJsonList args]
      | SIG => noArgConstructor "SIG"
      | HSH => noArgConstructor "HSH"
      | NONCE => noArgConstructor "NONCE"
      | AT pl t1 => constructorWithArgs "AT" [ placeToJson pl, apdtToJson t1]
      | LN t1 t2 =>  constructorWithArgs "LN" [ apdtToJson t1, apdtToJson t2]
      | BRS sp1 sp2 t1 t2 => constructorWithArgs "BRS" [spPairToJson (sp1, sp2), apdtToJson t1, apdtToJson t2]
      | BRP sp1 sp2 t1 t2=>  constructorWithArgs "BRP" [spPairToJson (sp1, sp2), apdtToJson t1, apdtToJson t2]
      |  _ =>  raise  Json.ERR "apdtToJson" "Unexpected constructor for APDT term: "

fun evidenceToJson evidence =
    case evidence
     of Mt => Json.String "Mt"
     | U aspid args pl bs ev =>  constructorWithArgs "U" [ aspidToJson aspid, stringListToJsonList args, placeToJson pl, byteStringToJson bs, evidenceToJson ev]
     | K aspid args pl1 pl2 bs ev =>  constructorWithArgs "K" [ aspidToJson aspid, stringListToJsonList args, placeToJson pl1, placeToJson pl2,  byteStringToJson bs, evidenceToJson ev]
     | G pl ev bs => constructorWithArgs "G" [placeToJson pl, evidenceToJson ev, byteStringToJson bs]
     | H pl bs => constructorWithArgs "H" [placeToJson pl, byteStringToJson bs]
     | N pl index bs ev => constructorWithArgs "N" [placeToJson pl, Json.Number (Json.Int index), byteStringToJson bs, evidenceToJson ev]
     | SS ev1 ev2 => constructorWithArgs "SS" [evidenceToJson ev1, evidenceToJson ev2]
     | PP ev1 ev2 => constructorWithArgs "PP" [evidenceToJson ev1, evidenceToJson ev2]
     |  _ =>  raise  Json.ERR "evidenceToJson" "Unexpected constructor for Evidence term: "
end
