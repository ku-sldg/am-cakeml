(* First we need to define the helper functions to get from Coq JSON to CakeML JSON *)

fun coq_JSON_to_CakeML_JSON (js : coq_JSON) =
  (case js of
    JSON_Object m =>
    Json.fromPairList 
      (List.map (fn (k, v) => (k, coq_JSON_to_CakeML_JSON v)) m) 
  | JSON_Array ls => 
    Json.fromList (List.map coq_JSON_to_CakeML_JSON ls)
  | JSON_String s => Json.fromString s
  | JSON_Boolean b => Json.fromBool b) : Json.json

(* NOTE: We cannot do perfect conversions since coq json doesnt support numbers yet *)
(** val coq_JSON_to_CakeML_JSON : coq_JSON -> (json, string) resultT **)

fun cakeML_JSON_to_coq_JSON js = 
  case js of
    Json.Object ascList => 
      let fun aux (k : string) (v : Json.json) = 
            (case cakeML_JSON_to_coq_JSON v of
              Coq_errC s => Coq_errC s
            | Coq_resultC v' => Coq_resultC (k, v')) : ((string * coq_JSON), string) coq_ResultT
          val mappedList : ((string * coq_JSON) list, string) coq_ResultT = 
            (result_map (fn (k,v) => aux k v) ascList)
      in
        case mappedList of
          Coq_errC s => Coq_errC s
        | Coq_resultC map' => Coq_resultC (JSON_Object map')
      end
  | Json.Array ls => 
      let val mappedList : (coq_JSON list, string) coq_ResultT = 
        result_map cakeML_JSON_to_coq_JSON ls
      in
        case mappedList of
          Coq_errC s => Coq_errC s
        | Coq_resultC ls' => Coq_resultC (JSON_Array ls')
      end
  | Json.String s => Coq_resultC (JSON_String s)
  | Json.Bool b => Coq_resultC (JSON_Boolean b)
  | _ => Coq_errC "Coq JSON must be an object, array, string, or bool at the top level"

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
