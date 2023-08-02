(* Filling in stubs from extracted definitions in extracted/CvmJson_Admits.cml *)

type coq_JsonT = Json.json

type coq_StringT = string


(*

(** val jsonToCvmIn : coq_JsonT -> coq_CvmInMessage **)
fun jsonToCvmIn js = case (Json.toMap js) of
          Some js' => fromAList js'
        | None => raise Json.Exn "jsonToCvmIn" "CvmIn message does not begin as an object."

    and
    fromAList pairs =
        let fun get str = case Map.lookup pairs str of
                  Some x => x
                | None   => raise Json.Exn "fromAList" "missing cvmIn message field"
         in getREQ (List.map get ["cvmTerm", "cvmInEv"])
        end

    and
    getREQ data = case data of
          [t, ev] =>
              CVM_IN (jsonToTerm t) (jsonBsListToList ev)
        | _ => raise Json.Exn "getREQ for CVM_IN" "unexpected argument list"

(** val jsonToCvmOut : coq_JsonT -> coq_CvmOutMessage **)
fun jsonToCvmOut js = case (Json.toMap js) of
          Some js' => fromAList js'
        | _ => raise Json.Exn "JsonToCvmOut" "CvmOut Response message does not begin as an AList"

    and
    fromAList pairs =
        let fun get str = case Map.lookup pairs str of
                  Some x => x
                | None   => raise Json.Exn "fromAList" "missing cvmOut response field"
         in getRES (List.map get ["cvmOutEv"])
        end

    and
    getRES data = case data of
          [ev] => (jsonBsListToList ev)
              (* CVM_OUT (jsonBsListToList ev) *)
        | _ => raise Json.Exn "getRES for CVM_OUT" "unexpected argument list"

(** val cvmInMessageToJson : coq_CvmInMessage -> coq_JsonT **)
fun cvmInMessageToJson (CVM_IN t ev) = Json.fromPairList
    [("cvmTerm", termToJson t), 
     ("cvmInEv", bsListToJsonList ev)]

(** val cvmOutMessageToJson : coq_CvmOutMessage -> coq_JsonT **)
fun cvmOutMessageToJson (ev) = Json.fromPairList
    [("cvmOutEv", bsListToJsonList ev)]


(* 
fun cvmInMessageToJson x = Json.Null
  (* failwith "AXIOM TO BE REALIZED" *)



fun cvmOutMessageToJson x = Json.Null
  (* failwith "AXIOM TO BE REALIZED" *)

*)

*)


(* fun isCvmReqJson : coq_JsonT -> bool *)
fun isCvmReqJson js = case (Json.toMap js) of 
    Some js' => fromAList js'
  | None => False

  and
  fromAList pairs =
        let fun get str = case Map.lookup pairs str of
                  Some x => True
                | None   => False
         in getREQ (List.map get ["reqTerm", "reqAuthTok", "reqEv"])
        end

  and
  getREQ data = case data of
          [True, True, True] => True
        | _ => False


(* fun isAppReqJson : coq_JsonT -> bool *)
fun isAppReqJson js = case (Json.toMap js) of 
    Some js' => fromAList js'
  | None => False

  and
  fromAList pairs =
        let fun get str = case Map.lookup pairs str of
                  Some x => True
                | None   => False
         in getREQ (List.map get ["appReqTerm", "appReqPlc", "appReqEt", "appReqEv"])
        end

  and
  getREQ data = case data of
          [True, True, True, True] => True
        | _ => False


(** val jsonToAmRequest : coq_JsonT -> coq_AM_RequestMessage **)

fun jsonToAmRequest js =  
(*
      let val cvmreq = jsonToRequest js in 
            (CVM_REQ cvmreq)
      end 
      *)
      case (isCvmReqJson js) of 
        True => 
          let val cvmreq = jsonToRequest js in 
            (CVM_REQ cvmreq)
          end 
      | False => 
          case (isAppReqJson js) of 
            True =>  
              let val appreq = jsonToAppRequest js in 
                (APP_REQ appreq) 
              end
          | False => 
              raise Json.Exn "jsonToAmRequest" "Request is NOT one of the expected AM Requests:  CVM | Appraisal"
            