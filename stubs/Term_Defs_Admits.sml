(* NOTE: This file is sort of hacked together from pre-existing functions.
I wish we had a better way of doing this quickly and easily. *)

(** val coq_Term_to_stringT : coq_Term -> coq_StringT **)

val coq_Term_to_stringT = fn t => Json.stringify (termToJson t)

(** val stringT_to_Term :
    coq_StringT -> (coq_Term, coq_StringT) coq_ResultT **)

val stringT_to_Term = fn s => 
  case (Json.parse s) of 
    Err s => Coq_errC s
  | Ok js => 
    Coq_resultC (jsonToTerm js)
  handle 
    Json.Exn s1 s2 => Coq_errC s2
    | _ => Coq_errC "Failed to parse term"


(** val coq_Evidence_to_stringT : coq_Evidence -> coq_StringT **)

val coq_Evidence_to_stringT = fn ev => Json.stringify (evToJson ev)

(** val stringT_to_Evidence :
    coq_StringT -> (coq_Evidence, coq_StringT) coq_ResultT **)

val stringT_to_Evidence = fn s =>
  case (Json.parse s) of 
    Err s => Coq_errC s
  | Ok js => 
    Coq_resultC (jsonToEv js)
  handle
    Json.Exn s1 s2 => Coq_errC s2
    | _ => Coq_errC "Failed to parse evidence"

(** val coq_AppResultC_to_stringT : coq_AppResultC -> coq_StringT **)

val coq_AppResultC_to_stringT = fn ar => Json.stringify (appResultToJson ar)

(** val stringT_to_AppResultC :
    coq_StringT -> (coq_AppResultC, coq_StringT) coq_ResultT **)

val stringT_to_AppResultC = fn s =>
  case (Json.parse s) of 
    Err s => Coq_errC s
  | Ok js =>
    Coq_resultC (jsonToAppResultC js)
  handle
    Json.Exn s1 s2 => Coq_errC s2
    | _ => Coq_errC "Failed to parse app result"

(** val coq_RawEv_to_stringT : coq_RawEv -> coq_StringT **)

val coq_RawEv_to_stringT = fn rawEv => 
  (Json.stringify (Json.fromList (List.map (Json.fromString o BString.toCString) rawEv))) : coq_StringT


(** val stringT_to_RawEv_helper 
    : (Json.json list) -> (coq_RawEv, coq_StringT) coq_ResultT **)
fun stringT_to_RawEv_helper js_list =
  case (js_list) of 
    [] => Coq_resultC []
  | h :: t =>
      case Json.toString h of
        None => Coq_errC "Failed to parse raw evidence"
      | Some s =>
        case stringT_to_RawEv_helper t of
          Coq_errC s1 => Coq_errC s1
        | Coq_resultC ls => Coq_resultC (BString.fromCString s :: ls)

(** val stringT_to_RawEv :
    coq_StringT -> (coq_RawEv, coq_StringT) coq_ResultT **)

val stringT_to_RawEv = fn s =>
  (case (Json.parse s) of 
    Err s => Coq_errC s
  | Ok js =>
    case (Json.toList js) of
      None => Coq_errC "Failed to parse raw evidence"
    | Some ls =>
      stringT_to_RawEv_helper ls
  handle
    Json.Exn s1 s2 => Coq_errC s2
    | _ => Coq_errC "Failed to parse raw evidence") : (coq_RawEv, coq_StringT) coq_ResultT
