(** val sig_params : coq_ASP_PARAMS **)

val sig_aspid = "sigid"
(*
val sig_params = Coq_asp_paramsC sig_aspid [] "0" "sigtargid"
*)

val sig_aspargs = []

val sig_targid = "sigtargid"
val sig_targplc = "sigP"

val sig_params = Coq_asp_paramsC sig_aspid sig_aspargs sig_targplc sig_targid

(** val hsh_params : coq_ASP_PARAMS **)

val hsh_aspid = "hshid"

val hsh_aspargs = []

val hsh_targid = "hshtargid"
val hsh_targplc = "hshP"

val hsh_params = Coq_asp_paramsC hsh_aspid hsh_aspargs hsh_targplc hsh_targid

(* val hsh_params = Coq_asp_paramsC "hshid" [] "0" "hshtargid" *)

(** val enc_params :: coq_Plc -> coq_ASP_PARAMS **)

val enc_aspid = "encid"

val enc_aspargs = []

val enc_targid = "enctargid"
val enc_targplc = "encP"

fun enc_params q = Coq_asp_paramsC enc_aspid enc_aspargs q enc_targid

(* fun enc_params q = Coq_asp_paramsC "encid" [] q "enctargid" *)