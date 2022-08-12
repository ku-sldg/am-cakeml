(* Depends on: util, copland/Instr *)

fun intToJson n = Json.fromInt n

fun stringToJson s = Json.fromString s

fun stringListToJsonList args  =  Json.fromList (List.map stringToJson args)

fun byteStringToJson bs = Json.fromString (BString.show bs)

                                          (*

fun idToJson (Id a) = Json.fromInt (natToInt a)
                                          *)

fun aspIdToJson i = Json.fromString i

fun targIdToJson i = Json.fromString i

fun placeToJson pl = Json.fromInt (natToInt pl)
                           
fun spPairToJson (sp1, sp2) =
    Json.fromList
        [Json.fromString  (spToString sp1), Json.fromString (spToString sp2)]
                              
fun spProdToJson sp =
    case sp of
        Coq_pair sp1 sp2 => spPairToJson (sp1,sp2)                            
                                  
fun nsMapToJson map =
    let fun jsonify (pl, addr) = (plToString pl, Json.fromString addr)
    in Json.fromPairList (List.map jsonify (Map.toAscList map))
    end

        

fun noArgConstructor cName =
    Json.fromPairList [("constructor", stringToJson cName )]

fun constructorWithArgs cName arglist =
    Json.fromPairList [("constructor", stringToJson cName),
                       ("data", Json.Array arglist)]

fun spToJson sp = stringToJson (spToString sp)

fun fwdToJson fwd = stringToJson (fwdToString fwd)

                                 
fun aspParamsToJson ps =
    case ps of
        Coq_asp_paramsC i args tpl tid =>
        constructorWithArgs "asp_paramsC" [aspIdToJson i, stringListToJsonList args,
                                           placeToJson tpl, targIdToJson tid]
                             
                                  

(* aspToJson :: coq_ASP -> json *)                      
fun aspToJson asp = case asp of
      NULL => noArgConstructor "Null"
    | CPY  => noArgConstructor "Cpy"
    | ASPC sp fwd ps => constructorWithArgs "Aspc"
                                            [spToJson sp, fwdToJson fwd, aspParamsToJson ps]
    | SIG => noArgConstructor "Sig"
    | HSH => noArgConstructor "Hsh"
                              
                      
(*
fun aspToJson asp = case asp of
      Cpy => noArgConstructor "Cpy"
    | Aspc aspid args => constructorWithArgs "Aspc" [idToJson aspid, stringListToJsonList args]
    | Sig => noArgConstructor "Sig"
    | Hsh => noArgConstructor "Hsh"
*)


                              

fun termToJson term = case term of
      Coq_asp asp      => constructorWithArgs "Asp"  [aspToJson asp]
    | Coq_att pl t     => constructorWithArgs "Att"  [placeToJson pl, termToJson t]
    | Coq_lseq t1 t2   => constructorWithArgs "Lseq" [termToJson t1, termToJson t2]
    | Coq_bseq p t1 t2 => constructorWithArgs "Bseq" [spProdToJson p, termToJson t1, termToJson t2]
    | Coq_bpar p t1 t2 => constructorWithArgs "Bpar" [spProdToJson p, termToJson t1, termToJson t2]
    |  _ => raise  Json.Exn "termToJson" "Unexpected constructor for APDT term: "

                   (*
fun evToJson e = case e of
      Mt => noArgConstructor "Mt"
    | U aid args bs ev => constructorWithArgs "U" [idToJson aid, stringListToJsonList args, byteStringToJson bs, evToJson ev]
    | G bs ev => constructorWithArgs "G" [byteStringToJson bs, evToJson ev]
    | H bs => constructorWithArgs "H" [byteStringToJson bs]
    | N id bs ev => constructorWithArgs "N" [idToJson id, byteStringToJson bs, evToJson ev]
    | SS ev1 ev2 => constructorWithArgs "SS" [evToJson ev1, evToJson ev2]
    | PP ev1 ev2 => constructorWithArgs "PP" [evToJson ev1, evToJson ev2]

*)
