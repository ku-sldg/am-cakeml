(* Stub code for ASP with asp ID:  cache_id *)

(* cache_asp_stub :: coq_ASP_PARAMS -> coq_RawEv -> coq_BS *)
fun cache_asp_stub ps e =
    case ps of Coq_asp_paramsC aspid args tpl tid =>
               let val _ = () in
                   print ("Matched aspid:  " ^ aspid ^ "\n");
                   print ("Performing ASP " ^ aspid ^ "\n\n"); 
                   (Coq_resultC passed_bs)
               end
