(** val cvm_events_core :
    coq_Core_Term -> coq_Plc -> coq_Evidence -> coq_Ev list **)

(* CLEANUP: Try to push this into an extraction implementation, 
but not at the cost of proof validity.
Duplicated functionality by (extracted/Axioms_Io.cml) *)

fun cvm_events_core t p e = []

(** val cvm_events : coq_Term -> coq_Plc -> coq_Evidence -> coq_Ev list **)

fun cvm_events t p e =
  cvm_events_core (copland_compile t) p e


(** fun event_id_span' : coq_Term -> nat **)
(* Dummy value should be fine since this is a verification artifact *)

fun event_id_span' t = O
                  
(** fun event_id_span : coq_Core_Term -> nat **)
(* Dummy value should be fine since this is a verification artifact *)

fun event_id_span ct = O
