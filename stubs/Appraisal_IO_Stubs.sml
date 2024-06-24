(* Depends on:  stubs/BS.sml, extracted/Term_Defs_Core.cml, 
     extracted/Term_Defs.cml, ... (TODO: crypto dependencies?) *)

(* TODO: I hate this but need compilation *)
val priv2 = BString.unshow "308202260201003082011706092a864886f70d010301308201080282010100c4bdfbb69055be49894bffad8f70c4dc6bb37672f925b84ef1d42f8488cefc207c9f082b6436431649917f77e833ccb34d2c886fcb3eb7cbd0b4139f5bc4d353c826400ca4b470ace06a28a7fa66240e819aea538ba0468eeb4d72bdd63b6929d377ab48a50477c4297a151a88631d8bf21851eb8b16d1ace2f3a33aee09fa54eb6f7cacca2e04169e3018eafbff583db0ded4222c438b463cb5fdaf41b842ebccc1a41b2603fc958c48f63628b5040fddcdb330c64a39f1f162501edaa080b5371798c1e334163076faf1e9ea8cdd82588d9635f84a302998ea9c38e236dd374e7bb25f793a937e4e0dc4b4c5777309a0a1ea837951cab0b120e649a496dabf02010204820104028201005b0638014e949bbbf8aed699e4ba9690d4d53c1de27596d215d07f086ea2475f8d67d1dee7ad5192eb79a58ff7cf1cbce571834654e13de2e315da720b81c13c4daf11740df61960e02103d7181a9de97b966ad9e5d5b85df890885af4432ba483face41e7a9d3278b407cddb07184e9a8af1bd49faece0d6586e1810911aea6543a134df2113cbe086bfa64ffe7e245becee4a1f1c144a5d7f8d492535b20bcb7d1da28003c1f49c188b67b50bd0bc8942709d4de5a898137f9a9b3eba8ff65091db219897097287768976f46e5ae55f43bedbfff12c438e09a7e2704f990a8647a0fb76283578c48a6c3f362f8f931821849ae7274c5c2629de8fec957e296"

(** val gen_nonce_bits : coq_BS **)

val gen_nonce_bits = (BString.fromString "anonce") (* TODO: real nonce gen *)


(** val decrypt_bs_to_rawev_prim :
    coq_BS -> coq_ASP_PARAMS -> coq_PublicKey -> (coq_RawEv,
    coq_DispatcherErrors) coq_ResultT **)
fun decrypt_bs_to_rawev_prim bs params pubkey = 
    let val recoveredtext : string = Crypto.decryptOneShot priv2 pubkey (*pub1*) (* priv1 pubkey *) bs (*priv2 pub1 bs *)
        val res = case stringT_to_RawEv recoveredtext of
                      Coq_resultC r => r
                    | Coq_errC e => raise Exception e
        val _ = print ("\nDecryption Succeeded: \n" ^ (coq_RawEv_to_stringT res) ^ "\n" ) in
        (Coq_resultC res)
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
