(* Appraisal Stub code for ASP with asp ID:  cm_aspid *)

(* appraise_cm_asp_stub :: coq_ASP_PARAMS -> coq_Plc -> coq_BS -> coq_RawEv -> coq_BS *)
fun appraise_cm_asp_stub ps p bs ls =
    case ps of Coq_asp_paramsC aspid args tpl tid =>
                let 
                    val _ = print ("Appraising ASP with ID:  " ^ aspid ^ "\n");
                    (*
                    val result = kernelAppraisal 0 bs
                    *)
                in 
                    (Coq_resultC passed_bs)
                end

