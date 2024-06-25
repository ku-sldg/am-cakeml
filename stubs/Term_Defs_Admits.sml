(* NOTE: This file is sort of hacked together from pre-existing functions.
I wish we had a better way of doing this quickly and easily. *)

(** val coq_Term_to_string : coq_Term -> string **)

val coq_Term_to_string = fn t => Json.stringify (termToJson t)

(** val string_to_Term :
    string -> (coq_Term, string) coq_ResultT **)

val string_to_Term = fn s => 
  case (Json.parse s) of 
    Err s => Coq_errC s
  | Ok js => 
    Coq_resultC (jsonToTerm js)
  handle 
    Json.Exn s1 s2 => Coq_errC s2
    | _ => Coq_errC "Failed to parse term"


(** val coq_Evidence_to_string : coq_Evidence -> string **)

val coq_Evidence_to_string = fn ev => Json.stringify (evToJson ev)

(** val string_to_Evidence :
    string -> (coq_Evidence, string) coq_ResultT **)

val string_to_Evidence = fn s =>
  case (Json.parse s) of 
    Err s => Coq_errC s
  | Ok js => 
    Coq_resultC (jsonToEv js)
  handle
    Json.Exn s1 s2 => Coq_errC s2
    | _ => Coq_errC "Failed to parse evidence"

(** val coq_AppResultC_to_string : coq_AppResultC -> string **)

val coq_AppResultC_to_string = fn ar => Json.stringify (appResultToJson ar)

(** val string_to_AppResultC :
    string -> (coq_AppResultC, string) coq_ResultT **)

val string_to_AppResultC = fn s =>
  case (Json.parse s) of 
    Err s => Coq_errC s
  | Ok js =>
    Coq_resultC (jsonToAppResultC js)
  handle
    Json.Exn s1 s2 => Coq_errC s2
    | _ => Coq_errC "Failed to parse app result"

(** val coq_RawEv_to_string : coq_RawEv -> string **)

val coq_RawEv_to_string = fn rawEv => 
  (Json.stringify (Json.fromList (List.map (Json.fromString o BString.show) rawEv))) : string


(** val string_to_RawEv_helper 
    : (Json.json list) -> (coq_RawEv, string) coq_ResultT **)
fun string_to_RawEv_helper js_list =
  case (js_list) of 
    [] => Coq_resultC []
  | h :: t =>
      case Json.toString h of
        None => Coq_errC "Failed to parse raw evidence"
      | Some s =>
        case string_to_RawEv_helper t of
          Coq_errC s1 => Coq_errC s1
        | Coq_resultC ls => Coq_resultC (BString.unshow s :: ls)

(** val string_to_RawEv :
    string -> (coq_RawEv, string) coq_ResultT **)

val string_to_RawEv = fn s =>
  (case (Json.parse s) of 
    Err s => Coq_errC s
  | Ok js =>
    case (Json.toList js) of
      None => Coq_errC "Failed to parse raw evidence"
    | Some ls =>
      string_to_RawEv_helper ls
  handle
    Json.Exn s1 s2 => Coq_errC s2
    | _ => Coq_errC "Failed to parse raw evidence") : (coq_RawEv, string) coq_ResultT


(** val coq_ASP_ARGS_to_string : coq_ASP_ARGS -> string **)

val coq_ASP_ARGS_to_string = coq_ASP_ARGS_to_string
