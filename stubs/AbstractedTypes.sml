
type coq_ID_Type = string
(* AXIOM TO BE REALIZED *)
(** val coq_ID_Type_to_string : coq_ID_Type -> string **)

val coq_ID_Type_to_string = fn x => x

(** val string_to_ID_Type :
    string -> (coq_ID_Type, string) coq_ResultT **)

val string_to_ID_Type = fn x => Coq_resultC x

(** val coq_Eq_Class_ID_Type : coq_ID_Type coq_EqClass **)

fun coq_Eq_Class_ID_Type x y = (x = y)

val coq_ID_Type_ordering = String.compare

