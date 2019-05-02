
(* ******************************* *)

fun stringToSp n =
    case n
    of  "ALL" => ALL
    |   "NONE" => NONE

fun jsonStringToString (Json.String s) = s
fun jsonStringListToList (Json.List args)  = List.map jsonStringToString args

fun jsonStringToBS (Json.String s) = ByteString.fromHexString s


structure JsonToCopland =
struct

(* json object to apt object *)
fun jsonToApdt js =
    case js
     of Json.AList js' => fromAList js'
      | _ =>  raise  Json.ERR "jsonToApdt" "APDT term does not begin as an AList"

      and
    fromAList pairs =
    case pairs
     of [("name", nameVal)] => handleNullConstructor nameVal
      |  [("name", nameVal), ("data", args)] => handleConstructorWithArgs nameVal args
      |  [("data", args),  ("name", nameVal)]  => handleConstructorWithArgs nameVal args
      | _ =>  raise  Json.ERR "fromAList" "does not contain just name and data pairs"

      and
    handleNullConstructor (Json.String name) =
    case name
     of "SIG" => SIG
     |  "HSH" =>  HSH
     |  "NONCE" => NONCE
     | _ => raise Json.ERR "handleNullConstructor"  (String.concat ["Unexpected Null constructor for APDT term: ", name])

    and
    handleConstructorWithArgs (Json.String name) (Json.List args) =
        case name
         of "KIM" => getKIM args
         | "USM" =>  getUSM args
         | "AT"  =>  getAT args
         | "LN"  =>  getLN args
         | "BRS" =>  getBRS args
         | "BRP" =>  getBRP args
         |  _ =>  raise  Json.ERR "handleConstructorWithArgs" (String.concat ["Unexpected constructor for APDT term: ", name])

      and
    getKIM data =
    case data
     of [ Json.Number (Json.Int aspId), Json.Number (Json.Int place), args] =>
             KIM (Id (natFromInt aspId)) (natFromInt place) (jsonStringListToList args)
      | _ => raise  Json.ERR "getKIM" "unexpected argument list"

      and
    getUSM data =
    case data
     of [ Json.Number (Json.Int aspId), args] => USM (Id (natFromInt aspId)) (jsonStringListToList args)
      | _ => raise  Json.ERR "getUSM" "unexpected argument list"

    and
    getAT data =
    case data
     of [ Json.Number (Json.Int place), term] => AT (natFromInt place) (jsonToApdt term)
      | _ => raise  Json.ERR "getAT" "unexpected argument list"

    and
    getLN data =
    case data
     of [term1, term2] => LN (jsonToApdt term1) (jsonToApdt term2)
      | _ => raise  Json.ERR "getLN" "unexpected argument list"

    and
    getBRS data =
    case data
     of [ Json.List [ (Json.String sp1), (Json.String sp2)], term1, term2] =>
     BRS (stringToSp sp1) (stringToSp sp2) (jsonToApdt term1) (jsonToApdt term2)
      | _ => raise  Json.ERR "getBRS" "unexpected argument list"
    and
    getBRP data =
    case data
     of [ Json.List [ (Json.String sp1), (Json.String sp2)], term1, term2] =>
     BRP (stringToSp sp1) (stringToSp sp2) (jsonToApdt term1) (jsonToApdt term2)
      | _ => raise  Json.ERR "getBRP" "unexpected argument list"

(* json object to apt object *)
fun jsonToEvidence js =
    case js
     of Json.AList js' => fromAList js'
      | _ =>  raise  Json.ERR "JsonToEvidence" "APDT Evidence does not begin as an AList"

      and
    fromAList pairs =
    case pairs
     of [("name", nameVal)] => handleNullConstructor nameVal
     |  [("name", nameVal), ("data", args)] => handleConstructorWithArgs nameVal args
     |  [("data", args),  ("name", nameVal)]  => handleConstructorWithArgs nameVal args
     | _ =>  raise  Json.ERR "fromAList" "does not contain just name and data pairs"

    and
    handleNullConstructor (Json.String name) =
    case name
     of "Mt" => Mt
     | _ => raise Json.ERR "handleNullConstructor"  (String.concat ["Unexpected Null constructor for APDT Evidence: ", name])

    and
    handleConstructorWithArgs (Json.String name) (Json.List args) =
    case name
     of "K" => getK args
     | "U" =>  getU args
     | "G" =>  getG args
     | "H" =>  getH args
     | "N" =>  getN args
     | "SS"  =>  getSS args
     | "PP" =>  getPP args
     |  _ =>  raise  Json.ERR "handleConstructorWithArgs" (String.concat ["Unexpected constructor for APDT Evidence: ", name])

    and
    getK data =
    case data
     of [ Json.Number (Json.Int aspId), args, Json.Number (Json.Int place1), Json.Number (Json.Int place2), bs, ev] =>
           K (Id (natFromInt aspId))  (jsonStringListToList args) (natFromInt place1) (natFromInt place2) (jsonStringToBS bs) (jsonToEvidence ev)
     | _ => raise  Json.ERR "getK" "unexpected argument list"

    and
    getU data =
    case data
     of [ Json.Number (Json.Int aspId), args, Json.Number (Json.Int place), bs, ev] =>
           U (Id (natFromInt aspId)) (jsonStringListToList args) (natFromInt place) (jsonStringToBS bs) (jsonToEvidence ev)
     | _ => raise  Json.ERR "getU" "unexpected argument list"

    and
    getG data =
    case data
     of [ Json.Number (Json.Int place), ev, bs] =>
            G (natFromInt place) (jsonToEvidence ev) (jsonStringToBS bs)
     | _ => raise  Json.ERR "getG" "unexpected argument list"

    and
    getH data =
    case data
     of [ Json.Number (Json.Int place), bs] => H (natFromInt place) (jsonStringToBS bs)
     | _ => raise  Json.ERR "getH" "unexpected argument list"

    and
    getN data =
    case data
     of [ Json.Number (Json.Int place), Json.Number (Json.Int index), bs, ev] =>
           N (natFromInt place) index (jsonStringToBS bs) (jsonToEvidence ev)
     | _ => raise  Json.ERR "getN" "unexpected argument list"

    and
    getSS data =
    case data
     of [ev1, ev2] => SS  (jsonToEvidence ev1)  (jsonToEvidence ev2)
     | _ => raise  Json.ERR "getSS" "unexpected argument list"

    and
    getPP data =
    case data
     of [ev1, ev2] => PP  (jsonToEvidence ev1)  (jsonToEvidence ev2)
     | _ => raise  Json.ERR "getPP" "unexpected argument list"
end
