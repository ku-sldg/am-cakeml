
(* Used for locating something on the local filesystem *)

type coq_FS_Location = string

type coq_UUID = string (* AXIOM TO BE REALIZED *)

(** val coq_Stringifiable_UUUID : coq_UUID coq_Stringifiable **)

val coq_Stringifiable_UUUID : coq_UUID coq_Stringifiable =
  Build_Stringifiable (fn v => v) (fn v => Coq_resultC v)

type coq_PublicKey = BString.bstring (* AXIOM TO BE REALIZED *)

(** val coq_Stringifiable_PublicKey : coq_PublicKey coq_Stringifiable **)

val coq_Stringifiable_PublicKey : coq_PublicKey coq_Stringifiable =
  Build_Stringifiable (fn s => (BString.toString s)) (fn s => Coq_resultC (BString.fromString s))

