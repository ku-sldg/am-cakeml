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

val hsh_params = Coq_asp_paramsC "hshid" [] "0" "hshtargid"

(** val enc_params :: coq_Plc -> coq_ASP_PARAMS **)
fun enc_params q = Coq_asp_paramsC "encid" [] q "enctargid"