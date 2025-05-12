
(** val append_aspid_to_errstr : string -> coq_ID_Type -> string **)

fun append_aspid_to_errstr (errStr:string) (i:coq_ID_Type) = String.concat [errStr, i]