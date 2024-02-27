
type coq_ASP_Address = string (* AXIOM TO BE REALIZED *)

type coq_UUID = string (* AXIOM TO BE REALIZED *)

fun coq_Eq_Class_uuid x y = (x = y)

type coq_PublicKey = BString.bstring (* AXIOM TO BE REALIZED *)

fun coq_Eq_Class_public_key x y = (x = y)

type coq_PrivateKey = BString.bstring (* AXIOM TO BE REALIZED *)

fun coq_Eq_Class_private_key x y = (x = y)

(* type coq_PolicyT = bool (* AXIOM TO BE REALIZED *) 

val empty_PolicyT = True

type coq_PolicyT = bool  (* ((coq_ASP_ID, coq_Plc) prod) list *)

(** val empty_PolicyT : coq_PolicyT **)

val empty_PolicyT : coq_PolicyT = False (*[] *) (* [(Coq_pair "hi" "hey")] *)

*)

val empty_Manifest_Plc = "empty_Plc"

val empty_ASP_Address = "empty_ASP_ID"

val default_uuid = ""
