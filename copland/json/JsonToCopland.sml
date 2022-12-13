(* Depends on: util, extracted/ *)

(* spFromString :: string -> coq_SP *)
fun spFromString n =
    case n
    of  "ALL" => ALL
    |   "NONE" => NONE

(* fwdFromString :: string -> coq_FWD *)
fun fwdFromString n =
    case n of
        "COMP" => COMP
      | "EXTD" => EXTD
      | "ENCR" => ENCR
      | "KILL" => KILL
      | "KEEP" => KEEP

fun jsonStringToString (Json.String s) = s
fun jsonStringListToList (Json.Array args) =
    List.map jsonStringToString args

(* jsonStringToBS : json -> coq_BS *)
fun jsonStringToBS (Json.String s) = BString.unshow s

(* jsonBsListToList : json -> coq_BS list *)
fun jsonBsListToList (Json.Array args) =
    List.map jsonStringToBS args


fun getConstructorString c =
    case c of
        (Json.String s) => s
      | _ => raise Json.Exn "getConstructorString" "did not find a Json.String in the 'constructor' field"



(* fromJsonMap :: (string,json) map -> (string -> Json.Array(json) -> T) -> T

   parameters:
   - m:  map from string to json objects.  This is the map representation of 
         the json object.
   - f:  function that takes as input the constructor name string, the 
         Json Array of constructor arguments, and returns the decoded term 
         of type T.
   returns:  decoded term of type T (upon sucessful json decoding)
   error:  Json.Exn (unexpected Json object structure for target term :: T)
*)

fun fromJsonMap m f = fromAList (Map.toAscList m) f
                                
  and
  fromAList pairs f =
  case pairs of
      [("constructor", constructorVal), ("data", args)] =>
      f (getConstructorString constructorVal) args
    | [("data", args), ("constructor", constructorVal)] =>
      f (getConstructorString constructorVal) args
    | [("constructor", constructorVal)] =>
      f (getConstructorString constructorVal) (Json.Array [])
    | _ =>
      raise Json.Exn "fromAList" "does not contain just constructor and data pairs"

(* json_ObToTerm :: Json.Object(json) -> (string -> Json.Array(json) -> T) -> T *)
fun json_ObToTerm ob f =
    case ob of
        (Json.Object m) => fromJsonMap m f
     | _ => raise Json.Exn "json_ObToTerm" "expected Json.Object parameter"

(* getAspParams :: string -> Json.Array(json) -> coq_ASP_PARAMS *)
fun getAspParams constructor (Json.Array args) =
    case constructor of
        "asp_paramsC" => getAspParamsArray args
      | _ => raise Json.Exn "getAspParams" "unexpected asp_paramsC constructor name"
    

    (* getAspParamsArray :: json list -> coq_ASP_PARAMS
       Expected:  [Json.String aspid, 
                   Json.Array [Json.String stringArg1, Json.String stringArg2, ...], 
                   Json.Int plc, 
                   Json.String targid] *)              
    and
    getAspParamsArray js = (* Coq_asp_paramsC "" [] O "" *)
      case js of
          [Json.String aspid, arrayArgs, Json.Int plc, Json.String targid] =>
            Coq_asp_paramsC aspid (jsonStringListToList arrayArgs)  (natFromInt plc) targid
        | _ => raise Json.Exn "getAspParamsArray" "unexpected Coq_asp_paramsC params"


(* jsonToTerm : json -> coq_Term 
   (json object to Copland phrase)  *)      
