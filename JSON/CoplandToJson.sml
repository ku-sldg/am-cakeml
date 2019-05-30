
(* ******************************* *)

structure CoplandToJson =
struct

fun intToJson n = Json.Number (Json.Int n)

fun stringToJson s = Json.String s

fun stringListToJsonList args  =  Json.List (List.map stringToJson args)

fun byteStringToJson bs = Json.String (ByteString.toHexString bs)

fun aspidToJson (Id a) = Json.Number (Json.Int (natToInt a))

fun placeToJson pl = Json.Number (Json.Int (natToInt pl))

fun spPairToJson (sp1, sp2) = Json.List [ Json.String  (spToString sp1), Json.String (spToString sp2)]

fun plAddrMapToJson map =
    let fun jsonify (pl, addr) = (plToString pl, Json.String addr)
     in Json.AList (List.map jsonify (Map.toAscList map))
    end

fun noArgConstructor cName = Json.AList [("constructor", stringToJson cName )]

fun constructorWithArgs cName arglist = Json.AList [("constructor", stringToJson cName),
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
      | BRS p t1 t2 => constructorWithArgs "BRS" [spPairToJson p, apdtToJson t1, apdtToJson t2]
      | BRP p t1 t2=>  constructorWithArgs "BRP" [spPairToJson p, apdtToJson t1, apdtToJson t2]
      |  _ =>  raise  Json.ERR "apdtToJson" "Unexpected constructor for APDT term: "

fun evidenceToJson evidence =
    case evidence
     of Mt => noArgConstructor "Mt"
     | U aspid args pl bs ev =>  constructorWithArgs "U" [ aspidToJson aspid, stringListToJsonList args, placeToJson pl, byteStringToJson bs, evidenceToJson ev]
     | K aspid args pl1 pl2 bs ev =>  constructorWithArgs "K" [ aspidToJson aspid, stringListToJsonList args, placeToJson pl1, placeToJson pl2,  byteStringToJson bs, evidenceToJson ev]
     | G pl ev bs => constructorWithArgs "G" [placeToJson pl, evidenceToJson ev, byteStringToJson bs]
     | H pl bs => constructorWithArgs "H" [placeToJson pl, byteStringToJson bs]
     | N pl index bs ev => constructorWithArgs "N" [placeToJson pl, Json.Number (Json.Int index), byteStringToJson bs, evidenceToJson ev]
     | SS ev1 ev2 => constructorWithArgs "SS" [evidenceToJson ev1, evidenceToJson ev2]
     | PP ev1 ev2 => constructorWithArgs "PP" [evidenceToJson ev1, evidenceToJson ev2]
     |  _ =>  raise  Json.ERR "evidenceToJson" "Unexpected constructor for Evidence term: "

fun requestToJson (REQ pl1 pl2 map t ev) = constructorWithArgs "REQ" [placeToJson pl1, placeToJson pl2, plAddrMapToJson map, apdtToJson t, evidenceToJson ev]

fun responseToJson (RES pl1 pl2 ev) = constructorWithArgs "RES" [placeToJson pl1, placeToJson pl2, evidenceToJson ev]

end
