(* Stub code for ASP with asp ID:  ssl_sig_aspid *)

fun get_prikey ini ps =
    get_ini_hexbytes ini "privateKey"

(* ssl_sig_asp_stub :: coq_ASP_PARAMS -> coq_RawEv -> coq_BS *)
fun ssl_sig_asp_stub ps e =
    case ps of Coq_asp_paramsC aspid args tpl tid =>
               let val _ = () in
                   print ("Matched aspid:  " ^ aspid ^ "\n");
                   let val data = encode_RawEv e
                       val ini = get_ini ()
		       val myPriKey = get_prikey ini ps
                       val sigRes = Crypto.signMsg myPriKey data in
                       sigRes
                   end
               end
