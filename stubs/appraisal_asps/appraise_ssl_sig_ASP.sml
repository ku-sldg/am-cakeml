(* Depends on: (TODO: dependencies?) *)

(* fun appraise_ssl_sig : 
   coq_ASP_PARAMS -> coq_Plc -> coq_BS -> coq_RawEv -> coq_BS 

   Performs openssl signature checking *)
fun appraise_ssl_sig ps p bs ls =
    let
        val msg = encode_RawEv ls
        val signGood_loc = bs   

        val ini = get_ini ()
	val theirPubkey = get_ini_pubkey ini p
        (*pub*) (* signingKey *) (* theirPubkey_bc *)
                              
                              (*
	val _ = print ("\ntheirPubkey bytes: \n" ^ (BString.toString theirPubkey) ^ "\n\n")
	val _ = print ("\nmsg: " ^ (BString.show msg) ^ "\n\n")
	val _ = print ("\nsignGood: " ^ (BString.show signGood_loc) ^ "\n\n")
                              *)
                              
        val pub_len = BString.length theirPubkey
        val sig_len = BString.length signGood_loc
        val msg_len = BString.length msg

                                     (*
	val pubkeyfile_dest = "src-pub.pem" (* "src-pub-temp-client.pem" *)
        val outFileHandle = TextIO.openOut pubkeyfile_dest
	val _ = print ("\nOutputting pubkey FROM blockchain TO file: " ^ pubkeyfile_dest ^ "\n")
        val _ = TextIO.output outFileHandle (BString.toString theirPubkey)
                                     *)
                                     
        val checkGood = Crypto.sigCheck theirPubkey signGood_loc msg (* Crypto.checkTpmSig signGood msg *)
    in
        if checkGood
        then (print ("\nSSL Sig Check PASSED\n\n");
              passed_bs)
        else (print ("\nSSL Sig Check FAILED\n\n");
              failed_bs)
    end
