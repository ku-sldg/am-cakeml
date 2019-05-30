
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

(* json object to apdt object *)
fun jsonToApdt js =
    case js
     of Json.AList js' => fromAList js'
      | _ =>  raise  Json.ERR "jsonToApdt" "APDT term does not begin as an AList"

      and
    fromAList pairs =
    case pairs
     of [("constructor", constructorVal)] => handleNullConstructor constructorVal
      |  [("constructor", constructorVal), ("data", args)] => handleConstructorWithArgs constructorVal args
      |  [("data", args),  ("constructor", constructorVal)]  => handleConstructorWithArgs constructorVal args
      | _ =>  raise  Json.ERR "fromAList" "does not contain just constructor and data pairs"

      and
    handleNullConstructor (Json.String constructor) =
    case constructor
     of "SIG" => SIG
     |  "HSH" =>  HSH
     |  "NONCE" => NONCE
     | _ => raise Json.ERR "handleNullConstructor"  (String.concat ["Unexpected Null constructor for APDT term: ", constructor])

    and
    handleConstructorWithArgs (Json.String constructor) (Json.List args) =
        case constructor
         of "KIM" => getKIM args
         | "USM" =>  getUSM args
         | "AT"  =>  getAT args
         | "LN"  =>  getLN args
         | "BRS" =>  getBRS args
         | "BRP" =>  getBRP args
         |  _ =>  raise  Json.ERR "handleConstructorWithArgs" (String.concat ["Unexpected constructor for APDT term: ", constructor])

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
     BRS (stringToSp sp1, stringToSp sp2) (jsonToApdt term1) (jsonToApdt term2)
      | _ => raise  Json.ERR "getBRS" "unexpected argument list"
    and
    getBRP data =
    case data
     of [ Json.List [ (Json.String sp1), (Json.String sp2)], term1, term2] =>
     BRP (stringToSp sp1, stringToSp sp2) (jsonToApdt term1) (jsonToApdt term2)
      | _ => raise  Json.ERR "getBRP" "unexpected argument list"

(* json object to ev object *)
fun jsonToEvidence js =
    case js
     of Json.AList js' => fromAList js'
      | _ =>  raise  Json.ERR "JsonToEvidence" "APDT Evidence does not begin as an AList"

      and
    fromAList pairs =
    case pairs
     of [("constructor", constructorVal)] => handleNullConstructor constructorVal
     |  [("constructor", constructorVal), ("data", args)] => handleConstructorWithArgs constructorVal args
     |  [("data", args),  ("constructor", constructorVal)]  => handleConstructorWithArgs constructorVal args
     | _ =>  raise  Json.ERR "fromAList" "does not contain just constructor and data pairs"

    and
    handleNullConstructor (Json.String constructor) =
    case constructor
     of "Mt" => Mt
     | _ => raise Json.ERR "handleNullConstructor"  (String.concat ["Unexpected Null constructor for APDT Evidence: ", constructor])

    and
    handleConstructorWithArgs (Json.String constructor) (Json.List args) =
    case constructor
     of "K" => getK args
     | "U" =>  getU args
     | "G" =>  getG args
     | "H" =>  getH args
     | "N" =>  getN args
     | "SS"  =>  getSS args
     | "PP" =>  getPP args
     |  _ =>  raise  Json.ERR "handleConstructorWithArgs" (String.concat ["Unexpected constructor for APDT Evidence: ", constructor])

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
     | _ => raise Json.ERR "getPP" "unexpected argument list"

fun jsonToRequest js =
    case js
      of Json.AList js' => fromAList js'
       | _ => raise Json.ERR "JsonToRequest" "Request message does not begin as an AList"

    and
    fromAList pairs =
        case pairs
          of [("constructor", constructorVal), ("data", args)] => handleConstructorWithArgs constructorVal args
           | [("data", args), ("constructor", constructorVal)] => handleConstructorWithArgs constructorVal args
           | _ => raise Json.ERR "fromAList" "does not contain just constructor and data pairs"

    and
    handleConstructorWithArgs (Json.String constructor) (Json.List args) =
        case constructor
          of "REQ" => getREQ args
           |  _    => raise Json.ERR "handleConstructorWithArgs" (String.concat ["Unexpected constructor for REQ term: ", constructor])

    and
    getREQ data =
        case data
          of [Json.Number (Json.Int pl1), Json.Number (Json.Int pl2), Json.AList alist, t, ev] =>
                 REQ (natFromInt pl1) (natFromInt pl2) (toPlAddrMap alist) (jsonToApdt t) (jsonToEvidence ev)
           | _ => raise Json.ERR "getREQ" "unexpected argument list"

    and
    toPlAddrMap alist =
        let fun unjasonify (s, Json.String s') =
                case Int.fromString s
                  of Some i => (natFromInt i, s')
                   | _ => raise Json.ERR "toPlAddrMap" "unexpected non-integer"
         in Map.fromList nat_compare (List.map unjasonify alist)
        end

fun jsonToResponse js =
    case js
      of Json.AList js' => fromAList js'
       | _ => raise Json.ERR "JsonToResponse" "Response message does not begin as an AList"

    and
    fromAList pairs =
        case pairs
          of [("constructor", constructorVal), ("data", args)] => handleConstructorWithArgs constructorVal args
           | [("data", args), ("constructor", constructorVal)] => handleConstructorWithArgs constructorVal args
           | _ =>  raise Json.ERR "fromAList" "does not contain just constructor and data pairs"

    and
    handleConstructorWithArgs (Json.String constructor) (Json.List args) =
        case constructor
          of "RES" => getRES args
           |  _    => raise Json.ERR "handleConstructorWithArgs" (String.concat ["Unexpected constructor for RES term: ", constructor])

    and
    getRES data =
        case data
          of [Json.Number (Json.Int pl1), Json.Number (Json.Int pl2), ev] =>
                 RES (natFromInt pl1) (natFromInt pl2) (jsonToEvidence ev)
           | _ => raise Json.ERR "getRES" "unexpected argument list"

end
