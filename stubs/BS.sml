(* Depends on:  util *)

(* CLEANUP: Low priority, maybe try to clean this up 
We would like aliases in one place if possible *)
type coq_BS = BString.bstring
type bs = coq_BS

(** val coq_Stringifiable_BS : coq_BS coq_Stringifiable **)

val coq_Stringifiable_BS : coq_BS coq_Stringifiable =
  Build_Stringifiable 
    (fn s => (BString.show s)) 
    (fn s => 
      Coq_resultC (BString.unshow s)
    handle Word8Extra.InvalidHex => 
      Coq_errC ("Invalid hex string: " ^ s)
      )

(** val coq_EqClass_BS : coq_BS coq_EqClass **)

val coq_EqClass_BS : coq_BS coq_EqClass =
    (fn bs1 => fn bs2 => bs1 = bs2)

val passed_bs = BString.fromString "UEFTU0VE"
val failed_bs = BString.fromString "FAILED"