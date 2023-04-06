(* Depends on:  util *)

(* CLEANUP: Low priority, maybe try to clean this up 
We would like aliases in one place if possible *)
type coq_BS = BString.bstring
type bs = coq_BS

type coq_ID_Type = string
fun coq_Eq_Class_ID_Type x y = (x = y)
val coq_ID_Type_ordering = String.compare

(** val eqb : 'a1 coq_EqClass -> 'a1 -> 'a1 -> bool **)

fun eqb eqClass =
  eqClass

val passed_bs = BString.fromString "PASSED"
val failed_bs = BString.fromString "FAILED"
