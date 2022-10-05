(* Depends on:  stubs/BS.sml, extracted/Term_Defs_Core.cml, 
     extracted/Term_Defs.cml, ... (TODO: crypto dependencies?) *)


fun strToJson str = Result.okValOf (Json.parse str)
fun jsonToStr js  = Json.stringify js



(* 
   fun encode_RawEv : coq_RawEv -> coq_BS 

   This function takes a coq_RawEv value (list of coq_BS values) and encodes it as a single
   coq_BS value (to, for instance prepare it for cryptographic transformation).  To encode, 
   we first take the raw evidence sequence to an Array of Json strings (am/CommTypes.bsListToJsonList).
   Next, we "stringify" that Array (am/ServerAM.jsonToStr) to a single string.  Finally, we lift
   that string into a bstring (BString.fromString).
*)
fun encode_RawEv ls = BString.fromString (jsonToStr (bsListToJsonList ls))

(* 
   fun decode_RawEv : coq_BS -> coq_RawEv
   This should be the inverse of encode_RawEv.
*)
fun decode_RawEv bsval = jsonBsListToList (strToJson (BString.toString bsval))


(** val decrypt_bs_to_rawev' : coq_BS -> coq_ASP_PARAMS -> coq_RawEv **)

fun decrypt_bs_to_rawev' bs ps =
    let val recoveredtext = Crypto.decryptOneShot priv2 pub1 bs
        val bs_recovered = BString.fromString recoveredtext
        val res = decode_RawEv bs_recovered
        val _ = print ("\nDecryption Succeeded: \n" ^ (rawEvToString res) ^ "\n" ) in
        res
    end


(** val checkGG'' :
    coq_ASP_PARAMS -> coq_Plc -> coq_BS -> coq_RawEv -> coq_BS **)
fun checkGG'' ps p bs ls =
    let
        val msg = encode_RawEv ls
        val signGood = bs
        (* FIX ids *)
        val attestId = BString.unshow "deadbeef"
        val targetId = BString.unshow "facefeed"

	val _ = print "\n\n Please enter a character (after 5+ seconds) to query blockchain and proceed with appraisal:  "
	val delay = TextIO.input1 (TextIO.stdIn)




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
        val signingKeyNullEnd = if signingKeyNullSize > 2
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
        then (print ("\n\nSig Check PASSED\n\n");
              passed_bs)
        else (print ("\n\nSig Check FAILED\n\n");
              failed_bs)
    end

(** val checkGG' :
    coq_ASP_PARAMS -> coq_Plc -> coq_BS -> coq_RawEv -> coq_BS **)
fun checkGG' ps p bs ls =
    case ps of
        Coq_asp_paramsC aspid args tpl tid =>
        case (aspid = tpm_sig_aspid) of
            True => checkGG'' ps p bs ls
          | _ =>
            let val _ = (print "Checking non-signature ASP ... \n\n") in
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
