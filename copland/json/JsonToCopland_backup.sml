(* Depends on: util, copland/Instr *)

fun stringToSp n =
    case n
    of  "ALL" => ALL
    |   "NONE" => NONE

fun jsonStringToString (Json.String s) = s
fun jsonStringListToList (Json.Array args) =
    List.map jsonStringToString args

fun jsonStringToBS (Json.String s) = BString.unshow s

(* json object to apdt object *)
fun jsonToTerm js = case (Json.toMap js) of
      Some js' => fromAList (Map.toAscList js')
    | None =>
        raise Json.Exn "jsonToTerm" "Copland term does not begin as an AList"

    and
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
          "Asp"  => Asp (getAsp args)
        | "Att"  => getAtt  args
        | "Lseq" => getLseq args
        | "Bseq" => getBseq args
        | "Bpar" => getBpar args
        |  _ => raise Json.Exn "getTerm" ("Unexpected constructor for Copland term: " ^ constructor)

    and
    getAsp data = case data of
          [Json.Object js'] => getAspFromAList (Map.toAscList js')
        | _ => raise Json.Exn "getAsp" "Copland Asp term does not begin as an AList"

    and
    getAspFromAList data = case data of
          [("constructor", constructorVal)] =>
            getAspNullaryConstructor constructorVal
        | [("constructor", Json.String "Aspc"), ("data", args)] =>
            getAspc args
        | [("data", args), ("constructor", Json.String "Aspc")] =>
            getAspc args
        | _ => raise Json.Exn "getAspFromAList" "does not contain just constructor and data pairs"

    and
    getAspNullaryConstructor (Json.String constructor) = case constructor of
          "Cpy" => Cpy
        | "Sig" => Sig
        | "Hsh" => Hsh
        | _ => raise Json.Exn "getAspNullaryConstructor" ("Unexpected constructor for Copland Asp term: " ^ constructor)

    and
    getAspc (Json.Array args) = case args of
          [Json.Int aspId, args] => Aspc (Id (natFromInt aspId)) (jsonStringListToList args)
        | _ => raise Json.Exn "getAspc" "unexpected argument list"

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
