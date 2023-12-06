(* Appraisal Stub code for ASP with asp ID:  check_ssl_sig_aspid *)

(* appraise_check_ssl_sig_asp_stub :: coq_ASP_PARAMS -> coq_Plc -> coq_BS -> coq_RawEv -> coq_BS *)
fun appraise_check_ssl_sig_asp_stub ps p bs ls =
    case ps of Coq_asp_paramsC aspid args tpl tid =>
        let val _ = print ("Appraising ASP with ID: \n" ^ aspid ^ "...\n\n") 
        (*
            val et = eval example_phrase_p2_appraise coq_P0 (Coq_nn O)
            val appres = gen_appraise_AM et ls
        *)
                in 
                Coq_resultC passed_bs
        end
        

