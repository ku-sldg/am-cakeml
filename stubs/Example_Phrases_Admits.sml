(** val coq_P0 : coq_Plc **)

val coq_P0 = "P0"
  (* failwith "AXIOM TO BE REALIZED" *)

(** val coq_P1 : coq_Plc **)
(*
val coq_P1 = "P1"
  (* failwith "AXIOM TO BE REALIZED" *)
*)

(** val coq_P2 : coq_Plc **)

val coq_P2 = "P2"
  (* failwith "AXIOM TO BE REALIZED" *)

val coq_P3 = "P3"
  (* failwith "AXIOM TO BE REALIZED" *)

val coq_P4 = "P4"
  (* failwith "AXIOM TO BE REALIZED" *)

val default_place = "default_place"
  (* failwith "AXIOM TO BE REALIZED" *)

(** val attest_id : coq_ASP_ID **)

val attest_id = "attest_aspid"
  (* failwith "AXIOM TO BE REALIZED" *)

(*
val attest1_id = "attest1_aspid"
val attest2_id = "attest2_aspid"
*)

(** val appraise_id : coq_ASP_ID **)

val appraise_id = "appraise_aspid"
 (* failwith "AXIOM TO BE REALIZED" *)

val appraise_inline_id = "appraise_inline_aspid"
 (* failwith "AXIOM TO BE REALIZED" *)

(** val cert_id : coq_ASP_ID **)

val cert_id = "cert_aspid"
  (* failwith "AXIOM TO BE REALIZED" *)

val cache_id = "cache_aspid"
  (* failwith "AXIOM TO BE REALIZED" *)

val store_args = []
  (* failwith "AXIOM TO BE REALIZED" *)

(** val appraise_inline_args : coq_Arg list **)
val appraise_inline_args : coq_Arg list = 
  let val appReq = (REQ_APP example_phrase_p2_appraise coq_P1 (Coq_nn O) [])
      val jsonAppReq = appRequestToJson appReq
      val strJsonAppReq = jsonToStr jsonAppReq in 
        [(strJsonAppReq)]
  end
  (* failwith "AXIOM TO BE REALIZED"  *)

(* 

datatype coq_AppraisalRequestMessage =
  REQ_APP coq_Term coq_Plc coq_Evidence coq_RawEv
  
  val jsonReq = appRequestToJson req
      val strJsonReq = jsonToStr jsonReq
  
  
  
  
  
   *)


(*
(** val sys : coq_TARG_ID **)
val sys = "sys_targid"
  (* failwith "AXIOM TO BE REALIZED" *)
*)

(** val att_tid : coq_TARG_ID **)

val att_tid = "att_targid"
  (* failwith "AXIOM TO BE REALIZED" *)


(** val it : coq_TARG_ID **)

val it = "it_targid"
  (* failwith "AXIOM TO BE REALIZED" *)

(** val cahce : coq_TARG_ID **)

val cache = "cache_targid"
  (* failwith "AXIOM TO BE REALIZED" *)

(** val retrieve_args : coq_Arg list **)
val retrieve_args = []

(** val check_ssl_sig_aspid : coq_ASP_ID **)
val check_ssl_sig_aspid = "check_ssl_sig_aspid"
