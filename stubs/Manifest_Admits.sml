
(* Used for locating something on the local filesystem *)

type coq_FS_Location = string

type coq_UUID = string (* AXIOM TO BE REALIZED *)

(** val coq_Serializable_UUUID : coq_UUID coq_Serializable **)

val coq_Serializable_UUUID : coq_UUID coq_Serializable =
  Build_Serializable (fn v => v) (fn v => Coq_resultC v)

fun coq_Eq_Class_uuid x y = (x = y)

type coq_PublicKey = BString.bstring (* AXIOM TO BE REALIZED *)

(** val coq_Serializable_PublicKey : coq_PublicKey coq_Serializable **)

val coq_Serializable_PublicKey : coq_PublicKey coq_Serializable =
  Build_Serializable (fn s => (BString.toString s)) (fn s => Coq_resultC (BString.fromString s))

fun coq_Eq_Class_public_key x y = (x = y)

val empty_Manifest_Plc = "empty_Plc"
