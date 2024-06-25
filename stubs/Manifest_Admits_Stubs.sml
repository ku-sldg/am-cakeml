
(* Used for locating something on the local filesystem *)
(** val coq_JSON_Local_ASP : string **)

val coq_JSON_Local_ASP = "LOCAL_ASP"

(** val coq_JSON_Remote_ASP : string **)

val coq_JSON_Remote_ASP = "REMOTE_ASP"

type coq_FS_Location = string

(** val jsonifiable_FS_Location : coq_FS_Location coq_Jsonifiable **)

val jsonifiable_FS_Location =
  Build_Jsonifiable (fn v => JSON_String v) (fn v =>
    case v of
      JSON_String s => Coq_resultC s
    | _ => Coq_errC "Fail to get jsonifiable_FS_Location")

type coq_UUID = string (* AXIOM TO BE REALIZED *)

(** val string_to_UUUID :
    string -> (coq_UUID, string) coq_ResultT **)

val string_to_UUUID = (fn v => Coq_resultC v)

(** val jsonifiable_uuid : coq_UUID coq_Jsonifiable **)

val jsonifiable_uuid =
  Build_Jsonifiable (fn v => JSON_String v) (fn v =>
    case v of
      JSON_String s => Coq_resultC s
    | _ => Coq_errC "Fail to get jsonifiable_uuid")


fun coq_Eq_Class_uuid x y = (x = y)

type coq_PublicKey = BString.bstring (* AXIOM TO BE REALIZED *)

(** val jsonifiable_public_key : coq_PublicKey coq_Jsonifiable **)

val jsonifiable_public_key =
  Build_Jsonifiable (fn v => JSON_String (BString.show v)) (fn v =>
    case v of
      JSON_String s => Coq_resultC (BString.unshow s)
    | _ => Coq_errC "Fail to get jsonifiable_public_key")

fun coq_Eq_Class_public_key x y = (x = y)

val empty_Manifest_Plc = "empty_Plc"
