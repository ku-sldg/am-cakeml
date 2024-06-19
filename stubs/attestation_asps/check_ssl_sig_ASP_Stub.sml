(* Stub code for ASP with asp ID:  check_ssl_sig_aspid *)

(* check_ssl_sig_asp_stub :: coq_ASP_PARAMS -> coq_RawEv -> coq_BS *)
fun check_ssl_sig_asp_stub ps e =
    case ps of Coq_asp_paramsC aspid args tpl tid =>
               let val _ = (print ("Matched aspid:  " ^ aspid ^ "\n");
                            print ("Performing ASP " ^ aspid ^ "\n\n")) 

                    val my_amlib = ManifestUtils.get_local_amLib ()

                    val appServerAddr = 
                      case my_amlib of  
                            Build_AM_Library addr _ _ _ _ => addr

                    val appTerm = (Coq_asp (ASPC ALL (EXTD (S O)) (Coq_asp_paramsC ssl_sig_aspid []
                                   coq_P0 sys)))



                    val appresult = case (run_appraisal_client appTerm coq_P0 (Coq_nn O) e appServerAddr) of
                                        Coq_errC e => raise (Exception e)
                                      | Coq_resultC v => v

                     val _ = print ("\n\nAppraised Evidence structure:  \n" ^ (coq_AppResultC_to_stringT appresult) ^ "\n\n") 
                     
                     in
                        Coq_resultC (passed_bs)
               end
                    
(*

fun appraise_ssl_sig (ps : coq_ASP_PARAMS) (p : coq_Plc) (bs : coq_BS) (ls : coq_RawEv)  =
    let
        val msg = encode_RawEv ls
        val signGood_loc = bs

        val _ = print ("Looking up Pubkey for place " ^ (plToString p) ^ "\n"  (*^ (BString.show pubkey) ^  "\n\n" *))

        val res_pubkey = (ManifestUtils.get_PubKeyCallback() p) (* ): BString.bstring *)
        val pubkey = 
            case res_pubkey of 
                Coq_errC e => BString.empty(* raise Excn ("get_PubKeyCallback error")  *)
            | Coq_resultC v => v

        (* val _ = print "\n\nPast looking up pubkey\n\n" *)
        val pub_len = BString.length pubkey
        val sig_len = BString.length signGood_loc
        val msg_len = BString.length msg

                                     (*
	val pubkeyfile_dest = "src-pub.pem" (* "src-pub-temp-client.pem" *)
        val outFileHandle = TextIO.openOut pubkeyfile_dest
	val _ = print ("\nOutputting pubkey FROM blockchain TO file: " ^ pubkeyfile_dest ^ "\n")
        val _ = TextIO.output outFileHandle (BString.toString theirPubkey)
                                     *)
                                     
        val checkGood = Crypto.sigCheck pubkey signGood_loc msg (* Crypto.checkTpmSig signGood msg *)
    in
        if checkGood
        then (print ("\nSSL Sig Check PASSED\n\n");
              (Coq_resultC passed_bs))
        else (print ("\nSSL Sig Check FAILED\n\n");
              (Coq_resultC failed_bs))
    end
*)