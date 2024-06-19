(* Depends on: util, copland/Instr *)

fun intToJson n = Json.fromInt n

fun stringToJson s = Json.fromString s

fun stringListToJsonList args  =  Json.fromList (List.map stringToJson args) 

fun coq_BS_to_Json bs = Json.fromString (BString.show bs)

fun aspIdToJson i = Json.fromString i

fun aspidListToJsonList ids = Json.fromList (List.map aspIdToJson ids)

fun targIdToJson i = Json.fromString i

fun placeToJson pl = Json.fromString pl 


fun placeListToJsonList ids = Json.fromList (List.map placeToJson ids)

fun coq_RawEv_to_Json args  =  Json.fromList (List.map coq_BS_to_Json args)

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

(* appMapToJson : appMap -> json 
   type appMap = ((coq_Plc, coq_ASP_ID) prod list)
*)
fun appMapToJson map =
    let fun jsonify (pl, aspid) = (plToString pl, Json.fromString aspid)
    in Json.fromPairList (List.map jsonify (Map.toAscList map))
    end

(* policyToJson : appMap -> json 
   type appMap = ((coq_ASP_ID, coq_Plc) prod list)
*)
fun policyToJson map =
    let fun jsonify (aspid, pl) = (aspIdToString aspid, Json.fromString pl)
    in Json.fromPairList (List.map jsonify map (* (Map.toAscList map) *) )
    end

(* aspMapToJson : am/Manifest.aspMap -> json 
   type aspMap = ((coq_ASP_ID, addr) map)
*)
fun aspMapToJson map =
    let fun jsonify (id, addr) = (aspIdToString id, Json.fromString addr)
    in Json.fromPairList (List.map jsonify (Map.toAscList map))
    end

(* pubkeyMapToJson : am/Manifest.pubkeyMap -> json 
   type aspMap = ((coq_Plc, string) map)
*)
fun pubkeyMapToJson map =
    let fun jsonify (pl, pubkey) = (plToString pl, Json.fromString pubkey)
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
fun spToJson sp = noArgConstructor (spToString sp)

fun fwdToJson fwd = noArgConstructor (fwdToString fwd)

fun coq_ASP_ARGS_to_Json x = coq_MapC_to_Json x (fn x => x)

(* aspParamsToJson : coq_ASP_PARAMS -> json *)                               
fun aspParamsToJson ps =
    case ps of
        Coq_asp_paramsC i args tpl tid =>
        constructorWithArgs "Asp_paramsC"
                            [aspIdToJson i,
                             coq_ASP_ARGS_to_Json args,
                             placeToJson tpl,
                             targIdToJson tid]

             
(* aspToJson :: coq_ASP -> json *)                      
fun aspToJson asp = case asp of
      NULL => noArgConstructor "Null"
    | CPY  => noArgConstructor "Cpy"
    | ASPC sp fwd ps =>
    (*
      let val s = (Json.stringify (aspParamsToJson ps)) 
          val _ = print ("\n\n" ^ s ^ "\n\n") in 
    *)
      constructorWithArgs "Aspc"
                          [spToJson sp, fwdToJson fwd, aspParamsToJson ps]
      (*  end  *)
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
    | Coq_bseq (Coq_pair sp1 sp2) t1 t2 =>
      constructorWithArgs "Bseq"
                          [spToJson sp1, spToJson sp2, termToJson t1, termToJson t2]
    | Coq_bpar (Coq_pair sp1 sp2) t1 t2 =>
      constructorWithArgs "Bpar"
                          [spToJson sp1, spToJson sp2, termToJson t1, termToJson t2]
    |  _ =>
       raise  Json.Exn "termToJson" "Unexpected constructor for APDT term: "


fun evToJson e = case e of
                     Coq_mt => noArgConstructor "Mt"
                   | Coq_nn nid => constructorWithArgs "NN" [intToJson (natToInt nid)]
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

fun appResultToJson e = case e of
                      Coq_mtc_app => noArgConstructor "mtc_app"
                    | Coq_nnc_app nid bs => 
                      constructorWithArgs "nnc_app" [intToJson (natToInt nid), 
                                                     (coq_BS_to_Json bs)]
                    | Coq_ggc_app p ps bs e' =>
                     constructorWithArgs "ggc_app"
                                         [ placeToJson p,
                                           aspParamsToJson ps,
                                           coq_RawEv_to_Json bs,
                                           appResultToJson e' ]
                    | Coq_hhc_app p ps bs e' =>
                     constructorWithArgs "hhc_app"
                                         [ placeToJson p,
                                           aspParamsToJson ps,
                                           coq_BS_to_Json bs,
                                           appResultToJson e' ]
                    | Coq_eec_app p ps bs e' =>
                     constructorWithArgs "eec_app"
                                         [ placeToJson p,
                                           aspParamsToJson ps,
                                           coq_BS_to_Json bs,
                                           appResultToJson e' ]
                  
                   | Coq_ssc_app e1 e2 =>
                     constructorWithArgs "ssc_app"
                                         [ appResultToJson e1,
                                           appResultToJson e2 ]

fun evcToJson e =
    case e of
        Coq_evc ev et => constructorWithArgs "EvC" [ coq_RawEv_to_Json ev,
                                                     evToJson et ]