(** val cvm_events_core :
    coq_Core_Term -> coq_Plc -> coq_Evidence -> coq_Ev list **)

fun cvm_events_core t p e = []
(*
  failwith "AXIOM TO BE REALIZED" *)

(** val cvm_events : coq_Term -> coq_Plc -> coq_Evidence -> coq_Ev list **)

fun cvm_events t p e =
  cvm_events_core (copland_compile t) p e