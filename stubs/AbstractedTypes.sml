
type coq_ID_Type = string
(* AXIOM TO BE REALIZED *)
(** val coq_ID_Type_to_stringT : coq_ID_Type -> coq_StringT **)

val coq_ID_Type_to_stringT = fn x => x

(** val stringT_to_ID_Type :
    coq_StringT -> (coq_ID_Type, coq_StringT) coq_ResultT **)

val stringT_to_ID_Type = fn x => x

(** val coq_Eq_Class_ID_Type : coq_ID_Type coq_EqClass **)

fun coq_Eq_Class_ID_Type x y = (x = y)
  (* failwith "AXIOM TO BE REALIZED" *)
val coq_ID_Type_ordering = String.compare

