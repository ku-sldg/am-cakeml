(* Depends on:  stubs/BS.sml, extracted/Term_Defs_Core.cml, 
     extracted/Term_Defs.cml, ... (TODO: crypto dependencies?) *)




(* TPM sig checking *)
(** val checkGG'' :
    coq_ASP_PARAMS -> coq_Plc -> coq_BS -> coq_RawEv -> coq_BS **)
fun checkGG'' ps p bs ls =
    let
        val msg = encode_RawEv ls
        val signGood = bs
        (* FIX ids *)
        val attestId = BString.unshow "deadbeef"
        val targetId = BString.unshow "facefeed"
        (* val _ = print "\n\n Please enter a character (after 5+ seconds) to query blockchain and proceed with appraisal:  "
        val delay = TextIO.input1 (TextIO.stdIn) *)
        fun ackermann m n =
            if m = 0
            then n + 1
            else
                if n = 0
                then ackermann (m - 1) 1
                else ackermann (m - 1) (ackermann m (n - 1))
        (* val _ = ackermann 4 1 *)
        val _ = ackermann 4 1
        (* FIX IP address info *)
        val blockchainResult =
            HealthRecord.getRecentRecord blockchainIpAddr blockchainIpPort
                jsonId
                healthRecordContract
                userAddress
                attestId
                targetId


	val bcErrString =
	    case blockchainResult of
	    	 Ok v => "bc success"
		 | Err e' => e'
	val _ = print ("\nBC read error:  \n" ^ bcErrString ^ "\n\n")

        val theirPubkeyResult =
            Result.map HealthRecord.getSigningKey
                (Result.bind blockchainResult HealthRecord.fromJson)
		
			     
	val theirPubkey_bc =
	    case theirPubkeyResult of
	    	   Ok v => let val _ =
		   (print ("\ntheirPubkey read error (JSON):  \n" ^ "success" ^ "\n\n")) in
		   v end 
		   | Err errString => let val _ =
		   print ("\ntheirPubkey read error (JSON):  \n" ^ errString ^ "\n\n") in
		   (BString.nulls 451) end		       




	(*
	val hrResult = HealthRecord.getSigningKey blockchainResult
	val hrErrString =
	    case hrResult of
	    	 Ok _ => "hr success"
		 | Err e' => e'
	val _ = print ("\HR.getSigningKey read error:  \n" ^ hrErrString ^ "\n\n")
	*)




(*

	val pubkeyfile_src = "../server/src-pub.pem"

	val signingKeyNull = String.concat
	    		     (Option.getOpt
                                      (TextIO.b_inputLinesFrom pubkeyfile_src)
                                      			       [])
	val _=(print ("\nRead Bytes from file '" ^ pubkeyfile_src ^ "':\n" ^ signingKeyNull ^ "\n\n"))
        val signingKeyNullSize = String.size signingKeyNull
        val signingKeyNullEnd = if signingKeyNullSize > 1
                                then signingKeyNullSize - 1
                                else signingKeyNullSize
        val signingKey =
                                  BString.fromString
                                    (String.substring
                                      signingKeyNull
                                      0
                                      signingKeyNullEnd)

*)
                                          


	val theirPubkey = (* signingKey *) theirPubkey_bc
	val _ = print ("\ntheirPubkey bytes: \n" ^ (BString.toString theirPubkey) ^ "\n\n")
        val pub_len = BString.length theirPubkey
        val sig_len = BString.length signGood
        val msg_len = BString.length msg
	val pubkeyfile_dest = "src-pub.pem" (* "src-pub-temp-client.pem" *)
        val outFileHandle = TextIO.openOut pubkeyfile_dest
	val _ = print ("\nOutputting pubkey FROM blockchain TO file: " ^ pubkeyfile_dest ^ "\n")
        val _ = TextIO.output outFileHandle (BString.toString theirPubkey)
        val checkGood = Crypto.checkTpmSig signGood msg
    in
        if checkGood
        then (print ("\n\nTPM Sig Check PASSED\n\n");
              passed_bs)
        else (print ("\n\nTPM Sig Check FAILED\n\n");
              failed_bs)
    end




(* SSL sig checking *)
(** val checkGG''' :
    coq_ASP_PARAMS -> coq_Plc -> coq_BS -> coq_RawEv -> coq_BS **)
fun checkGG''' ps p bs ls =
    let
        val msg = encode_RawEv ls
        val signGood_loc = bs   

	val theirPubkey = pub (* signingKey *) (* theirPubkey_bc *)
	val _ = print ("\ntheirPubkey bytes: \n" ^ (BString.toString theirPubkey) ^ "\n\n")
	val _ = print ("\nmsg: " ^ (BString.show msg) ^ "\n\n")
	val _ = print ("\nsignGood: " ^ (BString.show signGood_loc) ^ "\n\n")
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
        then (print ("\n\nSSL Sig Check PASSED\n\n");
              passed_bs)
        else (print ("\n\nSSL Sig Check FAILED\n\n");
              failed_bs)
    end

(** val checkGG' :
    coq_ASP_PARAMS -> coq_Plc -> coq_BS -> coq_RawEv -> coq_BS **)
fun checkGG' ps p bs ls =
    case ps of
        Coq_asp_paramsC aspid args tpl tid =>
        case (aspid = tpm_sig_aspid) of
            True => checkGG'' ps p bs ls
                              
          | _ => case (aspid = ssl_sig_aspid) of
                     True => checkGG''' ps p bs ls

                   | _ => case (aspid = kim_meas_aspid) of
                              True => appraise_kim_meas_asp_stub ps p bs ls
                                                 
                            | _ => let val _ = (print "Checking non-signature ASP ... \n\n") in
                                       BString.fromString "check(data.txt)" (* TODO: check data val here? *)
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
