(* Stub code for ASP with asp ID:  ssl_enc_aspid *)

(* ssl_enc_asp_stub :: coq_ASP_PARAMS -> coq_RawEv -> coq_BS *)
fun ssl_enc_asp_stub ps e =
    case ps of Coq_asp_paramsC aspid args tpl tid =>
               let val _ = () in
                   print ("Matched aspid:  " ^ aspid ^ "\n");
                   let val plaintext =
                           BString.toString (encode_RawEv e) 
                       val ciphertext =
                           Crypto.encryptOneShot
                               priv1 pub2 plaintext in
                       ciphertext
                   end
               end
