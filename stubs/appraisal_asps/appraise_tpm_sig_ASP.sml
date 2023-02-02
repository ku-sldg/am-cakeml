(* Depends on: (TODO: dependencies?) *)


(* fun appraise_tpm_sig : 
   coq_ASP_PARAMS -> coq_Plc -> coq_BS -> coq_RawEv -> coq_BS 

   Performs TPM signature checking *)
fun appraise_tpm_sig ps p bs ls =
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
                  (*             
	val _ = print ("\nBC read error:  \n" ^ bcErrString ^ "\n\n")
                  *)
                               

        val theirPubkeyResult =
            Result.map HealthRecord.getSigningKey
                (Result.bind blockchainResult HealthRecord.fromJson)
		
			     
	val theirPubkey_bc =
	    case theirPubkeyResult of
	    	Ok v =>  let val _ = (print "\n\nPulled Server public key from Blockchain...\n\n")
                         in v
                         end

                                 (*
		   (print ("\ntheirPubkey read error (JSON):  \n" ^ "success" ^ "\n\n")) in *)
		   
		   | Err errString => (BString.nulls 451) (* let val _ =
		   print ("\ntheirPubkey read error (JSON):  \n" ^ errString ^ "\n\n") in
		   (BString.nulls 451) end *)		       




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
                              (* 
	val _ = print ("\ntheirPubkey bytes: \n" ^ (BString.toString theirPubkey) ^ "\n\n") *)
        val pub_len = BString.length theirPubkey
        val sig_len = BString.length signGood
        val msg_len = BString.length msg
	val pubkeyfile_dest = "src-pub.pem" (* "src-pub-temp-client.pem" *)
        val outFileHandle = TextIO.openOut pubkeyfile_dest
                                           (* 
	val _ = print ("\nOutputting pubkey FROM blockchain TO file: " ^ pubkeyfile_dest ^ "\n") *)
        val _ = TextIO.output outFileHandle (BString.toString theirPubkey)
        val checkGood = Crypto.checkTpmSig signGood msg
    in
        if checkGood
        then (print ("\n\nTPM Sig Check PASSED\n\n");
              passed_bs)
        else (print ("\n\nTPM Sig Check FAILED\n\n");
              failed_bs)
    end
