(* Stub code for ASP with asp ID:  ssl_sig_aspid *)

(* ssl_sig_asp_stub :: coq_ASP_PARAMS -> coq_RawEv -> coq_BS *)
fun ssl_sig_asp_stub ps e =
    case ps of Coq_asp_paramsC aspid args tpl tid =>
               let val _ = () in
                   print ("Matched aspid:  " ^ aspid ^ "\n");
                   let val data = encode_RawEv e
                       val sigRes = Crypto.signMsg privGood data (* Crypto.tpmSign data *) in
                       sigRes
                   end
               end
