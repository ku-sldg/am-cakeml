(* First we need to define the helper functions to get from Coq JSON to CakeML JSON *)

fun coq_JSON_to_CakeML_JSON js =
  case js of
    JSON_Object m => 
      Json.fromPairList (List.map (fn (k, v) => (k, coq_JSON_to_CakeML_JSON v)) m)
  | JSON_Array ls =>
      Json.fromList (List.map coq_JSON_to_CakeML_JSON ls)
  | JSON_String s =>
      Json.fromString s
  | JSON_Boolean b =>
      Json.fromBool b
  | JSON_Null => Json.Null

(* NOTE: We cannot do perfect conversions since coq json doesnt support numbers yet *)
(** val coq_JSON_to_CakeML_JSON : coq_JSON -> (json, string) resultT **)

fun cakeML_JSON_to_coq_JSON js = 
  case js of
    Json.Null => Coq_resultC JSON_Null
  | Json.Int _ => Coq_errC "Int not supported"
  | Json.Float _ => Coq_errC "Float not supported"
  | Json.Bool b => Coq_resultC (JSON_Boolean b)
  | Json.String s => Coq_resultC (JSON_String s)
  | Json.Array ls => 
      (case (conv_list ls) of
        Coq_errC s => Coq_errC s
      | Coq_resultC ls' => Coq_resultC (JSON_Array ls'))
  | Json.Object map => 
      let val ascList : (string * Json.json) list = Map.toAscList map
      in
        case (conv_map ascList) of
          Coq_errC s => Coq_errC s
        | Coq_resultC map' => Coq_resultC (JSON_Object map')
      end
  and 
    conv_list js_list =
      (case js_list of
        [] => Coq_resultC []
      | h::t => 
        case cakeML_JSON_to_coq_JSON h of
          Coq_errC s => Coq_errC s
        | Coq_resultC h' => 
          case conv_list t of
            Coq_errC s => Coq_errC s
          | Coq_resultC t' => Coq_resultC (h'::t')) : (coq_JSON list, string) coq_ResultT
  and
    conv_map js_asc_list =
      (case js_asc_list of
        [] => (Coq_resultC [])
      | h::t =>
        let val (k, v) = h in
        case cakeML_JSON_to_coq_JSON v of
          Coq_errC s => Coq_errC s
        | Coq_resultC v' =>
          case (conv_map t) of
            Coq_errC s => Coq_errC s
          | Coq_resultC t' => 
            Coq_resultC ((k, v')::t')
        end) : ((string * coq_JSON) list, string) coq_ResultT


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

(** val coq_JSON_get_string :
    string -> coq_JSON -> (string, string) coq_ResultT **)

val coq_JSON_get_string = fn (s : string) => fn (js : coq_JSON) =>
  (let val cakejs : Json.json = coq_JSON_to_CakeML_JSON js in
  (case (Json.lookup s cakejs) of
    None => Coq_errC ("Key '" ^ s ^ "' not found")
  | Some js' => 
    case cakeML_JSON_to_coq_JSON js' of
      Coq_resultC (JSON_String s') => Coq_resultC s'
    | _ => Coq_errC "Not a string")
  end) : (string, string) coq_ResultT

(** val coq_JSON_get_bool :
    string -> coq_JSON -> (bool, string) coq_ResultT **)

val coq_JSON_get_bool = fn s => fn js =>
  let val cakejs : Json.json = coq_JSON_to_CakeML_JSON js in
  (case (Json.lookup s cakejs) of
    None => Coq_errC ("Key '" ^ s ^ "' not found")
  | Some js' => 
    case cakeML_JSON_to_coq_JSON js' of
      Coq_resultC (JSON_Boolean b') => Coq_resultC b'
    | _ => Coq_errC "Not a bool")
  end

(** val coq_JSON_get_JSON :
    string -> coq_JSON -> (coq_JSON, string) coq_ResultT **)
val coq_JSON_get_JSON = fn s => fn js =>
  let val cakejs : Json.json = coq_JSON_to_CakeML_JSON js in
  (case (Json.lookup s cakejs) of
    None => Coq_errC ("Key '" ^ s ^ "' not found")
  | Some js' => 
    case cakeML_JSON_to_coq_JSON js' of
      Coq_resultC js'' => Coq_resultC js''
    | Coq_errC s => Coq_errC s)
  end

(* NEED SOME STUPID BLANK SPACE AT THE END *)
