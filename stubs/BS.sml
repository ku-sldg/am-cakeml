(* Depends on:  util *)

(* CLEANUP: Low priority, maybe try to clean this up 
We would like aliases in one place if possible *)
type coq_BS = BString.bstring
type bs = coq_BS

(** val coq_Stringifiable_BS : coq_BS coq_Stringifiable **)

val coq_Stringifiable_BS : coq_BS coq_Stringifiable =
  Build_Stringifiable (fn s => (BString.toString s)) (fn s => Coq_resultC (BString.fromString s))

val passed_bs = BString.fromString "PASSED"
val failed_bs = BString.fromString "FAILED"