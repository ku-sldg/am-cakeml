(* Depends on: util, copland/Instr *)

fun intToJson n = Json.fromInt n

fun stringToJson s = Json.fromString s

fun stringListToJsonList args  =  Json.fromList (List.map stringToJson args) 

fun byteStringToJson bs = Json.fromString (BString.show bs)

fun aspIdToJson i = Json.fromString i

fun aspidListToJsonList ids = Json.fromList (List.map aspIdToJson ids)

fun targIdToJson i = Json.fromString i

fun placeToJson pl = Json.fromInt (natToInt pl)

fun placeListToJsonList ids = Json.fromList (List.map placeToJson ids)

(* spPairToJson : (coq_SP * coq_SP) -> json *)
fun spPairToJson (sp1, sp2) =
    Json.fromList
        [Json.fromString  (spToString sp1), Json.fromString (spToString sp2)]
        
(* spProdToJson : (coq_SP, coq_SP) prod -> json 
   NOTE:  `prod` is the Coq pair type extracted naively to cakeml 
*)                             
fun spProdToJson sp =
    case sp of
        Coq_pair sp1 sp2 => spPairToJson (sp1,sp2)                            

(* nsMapToJson : am/CommTypes.nsMap -> json 
   type nsMap = ((coq_Plc, addr) map)
*)
fun nsMapToJson map =
    let fun jsonify (pl, addr) = (plToString pl, Json.fromString addr)
    in Json.fromPairList (List.map jsonify (Map.toAscList map))
    end

        
(* noArgConstructor : string -> json *)
fun noArgConstructor cName =
    Json.fromPairList [("constructor", stringToJson cName )]

(* constructorWithArgs : string -> (json list) -> json *)
fun constructorWithArgs cName arglist =
    Json.fromPairList [("constructor", stringToJson cName),
                       ("data", Json.Array arglist)]

(* spToJson : coq_SP -> json *)
fun spToJson sp = stringToJson (spToString sp)

(* fwdToJson : coq_FWD -> json *)
fun fwdToJson fwd = stringToJson (fwdToString fwd)

(* aspParamsToJson : coq_ASP_PARAMS -> json *)                               
fun aspParamsToJson ps =
    case ps of
        Coq_asp_paramsC i args tpl tid =>
        constructorWithArgs "asp_paramsC" [aspIdToJson i, stringListToJsonList args,
                                           placeToJson tpl, targIdToJson tid]

(* manifestToJson :: coq_Manifest -> json *)
fun manifestToJson m =
    case m of
        Build_Manifest asp_ids plc_ids =>
        constructorWithArgs "Manifest" [aspidListToJsonList asp_ids,
                                        placeListToJsonList plc_ids]
                            
(* aspToJson :: coq_ASP -> json *)                      
fun aspToJson asp = case asp of
      NULL => noArgConstructor "Null"
    | CPY  => noArgConstructor "Cpy"
    | ASPC sp fwd ps =>
      constructorWithArgs "Aspc"
                          [spToJson sp, fwdToJson fwd, aspParamsToJson ps]
    | SIG => noArgConstructor "Sig"
    | HSH => noArgConstructor "Hsh"
    | ENC q => constructorWithArgs "Enc" [placeToJson q]

(* termToJson : coq_Term -> json *)
fun termToJson term = case term of
      Coq_asp asp => constructorWithArgs "Asp"  [aspToJson asp]
    | Coq_att pl t => constructorWithArgs "Att"  [placeToJson pl, termToJson t]
    | Coq_lseq t1 t2 =>
      constructorWithArgs "Lseq"
                          [termToJson t1, termToJson t2]
    | Coq_bseq p t1 t2 =>
      constructorWithArgs "Bseq"
                          [spProdToJson p, termToJson t1, termToJson t2]
    | Coq_bpar p t1 t2 =>
      constructorWithArgs "Bpar"
                          [spProdToJson p, termToJson t1, termToJson t2]
    |  _ =>
       raise  Json.Exn "termToJson" "Unexpected constructor for APDT term: "



fun evToJson e = case e of
                     Coq_mt => noArgConstructor "Mt"
                   | Coq_nn nid => constructorWithArgs "NN" [placeToJson nid]
                   | Coq_uu p fwd ps e' =>
                     constructorWithArgs "UU"
                                         [ placeToJson p,
                                           fwdToJson fwd,
                                           aspParamsToJson ps,
                                           evToJson e' ]
                   | Coq_ss e1 e2 =>
                     constructorWithArgs "SS"
                                         [ evToJson e1,
                                           evToJson e2 ]

                                         
                           
