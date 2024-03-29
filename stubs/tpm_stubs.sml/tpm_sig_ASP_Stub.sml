(* Stub code for ASP with asp ID:  tpm_sig_aspid *)

(* tpm_sig_asp_stub :: coq_ASP_PARAMS -> coq_RawEv -> coq_BS *)
fun tpm_sig_asp_stub ps e =
    case ps of Coq_asp_paramsC aspid args tpl tid =>
               let val _ = () in
                   print ("Matched aspid:  " ^ aspid ^ "\n");
                   let val data = encode_RawEv e
                       val sigRes = Crypto.tpmSign data in
                       Coq_resultC (sigRes)
                   end
               end
