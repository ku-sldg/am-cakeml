(* Depends on:  util *)

(* CLEANUP: Low priority, maybe try to clean this up 
We would like aliases in one place if possible *)
type coq_BS = BString.bstring
type bs = coq_BS

val passed_bs = BString.fromString "PASSED"
val failed_bs = BString.fromString "FAILED"
