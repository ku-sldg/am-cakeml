(* Depends on:  stubs/BS.sml, extracted/Term_Defs_Core.cml, 
     extracted/Term_Defs.cml, ... (TODO: crypto dependencies?) *)

(** val decrypt_bs_to_rawev' : coq_BS -> coq_ASP_PARAMS -> coq_RawEv **)

fun decrypt_bs_to_rawev' bs ps =
    [BString.fromString "SigVal", BString.fromString "DataVal"]


    (* [BString.fromString ("decrypted ( " ^
                                                     (BString.toString bs) ^
                                                     " )"),
                                  default_bs (* ,
                                  default_bs ,
                                  default_bs,
                                  default_bs,
                                  default_bs *)]
     *)
    
  (* failwith "AXIOM TO BE REALIZED" *)

(** val checkGG' :
    coq_ASP_PARAMS -> coq_Plc -> coq_BS -> coq_RawEv -> coq_BS **)

fun checkGG' ps p bs ls = BString.fromString ("{EXTD_CHECK ( " ^
                                              (BString.toString bs) ^ ", " ^
                                              (rawEvToString ls) ^
                                              " ) }")

                              (* default_bs *)
  (* failwith "AXIOM TO BE REALIZED" *)
