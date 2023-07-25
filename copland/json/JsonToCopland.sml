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

fun jsonIntToNat (Json.Int i) = natFromInt i
fun jsonIntListToNatList (Json.Array args) =
    List.map jsonIntToNat args


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
          [Json.String aspid, arrayArgs, Json.String plc, Json.String targid] =>
            Coq_asp_paramsC aspid (jsonStringListToList arrayArgs) plc targid
        | _ => raise Json.Exn "getAspParamsArray" "unexpected Coq_asp_paramsC params"                     

(* jsonToTerm : json -> coq_Term 
   (json object to Copland phrase)  *)      
fun jsonToTerm js = case (Json.toMap js) of
                    (* Json.toMap : json -> ((string,json) map) option *)
      Some m => fromJsonMap m getTerm (* m : (string,json) map *)
    | None =>
        raise Json.Exn "jsonToTerm" "Copland term JSON does not begin as an AList"

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
    [Json.String q] => ENC q
        
                    | _ => raise Json.Exn "getAspc" "unexpected argument list"
    and
    getAtt data =
    case data of
        [ Json.String place, term] => Coq_att place (jsonToTerm term)
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
        raise Json.Exn "jsonToEv" "Copland Evidence does not begin as an AList"

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
        [Json.String q, Json.String fwdStr, paramsJsonOb, e'] =>
        Coq_uu q (fwdFromString fwdStr) (json_ObToTerm paramsJsonOb getAspParams)
               (jsonToEv e')
      | _ => raise Json.Exn "getUU" "unexpected argument list"

    and
    getSS args =
    case args of

        [e1, e2] =>
        Coq_ss (jsonToEv e1) (jsonToEv e2)
      | _ => raise Json.Exn "getSS" "unexpected argument list"


(* jsonToEv : json -> coq_AppResultC
   (json object to Copland Appraisal Result Type)  *)      
fun jsonToAppResultC js = case (Json.toMap js) of
                    (* Json.toMap : json -> ((string,json) map) option *)
      Some m => fromJsonMap m getEvidence (* js' : (string,json) map *)
    | None =>
        raise Json.Exn "jsonToAppResultC" "Copland Appraisal Result does not begin as an AList"

    and
    getEvidence constructor (Json.Array args) =
    case constructor of
        "mtc_app" => Coq_mtc_app
      | "nnc_app" => getNN args
      | "ggc_app" => getGG args
      | "hhc_app" => getHH args
      | "eec_app" => getEE args
      | "ssc_app" => getSS args
      |  _ => raise Json.Exn "getEvidence"
                    ("Unexpected constructor for Copland Appraisal Result: " ^
                     constructor)
                    

    (* getAspc :: json list -> coq_Evidence *)
    and                              
    getNN args =  case args of
    [Json.Int q, bs] => Coq_nnc_app (natFromInt q) (jsonStringToBS bs)

    and
    getGG args =
    case args of
        [Json.String q, paramsJsonOb, bs, e'] =>
        Coq_ggc_app q (json_ObToTerm paramsJsonOb getAspParams)
                      (jsonStringToBS bs) (jsonToAppResultC e')
      | _ => raise Json.Exn "getGG" "unexpected argument list for AppResultC"
    and
    getHH args =
    case args of
        [Json.String q, paramsJsonOb, bs, e'] =>
        Coq_hhc_app q (json_ObToTerm paramsJsonOb getAspParams)
                      (jsonStringToBS bs) (jsonToAppResultC e')
      | _ => raise Json.Exn "getHH" "unexpected argument list for AppResultC"
    and
    getEE args =
    case args of
        [Json.String q, paramsJsonOb, bs, e'] =>
        Coq_eec_app q (json_ObToTerm paramsJsonOb getAspParams)
                      (jsonStringToBS bs) (jsonToAppResultC e')
      | _ => raise Json.Exn "getEE" "unexpected argument list for AppResultC"
    and
    getSS args =
    case args of

        [e1, e2] =>
        Coq_ssc_app (jsonToAppResultC e1) (jsonToAppResultC e2)
      | _ => raise Json.Exn "getSS" "unexpected argument list"


(* jsonToEvC : json -> coq_EvC
   (json object to Copland EvC Type)  *)      
fun jsonToEvC js = case (Json.toMap js) of (* Json.toMap : json -> ((string,json) map) option *)
                       Some m => fromJsonMap m getEvC (* js' : (string,json) map *)
                     | None =>
                       raise Json.Exn "jsonToTerm" "Copland term does not begin as an AList"

                     and
                     getEvC constructor (Json.Array args) =
                     case constructor of
                         "EvC" => getEvcArgs args
                      | _ => raise Json.Exn "getEvC"
                    ("Unexpected constructor for Copland EvC: " ^
                     constructor)
                            (*
      | "NN" => getNN args
      | "UU" => getUU args
      | "SS" => getSS args
      |  _ => raise Json.Exn "getEvidence"
                    ("Unexpected constructor for Copland Evidence: " ^
                     constructor) *)
                    

    (* getEvcArgs :: json list -> coq_EvC *)
                     and                              
                     getEvcArgs args = case args of
                                           [ev, et] =>
                                           Coq_evc (jsonBsListToList ev) (jsonToEv et)


(* fun jsonToRequest : coq_JsonT -> coq_CvmRequestMessage  *)
fun jsonToRequest js = case (Json.toMap js) of
          Some js' => fromAList js'
        | None => raise Json.Exn "JsonToRequest" "Request message does not begin as an object."

    and
    fromAList pairs =
        let fun get str = case Map.lookup pairs str of
                  Some x => x
                | None   => raise Json.Exn "fromAList (REQ)" "missing request field"
         in getREQ (List.map get ["reqTerm", "reqAuthTok", "reqEv"])
        end

    and
    getREQ data = case data of
          [t, authTok, ev] =>
              REQ (jsonToTerm t) (jsonToEvC authTok) (jsonBsListToList ev)
        | _ => raise Json.Exn "getREQ" "unexpected argument list"

(* fun jsonToResponse : coq_JsonT -> coq_CvmResponseMessage  *)
fun jsonToResponse js = case (Json.toMap js) of
          Some js' => fromAList js'
        | _ => raise Json.Exn "JsonToResponse" "Response message does not begin as an AList"

    and
    fromAList pairs =
        let fun get str = case Map.lookup pairs str of
                  Some x => x
                | None   => raise Json.Exn "fromAList" "missing request field"
         in getRES (List.map get ["respEv"])
        end

    and
    getRES data = case data of
          [ev] => (jsonBsListToList ev)
              (* RES (jsonBsListToList ev) *)
        | _ => raise Json.Exn "getRES" "unexpected argument list"



(* fun jsonToAppRequest : coq_JsonT -> coq_AppraisalRequestMessage  *)
fun jsonToAppRequest js = case (Json.toMap js) of
          Some js' => fromAList js'
        | None => raise Json.Exn "JsonToAppRequest" "Request message does not begin as an object."

    and
    fromAList pairs =
        let fun get str = case Map.lookup pairs str of
                  Some x => x
                | None   => raise Json.Exn "fromAList (REQ_APP)" "missing request field"
         in getREQ (List.map get ["appReqTerm", "appReqPlc", "appReqEt", "appReqEv"])
        end

    and
    getREQ data = case data of
          [t, (Json.String p), et, ev] =>
              REQ_APP (jsonToTerm t) (p) (jsonToEv et) (jsonBsListToList ev)
        | _ => raise Json.Exn "getREQ_APP" "unexpected argument list"

(* fun jsonToAppResponse : coq_JsonT -> coq_AppraisalResponseMessage  *)
fun jsonToAppResponse js = case (Json.toMap js) of
          Some js' => fromAList js'
        | _ => raise Json.Exn "JsonToResponse" "Response message does not begin as an AList"

    and
    fromAList pairs =
        let fun get str = case Map.lookup pairs str of
                  Some x => x
                | None   => raise Json.Exn "fromAList APP" "missing request field"
         in getRES (List.map get ["appRespRes"])
        end

    and
    getRES data = case data of
          [ev] => (jsonToAppResultC ev)
              (* RES (jsonBsListToList ev) *)
        | _ => raise Json.Exn "getRES" "unexpected argument list"




fun strToJson str = 
    let val jp = (Json.parse str)
        val jpOk = case jp of
                      Err e => raise (Exception ("Json Parsing Error: Attempting to parse string '" ^ str ^ "' and encountered error '" ^ e ^ "'\n"))
                      | Ok v => v
    in
      jpOk
    end

fun jsonToStr js  = Json.stringify js


                                   
(* 
   fun encode_RawEv : coq_RawEv -> coq_BS 

   This function takes a coq_RawEv value (list of coq_BS values) and encodes it as a single
   coq_BS value (to, for instance prepare it for cryptographic transformation).  To encode, 
   we first take the raw evidence sequence to an Array of Json strings (am/CommTypes.bsListToJsonList).
   Next, we "stringify" that Array (am/ServerAM.jsonToStr) to a single string.  Finally, we lift
   that string into a bstring (BString.fromString).
*)
(* CLEANUP: Find a place to move this so it better fits *)
fun encode_RawEv ls = BString.fromString (jsonToStr (bsListToJsonList ls))
