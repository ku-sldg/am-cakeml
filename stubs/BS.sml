(* Depends on:  util *)
type coq_BS = BString.bstring
type bs = coq_BS

val empty_bs = BString.empty

val default_bs = empty_bs

val passed_bs = BString.fromString "PASSED"
val failed_bs = BString.fromString "FAILED"
