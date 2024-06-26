
type coq_ID_Type = string

(** val coq_Serializable_ID_Type : coq_ID_Type coq_Serializable **)
val coq_Serializable_ID_Type : coq_ID_Type coq_Serializable =
  Build_Serializable (fn s => s) (fn s => Coq_resultC s)

(** val coq_Eq_Class_ID_Type : coq_ID_Type coq_EqClass **)

fun coq_Eq_Class_ID_Type x y = (x = y)

val coq_ID_Type_ordering = String.compare