fun jsonToTerm js = case (Json.toMap js) of
                    (* Json.toMap : json -> ((string,json) map) option *)
      Some m => fromJsonMap m getTerm (* m : (string,json) map *)
    | None =>
        raise Json.Exn "jsonToTerm" "Copland term does not begin as an AList"

    and
    getTerm constructor (Json.Array args) =
        case constructor of
            "Asp"  => Coq_asp (getAsp args)
                              
          | "Att"  => getAtt args                                          
          | "Lseq" => getLseq args
                              
          | "Bseq" => getBseq args
                              
          | "Bpar" => getBpar args
          |  _ => raise Json.Exn "getTerm"
                        ("Unexpected constructor for Copland term: " ^
                         constructor)
                     
                    
    and
    (* getAsp :: json list -> coq_ASP
       Expected:  [Json.Object [("constructor", name), ("data", Json.Array args)]
       where name = "Null" | "Cpy" | "Aspc" | "Sig" | "Hsh" | "Enc"
     *)
    getAsp data = case data of
          [Json.Object m] => fromJsonMap m getAsp' (* getAspFromAList (Map.toAscList js') *)
                   | _ => raise Json.Exn "getAsp" "Copland Asp term does not begin as an AList"


    and
    getAsp' constructor (Json.Array args) =
    case constructor of
        "Aspc" => getAspc args
      | "Enc" => getEnc args
      | "Cpy" => CPY
      | "Null" => NULL 
      | "Sig" => SIG
      | "Hsh" => HSH
      |  _ => raise Json.Exn "getTerm"
                    ("Unexpected ASP constructor name for Copland term: " ^
                     constructor)

    (* getAspc :: Json.Array -> coq_ASP *)
    and                              
    getAspc args = case args of
    (* args :: json list 
       Expected: [Json.String "ALL" | "NONE", Json.String "COMP" | "EXTD" | ...,  
                  Json.Object [("constructor", "asp_paramsC"), ("data", ...)]]      *)
    [Json.String spStr, Json.String fwdStr, paramsJsonOb] =>
    ASPC (spFromString spStr) (fwdFromString fwdStr)
         (json_ObToTerm paramsJsonOb getAspParams)
                    | _ => raise Json.Exn "getAspc" "unexpected argument list"

                                 
    (* getEnc :: json list -> coq_ASP *)             
    and
    getEnc args = case args of
    [Json.Int q] => ENC (natFromInt q)
        
                    | _ => raise Json.Exn "getAspc" "unexpected argument list"
    and
    getAtt data =
    case data of
        [ Json.Int place, term] => Coq_att (natFromInt place) (jsonToTerm term)
      | _ => raise  Json.Exn "getAtt" "unexpected argument list"
                  
    and
    getLseq data = case data of
          [term1, term2] => Coq_lseq (jsonToTerm term1) (jsonToTerm term2)
        | _ => raise  Json.Exn "getLseq" "unexpected argument list"

    and
    getBseq data = case data of
          [ Json.Array [Json.String sp1, Json.String sp2], term1, term2] =>
            Coq_bseq (Coq_pair (spFromString sp1) (spFromString sp2)) (jsonToTerm term1) (jsonToTerm term2)
        | _ => raise  Json.Exn "getBseq" "unexpected argument list"
    and
    getBpar data = case data of
          [ Json.Array [Json.String sp1, Json.String sp2], term1, term2] =>
            Coq_bpar (Coq_pair (spFromString sp1) (spFromString sp2)) (jsonToTerm term1) (jsonToTerm term2)
        | _ => raise  Json.Exn "getBpar" "unexpected argument list"



                      
(* jsonToEv : json -> coq_Evidence
   (json object to Copland Evidence Type)  *)      
fun jsonToEv js = case (Json.toMap js) of
                    (* Json.toMap : json -> ((string,json) map) option *)
      Some m => fromJsonMap m getEvidence (* js' : (string,json) map *)
    | None =>
        raise Json.Exn "jsonToTerm" "Copland term does not begin as an AList"

    and
    getEvidence constructor (Json.Array args) =
    case constructor of
        "Mt" => Coq_mt
      | "NN" => getNN args
      | "UU" => getUU args
      | "SS" => getSS args
      |  _ => raise Json.Exn "getEvidence"
                    ("Unexpected constructor for Copland Evidence: " ^
                     constructor)
                    

    (* getAspc :: json list -> coq_Evidence *)
    and                              
    getNN args =  case args of
    [Json.Int q] => Coq_nn (natFromInt q)

    and
    getUU args =
    case args of
        [Json.Int q, Json.String fwdStr, paramsJsonOb, e'] =>
        Coq_uu (natFromInt q) (fwdFromString fwdStr) (json_ObToTerm paramsJsonOb getAspParams)
               (jsonToEv e')
      | _ => raise Json.Exn "getUU" "unexpected argument list"

    and
    getSS args =
    case args of

        [e1, e2] =>
        Coq_ss (jsonToEv e1) (jsonToEv e2)
      | _ => raise Json.Exn "getSS" "unexpected argument list"
