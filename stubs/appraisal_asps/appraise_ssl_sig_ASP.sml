(* Depends on: (TODO: dependencies?) *)

(* fun appraise_ssl_sig : 
   coq_ASP_PARAMS -> coq_Plc -> coq_BS -> coq_RawEv -> coq_BS 

   Performs openssl signature checking *)
fun appraise_ssl_sig (ps : coq_ASP_PARAMS) (p : coq_Plc) (bs : coq_BS) (ls : coq_RawEv)  =
    let
        val msg = BString.fromCString (coq_RawEv_to_stringT ls)
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
