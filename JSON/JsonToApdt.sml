
(* ******************************* *)

fun stringToSp n =
    case n
    of  "ALL" => ALL
    |   "NONE" => NONE

fun jsonStringToString (Json.String s) = s
fun jsonStringListToList (Json.List args)  = List.map jsonStringToString args


structure JsonToApdt =
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

end
