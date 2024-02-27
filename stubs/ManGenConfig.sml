
(* TODO: dependencies *)
structure ManGenConfig = struct


    val auth_phrase = ssl_sig_parameterized default_place
    fun auth_phrase_list p = [(Coq_pair auth_phrase p)]

    val kim_phrase = Coq_att coq_P1 (kim_meas dest_plc kim_meas_targid) 
    val kim_phrases =   [(Coq_pair kim_phrase coq_P0)] @ (auth_phrase_list coq_P0)

    val kim_enc_phrase = Coq_att coq_P1  (Coq_lseq (kim_meas dest_plc kim_meas_targid) (Coq_asp (ENC coq_P0)))
    val kim_enc_phrases =   [(Coq_pair kim_enc_phrase coq_P0)] @ (auth_phrase_list coq_P0)
    val cert_phrase = cert_style
    val cert_phrases =  [(Coq_pair cert_phrase coq_P0)] @ (auth_phrase_list coq_P0)
    val cache_phrase_p0 = cert_cache_p0
    val cache_phrase_p1 = cert_cache_p1
    val cache_phrases = [(Coq_pair cache_phrase_p0 coq_P0), (Coq_pair cache_phrase_p1 coq_P1)] @ (auth_phrase_list coq_P0) @ (auth_phrase_list coq_P1)
    val parmut_phrase_p0 = par_mut_p0 
    val parmut_phrase_p1 = par_mut_p1
    val parmut_phrases' = [(* (Coq_pair par_mut_p0 coq_P3) ,*) (Coq_pair parmut_phrase_p0 coq_P0), (Coq_pair parmut_phrase_p1 coq_P1) (* , (Coq_pair par_mut_p1 coq_P4) *) ] 
    val parmut_phrases_auth = (auth_phrase_list coq_P3) @ (auth_phrase_list coq_P0) @ (auth_phrase_list coq_P1) (* @ (auth_phrase_list coq_P4) *)
    val parmut_phrases = parmut_phrases' @ parmut_phrases_auth
    val layered_bg_phrase = layered_bg_strong
    val layered_bg_phrases = [(Coq_pair layered_bg_phrase coq_P0)] @ (auth_phrase_list coq_P0)
    val cm_phrase = Coq_lseq (cm_meas coq_P0 cm_targid) (Coq_asp SIG)
        (* Coq_lseq (cm_meas coq_P0 cm_targid) (ssl_sig_parameterized coq_P0) *)
    val cm_phrases = [(Coq_pair cm_phrase coq_P0)] (* @ (auth_phrase_list coq_P0) *)

    val cm_layered_phrase : coq_Term = Coq_att coq_P1 (Coq_lseq (cm_meas coq_P1 sys) (Coq_asp SIG))
    val cm_layered_phrases = [(Coq_pair cm_layered_phrase coq_P0)] @ (auth_phrase_list coq_P0)

    val demo_phrase = example_phrase
    val demo_phrase_p2_appraise = example_phrase_p2_appraise
    val demo_phrases = [(Coq_pair demo_phrase coq_P0)] @ (auth_phrase_list coq_P0)

    val inline_auth_phrase = inline_auth_phrase
    val inline_auth_phrases = [(Coq_pair inline_auth_phrase coq_P0)] @ (auth_phrase_list coq_P0)



    val appraiser_evidence_kim = eval kim_phrase coq_P0 (Coq_nn O)
    val appraiser_evidence_kim_enc = eval kim_enc_phrase coq_P0 (Coq_nn O)
    val appraiser_evidence_cm = eval cm_phrase coq_P0 (Coq_nn O)
    val appraiser_evidence_cm_layered = eval cm_layered_phrase coq_P0 (Coq_nn O)

    val appraiser_evidence_cert = eval cert_phrase coq_P0 (Coq_nn O)
    val appraiser_evidence_cache_p0 = eval cache_phrase_p0 coq_P0 (Coq_nn O)
    val appraiser_evidence_cache_p1 = eval cache_phrase_p1 coq_P1 (Coq_nn O)
    val appraiser_evidence_parmut_p0 = eval parmut_phrase_p0 coq_P0 (Coq_nn O)
    val appraiser_evidence_parmut_p1 = eval parmut_phrase_p1 coq_P1 (Coq_nn O)
    val appraiser_evidence_layeredbg = eval layered_bg_phrase coq_P0 (Coq_nn O)

    val appraiser_evidence_inlineauth = eval inline_auth_phrase coq_P0 (Coq_nn O)

    val ets_kim = [(Coq_pair appraiser_evidence_kim coq_P0),
                    (Coq_pair appraiser_evidence_kim coq_P3)]
    val ets_kim_enc = [(Coq_pair appraiser_evidence_kim_enc coq_P0),
                    (Coq_pair appraiser_evidence_kim_enc coq_P3)]
    val ets_cm = [(Coq_pair appraiser_evidence_cm coq_P0), 
                    (Coq_pair appraiser_evidence_cm coq_P3)]
    val ets_cm_layered = [(Coq_pair appraiser_evidence_cm_layered coq_P0), 
                    (Coq_pair appraiser_evidence_cm_layered coq_P3)]
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

    val ets_inlineauth = [(Coq_pair appraiser_evidence_inlineauth coq_P0),
                            (Coq_pair appraiser_evidence_inlineauth coq_P3)]

    val appraiser_evidence_demo_phrase = eval demo_phrase coq_P0 (Coq_nn O)

    val appraiser_evidence_demo_phrase_p2 = eval demo_phrase coq_P2 (Coq_nn O)

    val appraiser_evidence_demo_phrase' = eval demo_phrase_p2_appraise coq_P0 (Coq_nn O)

    val ets_example_phrase = [(Coq_pair appraiser_evidence_demo_phrase coq_P0), 
                                (Coq_pair appraiser_evidence_demo_phrase coq_P3)]

                                
end
(*  End structure ManGenConfig *)
(*  Whitespace for cmake compilation purposes... *)