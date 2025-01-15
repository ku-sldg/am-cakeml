(** val sig_params : coq_ASP_PARAMS **)

val sig_aspid = "sig_id"
(*
val sig_params = Coq_asp_paramsC sig_aspid [] "0" "sigtargid"
*)

val sig_aspargs = (JSON_Object [])

val sig_targid = "sigtargid"
val sig_targplc = "sigP"

val sig_params = Coq_asp_paramsC sig_aspid sig_aspargs sig_targplc sig_targid

(** val check_nonce_aspid : coq_ASP_ID **)
val check_nonce_aspid : coq_ASP_ID = "check_nonce_id"

(** val check_nonce_aspargs : coq_ASP_ARGS **)
val check_nonce_aspargs : coq_ASP_ARGS = (JSON_Object [])

(** val check_nonce_targid : coq_ASP_ID **)
val check_nonce_targid : coq_ASP_ID = "check_nonce_targid"

(** val check_nonce_targplc : coq_Plc **)
val check_nonce_targplc : coq_Plc = "check_nonce_targPlc"

(** val check_nonce_params : coq_ASP_PARAMS **)
val check_nonce_params : coq_ASP_PARAMS =
  Coq_asp_paramsC check_nonce_aspid check_nonce_aspargs check_nonce_targplc
    check_nonce_targid

(** val hsh_params : coq_ASP_PARAMS **)

val hsh_aspid = "hsh_id"

val hsh_aspargs = (JSON_Object [])

val hsh_targid = "hshtargid"
val hsh_targplc = "hshP"

val hsh_params = Coq_asp_paramsC hsh_aspid hsh_aspargs hsh_targplc hsh_targid

(* val hsh_params = Coq_asp_paramsC "hshid" [] "0" "hshtargid" *)

(** val enc_params :: coq_Plc -> coq_ASP_PARAMS **)

val enc_aspid = "enc_id"

val enc_aspargs = (JSON_Object [])

val enc_targid = "enctargid"
val enc_targplc = "encP"

fun enc_params q = Coq_asp_paramsC enc_aspid enc_aspargs q enc_targid

(* fun enc_params q = Coq_asp_paramsC "encid" [] q "enctargid" *)


(* TODO: move this to different stubs file?  
    Or eventually extract entirely from spec... *)
fun term_discloses_aspid_to_remote_enc_bool t p e i r = True