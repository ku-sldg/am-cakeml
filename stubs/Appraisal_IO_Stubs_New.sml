(* Depends on:  stubs/BS.sml, extracted/Term_Defs_Core.cml, 
     extracted/Term_Defs.cml, ... (TODO: crypto dependencies?) *)

(** val checkGG' :
    coq_ASP_PARAMS -> coq_Plc -> coq_BS -> coq_RawEv -> coq_BS **)
fun checkGG' ps p bs ls =
    case ps of
        Coq_asp_paramsC aspid args tpl tid =>
        case (aspid = tpm_sig_aspid) of
            True => appraise_tpm_sig ps p bs ls
                              
          | _ => case (aspid = ssl_sig_aspid) of
                     True => appraise_ssl_sig ps p bs ls

                   | _ => case (aspid = kim_meas_aspid) of
                              True => appraise_kim_meas_asp_stub ps p bs ls
                                                 
                            | _ => let val _ = () (* (print ("\n\nChecking ASP with ID: " ^ aspid ^ "\n\n")) *) in
                                       BString.fromString ("check(" ^ aspid ^ ")") (* TODO: check data val here? *)
                                   end
                                       
                                       
(** fun checkNonce' : coq_BS -> coq_BS -> coq_BS **)
fun checkNonce' nonceGolden nonceCandidate =
    if (nonceGolden = nonceCandidate)
    then
        let val _ = print "Nonce Check PASSED\n\n" in
            passed_bs
        end
    else
        let val _ = print "Nonce Check FAILED\n\n" in
            failed_bs
        end
