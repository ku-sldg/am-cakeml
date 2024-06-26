(* First we need to define the helper functions to get from Coq JSON to CakeML JSON *)

fun coq_JSON_to_CakeML_JSON (js : coq_JSON) =
  (case js of
    JSON_Object m =>
    Json.fromPairList 
      (List.map (fn (k, v) => (k, coq_InnerJSON_to_CakeML_JSON v)) m)) : Json.json
  and coq_InnerJSON_to_CakeML_JSON (ijs : coq_InnerJSON) =
    case ijs of
      InJSON_String s => Json.fromString s
    | InJSON_Object js' => coq_JSON_to_CakeML_JSON js'
    | InJSON_Boolean b => Json.fromBool b
    | InJSON_Array ls => 
        Json.fromList (List.map coq_InnerJSON_to_CakeML_JSON ls)

(* NOTE: We cannot do perfect conversions since coq json doesnt support numbers yet *)
(** val coq_JSON_to_CakeML_JSON : coq_JSON -> (json, string) resultT **)

fun cakeML_JSON_to_coq_JSON js = 
  case js of
    Json.Object map => 
      let val ascList : (string * Json.json) list = Map.toAscList map
          fun aux (k : string) (v : Json.json) = 
            (case cakeML_JSON_to_coq_InnerJSON v of
              Coq_errC s => Coq_errC s
            | Coq_resultC v' => Coq_resultC (k, v')) : ((string * coq_InnerJSON), string) coq_ResultT
          val mappedList : ((string * coq_InnerJSON) list, string) coq_ResultT = 
            (result_map (fn (k,v) => aux k v) ascList)
      in
        case mappedList of
          Coq_errC s => Coq_errC s
        | Coq_resultC map' => Coq_resultC (JSON_Object map')
      end
  | _ => Coq_errC "Coq JSON must be an object at the top level"
  (* and 
    result_mapping f ls = 
      case ls of
        [] => Coq_resultC []
      | h::t => 
        case f h of
          Coq_errC s => Coq_errC s
        | Coq_resultC h' => 
          case result_mapping f t of
            Coq_errC s => Coq_errC s
          | Coq_resultC t' => Coq_resultC (h'::t') *)
  and 
    cakeML_JSON_to_coq_InnerJSON (js : Json.json) = 
      case js of
        Json.Object map => 
          let val recJs : (coq_JSON, string) coq_ResultT = 
              cakeML_JSON_to_coq_JSON js
          in
            case recJs of
              Coq_errC s => Coq_errC s
            | Coq_resultC js' => Coq_resultC (InJSON_Object js')
          end
      | Json.Array ls => 
          let val mappedList : (coq_InnerJSON list, string) coq_ResultT = 
            result_map cakeML_JSON_to_coq_InnerJSON ls
          in
            case mappedList of
              Coq_errC s => Coq_errC s
            | Coq_resultC ls' => Coq_resultC (InJSON_Array ls')
          end
      | Json.String s => Coq_resultC (InJSON_String s)
      | Json.Bool b => Coq_resultC (InJSON_Boolean b)
      | _ => Coq_errC "Only objects, arrays, strings, and booleans are supported"

(* Now we can define the functions to convert between Coq JSON and CakeML JSON *)

(** val coq_JSON_to_string : coq_JSON -> string **)

val coq_JSON_to_string = 
  fn cjs => Json.stringify (coq_JSON_to_CakeML_JSON cjs)

(** val string_to_JSON :
    string -> (coq_JSON, string) coq_ResultT **)

val string_to_JSON =
  fn (s : string) => 
    (case Json.parse s of
      Err s => Coq_errC s
    | Ok j => cakeML_JSON_to_coq_JSON j) : (coq_JSON, string) coq_ResultT

(* NEED SOME STUPID BLANK SPACE AT THE END *)
