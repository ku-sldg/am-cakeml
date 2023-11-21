
(* TODO: dependencies *)
structure ManGenConfig = struct


    val auth_phrase = ssl_sig_parameterized default_place
    fun auth_phrase_list p = [(Coq_pair auth_phrase p)]

    val kim_phrase = Coq_att coq_P1 (kim_meas dest_plc kim_meas_targid) 
    val kim_phrases =   [(Coq_pair kim_phrase coq_P0)] @ (auth_phrase_list coq_P0)

    val kim_enc_phrase = Coq_att coq_P1  (Coq_lseq (kim_meas dest_plc kim_meas_targid) (Coq_asp (ENC coq_P0)))
    val kim_enc_phrases =   [(Coq_pair kim_enc_phrase coq_P0)] @ (auth_phrase_list coq_P0)
    val cert_phrases =  [(Coq_pair cert_style coq_P0)] @ (auth_phrase_list coq_P0)
    val cache_phrases = [(Coq_pair cert_cache_p0 coq_P0), (Coq_pair cert_cache_p1 coq_P1)] @ (auth_phrase_list coq_P0) @ (auth_phrase_list coq_P1)
    val parmut_phrases' = [(* (Coq_pair par_mut_p0 coq_P3) ,*) (Coq_pair par_mut_p0 coq_P0), (Coq_pair par_mut_p1 coq_P1) (* , (Coq_pair par_mut_p1 coq_P4) *) ] 
    val parmut_phrases_auth = (auth_phrase_list coq_P3) @ (auth_phrase_list coq_P0) @ (auth_phrase_list coq_P1) (* @ (auth_phrase_list coq_P4) *)
    val parmut_phrases = parmut_phrases' @ parmut_phrases_auth
    val layered_bg_phrases = [(Coq_pair layered_bg_strong coq_P0)] @ (auth_phrase_list coq_P0)
    val cm_phrase = Coq_lseq (cm_meas coq_P0 cm_targid) (Coq_asp SIG)
        (* Coq_lseq (cm_meas coq_P0 cm_targid) (ssl_sig_parameterized coq_P0) *)
    val cm_phrases = [(Coq_pair cm_phrase coq_P0)] (* @ (auth_phrase_list coq_P0) *)

    (* val main_phrase = example_phrase (* cert_style *) *)
    val demo_phrases = [(Coq_pair example_phrase coq_P0)] @ (auth_phrase_list coq_P0)




    val appraiser_evidence_kim = eval kim_phrase coq_P0 (Coq_nn O)
    val appraiser_evidence_kim_enc = eval kim_enc_phrase coq_P0 (Coq_nn O)
    val appraiser_evidence_cm = eval cm_phrase coq_P0 (Coq_nn O)
    val appraiser_evidence_cert = eval cert_style coq_P0 (Coq_nn O)
    val appraiser_evidence_cache_p0 = eval cert_cache_p0 coq_P0 (Coq_nn O)
    val appraiser_evidence_cache_p1 = eval cert_cache_p1 coq_P1 (Coq_nn O)
    val appraiser_evidence_parmut_p0 = eval par_mut_p0 coq_P0 (Coq_nn O)
    val appraiser_evidence_parmut_p1 = eval par_mut_p1 coq_P1 (Coq_nn O)
    val appraiser_evidence_layeredbg = eval layered_bg_strong coq_P0 (Coq_nn O)

    val ets_kim = [(Coq_pair appraiser_evidence_kim coq_P0),
                    (Coq_pair appraiser_evidence_kim coq_P3)]
    val ets_kim_enc = [(Coq_pair appraiser_evidence_kim_enc coq_P0),
                    (Coq_pair appraiser_evidence_kim_enc coq_P3)]
    val ets_cm = [(Coq_pair appraiser_evidence_cm coq_P0), 
                    (Coq_pair appraiser_evidence_cm coq_P3)]
    val ets_cert = [(Coq_pair appraiser_evidence_cert coq_P0),
                    (Coq_pair appraiser_evidence_cert coq_P3)]
    val ets_cache = [(Coq_pair appraiser_evidence_cache_p0 coq_P0),
                        (Coq_pair appraiser_evidence_cache_p1 coq_P1),
                        (Coq_pair appraiser_evidence_cache_p0 coq_P3),
                        (Coq_pair appraiser_evidence_cache_p1 coq_P3)]
    val ets_parmut = [(Coq_pair appraiser_evidence_parmut_p0 coq_P0),
                        (Coq_pair appraiser_evidence_parmut_p1 coq_P1),
                        (Coq_pair appraiser_evidence_parmut_p0 coq_P3),
                        (Coq_pair appraiser_evidence_parmut_p1 coq_P3)]
    val ets_layeredbg = [(Coq_pair appraiser_evidence_layeredbg coq_P0),
                            (Coq_pair appraiser_evidence_layeredbg coq_P3)]

    val appraiser_evidence_demo_phrase = eval example_phrase coq_P0 (Coq_nn O)

    val appraiser_evidence_demo_phrase_p2 = eval example_phrase coq_P2 (Coq_nn O)

    val appraiser_evidence_demo_phrase' = eval example_phrase_p2_appraise coq_P0 (Coq_nn O)

    val ets_example_phrase = [(Coq_pair appraiser_evidence_demo_phrase coq_P0), 
                                (Coq_pair appraiser_evidence_demo_phrase coq_P3)]

                                
end
(*  End structure ManGenConfig *)
(*  Whitespace for cmake compilation purposes... *)