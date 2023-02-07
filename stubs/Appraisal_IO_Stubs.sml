(* Depends on:  stubs/BS.sml, extracted/Term_Defs_Core.cml, 
     extracted/Term_Defs.cml, ... (TODO: crypto dependencies?) *)

(* CLEANUP:
Change CMake structure so that 
'appraisal_asps' and 'attestation_asps'
build their own folders respectively
 *)




(* 
   fun decode_RawEv : coq_BS -> coq_RawEv
   This should be the inverse of encode_RawEv.
*)
fun decode_RawEv bsval = jsonBsListToList (strToJson (BString.toString bsval))


(** val decrypt_bs_to_rawev : coq_BS -> coq_ASP_PARAMS -> coq_RawEv **)

fun decrypt_bs_to_rawev bs ps (* priv pub *) =
    let val recoveredtext = Crypto.decryptOneShot (* priv pub *) priv2 pub1 bs
        val bs_recovered = BString.fromString recoveredtext
        val res = decode_RawEv bs_recovered
        val _ = print ("\nDecryption Succeeded: \n" ^ (rawEvToString res) ^ "\n" ) in
        res
    end


(** val chec_asp_EXTD :
    coq_ASP_PARAMS -> coq_Plc -> coq_BS -> coq_RawEv -> coq_BS **)
fun check_asp_EXTD ps p bs ls =
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
                                       
                                       
(** fun checkNonce : coq_BS -> coq_BS -> coq_BS **)
fun checkNonce nonceGolden nonceCandidate =
    if (nonceGolden = nonceCandidate)
    then
        let val _ = print "Nonce Check PASSED\n\n" in
            passed_bs
        end
    else
        let val _ = print "Nonce Check FAILED\n\n" in
            failed_bs
        end


(** val gen_nonce_bits : coq_BS **)

val gen_nonce_bits = (BString.fromString "anonce") (* TODO: real nonce gen *)
  (* failwith "AXIOM TO BE REALIZED" *)
