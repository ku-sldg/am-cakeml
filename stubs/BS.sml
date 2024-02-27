(* Depends on:  util *)

(* CLEANUP: Low priority, maybe try to clean this up 
We would like aliases in one place if possible *)
type coq_BS = BString.bstring
type bs = coq_BS

(* type coq_ID_Type = string 
fun coq_Eq_Class_ID_Type x y = (x = y)
val coq_ID_Type_ordering = String.compare
*)

val passed_bs = BString.fromString "PASSED"
val failed_bs = BString.fromString "FAILED"

structure Nat = struct
  fun eqb x y = (x = y)

end
