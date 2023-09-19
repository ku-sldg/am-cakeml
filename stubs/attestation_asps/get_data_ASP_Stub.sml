(* Stub code for ASP with asp ID:  get_data_aspid *)

(* get_data_asp_stub :: coq_ASP_PARAMS -> coq_RawEv -> coq_BS *)
fun get_data_asp_stub ps e =
    case ps of Coq_asp_paramsC aspid args tpl tid =>
               let val _ = () in
                   print ("Matched aspid:  " ^ aspid ^ "\n");
                   let val dataRes = Crypto.getData () in
                       Coq_resultC (dataRes)
                   end
               end
