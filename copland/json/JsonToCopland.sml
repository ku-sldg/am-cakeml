(* Depends on: util, copland/Instr *)

(* spFromString :: string -> coq_SP *)
fun spFromString n =
    case n
    of  "ALL" => ALL
    |   "NONE" => NONE

(* fwdFromString :: string -> coq_FWD *)
fun fwdFromString n =
    case n
    of  "COMP" => COMP
    |   "EXTD" => EXTD

fun jsonStringToString (Json.String s) = s
fun jsonStringListToList (Json.Array args) =
    List.map jsonStringToString args

fun jsonStringToBS (Json.String s) = BString.unshow s

fun jsonBsListToList (Json.Array args) =
    List.map jsonStringToBS args

                                                    

(* json object to Copland phrase
   
   jsonToTerm :: json -> coq_Term 
 *)                                           
fun jsonToTerm js = case (Json.toMap js) of
                    (* Json.toMap :: json -> ((string,json) map) option *)
      Some js' => fromAList (Map.toAscList js') (* js' :: (string,json) map *)
    | None =>
        raise Json.Exn "jsonToTerm" "Copland term does not begin as an AList"

and
(* fromAList :: (string,json) map -> coq_Term  *)
    fromAList pairs = case pairs of
          [("constructor", constructorVal), ("data", args)] =>
            getTerm constructorVal args
        | [("data", args), ("constructor", constructorVal)] =>
            getTerm constructorVal args
        | _ =>
            raise Json.Exn "fromAList" "does not contain just constructor and data pairs"

    and
    getTerm (Json.String constructor) (Json.Array args) =
        case constructor of
            "Asp"  => Coq_asp (getAsp args)
                              (*
        | "Att"  => getAtt  args
        | "Lseq" => getLseq args
        | "Bseq" => getBseq args
        | "Bpar" => getBpar args *)
         |  _ => raise Json.Exn "getTerm" ("Unexpected constructor for Copland term: " ^ constructor)

    and
    (* getAsp :: json list -> coq_ASP
       Expected:  [Json.Object [("constructor", name), ("data", Json.Array args)]
       where name = "Null" | "Cpy" | "Aspc" | "Sig" | "Hsh"
     *)
    getAsp data = case data of
          [Json.Object js'] => getAspFromAList (Map.toAscList js')
        | _ => raise Json.Exn "getAsp" "Copland Asp term does not begin as an AList"

    and
    (* getAspFromAlist :: (string, json) list -> coq_ASP *)
    getAspFromAList data = case data of
          [("constructor", constructorVal)] =>
            getAspNullaryConstructor constructorVal
        | [("constructor", Json.String "Aspc"), ("data", args)] =>
            getAspc args
        | [("data", args), ("constructor", Json.String "Aspc")] =>
            getAspc args
        | _ => raise Json.Exn "getAspFromAList" "does not contain just constructor and data pairs"
                     
    and
    (* getAspc :: Json.Array -> coq_ASP *)
    getAspc (Json.Array args) = case args of
    (* args :: json list 
       Expected: [Json.String "ALL" | "NONE", Json.String "COMP" | "EXTD", 
                  Json.Object [("constructor", "asp_paramsC"), ("data", ...)]      *)
                     (* [("constructor", Json.String "asp_"), ("data", args)] => CPY *)
    [Json.String spStr, Json.String fwdStr, paramsJson] =>
        ASPC (spFromString spStr) (fwdFromString fwdStr) (getAspParams paramsJson)
                    | _ => raise Json.Exn "getAspc" "unexpected argument list"
                     
    and
    (* getAspParams :: json -> coq_ASP_PARAMS *)
    (* (string, json) list -> coq_ASP_PARAMS *)
    getAspParams (Json.Object js') =
      case (Map.toAscList js') of
          [("constructor", Json.String "asp_paramsC"), ("data", args)] => getAspParamsArray args
        | [("data", args), ("constructor", Json.String "asp_paramsC")] => getAspParamsArray args
        | _ => raise Json.Exn "getAspParams" "expected asp_paramsC constructor object"
    and
    (* getAspParamsArray :: json -> coq_ASP_PARAMS
       Expected:  [Json.String aspid, 
                   Json.Array [Json.String stringArg1, Json.String stringArg2, ...], 
                   Json.Int plc, 
                   Json.String targid] *)
    getAspParamsArray (Json.Array js) = (* Coq_asp_paramsC "" [] O "" *)
      case js of
          [Json.String aspid, arrayArgs, Json.Int plc, Json.String targid] =>
            Coq_asp_paramsC aspid (jsonStringListToList arrayArgs)  (natFromInt plc) targid
        | _ => raise Json.Exn "getAspParamsArray" "unexpected Coq_asp_paramsC params"
    and
    getAspNullaryConstructor (Json.String constructor) = case constructor of
          "Cpy" => CPY
        | "Null" => NULL 
        | "Sig" => SIG
        | "Hsh" => HSH
        | _ => raise Json.Exn "getAspNullaryConstructor" ("Unexpected constructor for Copland Asp term: " ^ constructor)

         

    (*
    getAspc (Json.Array args) = case args of
          [Json.Int aspId, args] => ASPC (Id (natFromInt aspId)) (jsonStringListToList args)
        | _ => raise Json.Exn "getAspc" "unexpected argument list"
    *)
(*
    and
    getAtt data = case data of
          [ Json.Int place, term] => Att(natFromInt place) (jsonToTerm term)
        | _ => raise  Json.Exn "getAtt" "unexpected argument list"

    and
    getLseq data = case data of
          [term1, term2] => Lseq (jsonToTerm term1) (jsonToTerm term2)
        | _ => raise  Json.Exn "getLseq" "unexpected argument list"

    and
    getBseq data = case data of
          [ Json.Array [Json.String sp1, Json.String sp2], term1, term2] =>
            Bseq (stringToSp sp1, stringToSp sp2) (jsonToTerm term1) (jsonToTerm term2)
        | _ => raise  Json.Exn "getBseq" "unexpected argument list"

    and
    getBpar data = case data of
          [ Json.Array [Json.String sp1, Json.String sp2], term1, term2] =>
            Bpar (stringToSp sp1, stringToSp sp2) (jsonToTerm term1) (jsonToTerm term2)
        | _ => raise  Json.Exn "getBpar" "unexpected argument list"
*)

 (*                    

(* json object to ev object *)
fun jsonToEv js = case (Json.toMap js) of
      Some js' => fromAList (Map.toAscList js')
    | None =>
        raise  Json.Exn "JsonToEv" "Copland evidence does not begin as an AList"

    and
    fromAList pairs = case pairs of
          [("constructor", constructorVal)] => handleNullConstructor constructorVal
        | [("constructor", constructorVal), ("data", args)] => handleConstructorWithArgs constructorVal args
        | [("data", args), ("constructor", constructorVal)]  => handleConstructorWithArgs constructorVal args
        | _ =>  raise  Json.Exn "fromAList" "does not contain just constructor and data pairs"

    and
    handleNullConstructor (Json.String constructor) = case constructor of
          "Mt" => Mt
        | _ => raise Json.Exn "handleNullConstructor"  ("Unexpected Null constructor for Copland evidence: " ^constructor)

    and
    handleConstructorWithArgs (Json.String constructor) (Json.Array args) =
        case constructor of
          "U"  => getU  args
        | "G"  => getG  args
        | "H"  => getH  args
        | "N"  => getN  args
        | "SS" => getSS args
        | "PP" => getPP args
        |  _ => raise Json.Exn "handleConstructorWithArgs" ("Unexpected constructor for Copland evidence: "^ constructor)

    and
    getU data = case data of
          [Json.Int aspId, args, bs, ev] =>
            U (Id (natFromInt aspId)) (jsonStringListToList args) (jsonStringToBS bs) (jsonToEv ev)
        | _ => raise Json.Exn "getU" "unexpected argument list"

    and
    getG data = case data of
          [bs, ev] => G (jsonStringToBS bs) (jsonToEv ev)
        | _ => raise Json.Exn "getG" "unexpected argument list"

    and
    getH data = case data of
          [bs] => H (jsonStringToBS bs)
        | _ => raise Json.Exn "getH" "unexpected argument list"

    and
    getN data = case data of
          [Json.Int index, bs, ev] =>
            N (Id (natFromInt index)) (jsonStringToBS bs) (jsonToEv ev)
        | _ => raise Json.Exn "getN" "unexpected argument list"

    and
    getSS data = case data of
          [ev1, ev2] => SS (jsonToEv ev1) (jsonToEv ev2)
        | _ => raise Json.Exn "getSS" "unexpected argument list"

    and
    getPP data = case data of
          [ev1, ev2] => PP (jsonToEv ev1) (jsonToEv ev2)
        | _ => raise Json.Exn "getPP" "unexpected argument list"


*)
