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
        (* FIX IP address info *)
        val blockchainResult =
            HealthRecord.getRecentRecord blockchainIpAddr blockchainIpPort
                jsonId
                healthRecordContract
                userAddress
                attestId
                targetId
        val theirPubkeyResult =
            Result.map HealthRecord.getSigningKey
                (Result.bind blockchainResult HealthRecord.fromJson)
        val theirPubkey = Result.getRes theirPubkeyResult (BString.nulls 451)
        val pub_len = BString.length theirPubkey
        val sig_len = BString.length signGood
        val msg_len = BString.length msg
        val outFileHandle = TextIO.openOut "src-pub.pem"
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
