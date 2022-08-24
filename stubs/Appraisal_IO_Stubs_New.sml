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
        val res = decode_RawEv bs_recovered in
        res
    end

    (*
    [BString.fromString "SigVal", BString.fromString "DataVal"]
    *)
    


    (* [BString.fromString ("decrypted ( " ^
                                                     (BString.toString bs) ^
                                                     " )"),
                                  default_bs (* ,
                                  default_bs ,
                                  default_bs,
                                  default_bs,
                                  default_bs *)]
     *)
    
  (* failwith "AXIOM TO BE REALIZED" *)



(** val checkGG'' :
    coq_ASP_PARAMS -> coq_Plc -> coq_BS -> coq_RawEv -> coq_BS **)

fun checkGG'' ps p bs ls =
    let val msg = encode_RawEv ls
        val signGood = bs
        val pub_len = BString.length pub
        val sig_len = BString.length signGood
        val msg_len = BString.length msg
  
        val _ = print ("pub_len: \n" ^ (Int.toString pub_len) ^ "\n")
        val _ = print ("sig_len: \n" ^ (Int.toString sig_len) ^ "\n")
        val _ = print ("msg_len: \n" ^ (Int.toString msg_len) ^ "\n")

        val checkGood = Crypto.sigCheck pub signGood msg in
        if checkGood
        then (print ("\n\nSig Check PASSED\n\n");
              BString.fromString "True")
        else (print ("\n\nSig Check FAILED\n\n");
              BString.fromString "False")
    end
        

    (*
    BString.fromString ("{EXTD_CHECK ( " ^
                        (BString.toString bs) ^ ", " ^
                        (rawEvToString ls) ^
                        " ) }")
    *)
    

                              (* default_bs *)
  (* failwith "AXIOM TO BE REALIZED" *)

(** val checkGG' :
    coq_ASP_PARAMS -> coq_Plc -> coq_BS -> coq_RawEv -> coq_BS **)
fun checkGG' ps p bs ls =
    case ps of
        Coq_asp_paramsC aspid args tpl tid =>
        case (aspid = tpm_sig_aspid) of
            True => checkGG'' ps p bs ls
          | _ =>
            let val _ = (print "Checking non-signature EXTD ASP ... \n\n") in
                BString.fromString "data.txt check" (* TODO: check data val here? *)
            end
                     
        

