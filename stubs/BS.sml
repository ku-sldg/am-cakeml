(* Depends on:  util *)

(* CLEANUP: Low priority, maybe try to clean this up 
We would like aliases in one place if possible *)
type coq_BS = BString.bstring
type bs = coq_BS

(** val coq_Serializable_BS : coq_BS coq_Serializable **)

val coq_Serializable_BS : coq_BS coq_Serializable =
  Build_Serializable (fn s => (BString.toString s)) (fn s => Coq_resultC (BString.fromString s))

val passed_bs = BString.fromString "PASSED"
val failed_bs = BString.fromString "FAILED"