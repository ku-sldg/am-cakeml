
type coq_StringT = string

(* type coq_ID_Type = string 
fun coq_Eq_Class_ID_Type x y = (x = y)
val coq_ID_Type_ordering = String.compare
*)
fun coq_EqClass_StringT x y = (x = y)
  (* failwith "AXIOM TO BE REALIZED" *)
val coq_StringT_ordering = String.compare