(* Stub code for ASP with asp ID:  appraise_id *)

(* appraise_asp_stub :: coq_ASP_PARAMS -> coq_RawEv -> coq_BS *)
fun appraise_asp_stub ps e =
    case ps of Coq_asp_paramsC aspid args tpl tid =>
               let val _ = (print ("Matched aspid:  " ^ aspid ^ "\n");
                            print ("Performing ASP " ^ aspid ^ "\n\n")) 
                    (*

                    val my_amlib = ManifestUtils.get_local_amLib ()

                    val appServerAddr = 
                      case my_amlib of  
                            Build_AM_Library _ _ _ _ addr _ _ _ _ _ _ _ _ => addr

                    val appresult = run_appraisal_client 
                                      example_phrase_p2_appraise
                                      coq_P0 
                                      (Coq_nn O)
                                      e 
                                      appServerAddr

                     val _ = print ("\n\nAppraised Evidence structure:  \n" ^ (evidenceCToString appresult) ^ "\n\n")
                    

                    *)
              (*

              (** val run_appraisal_client :
                coq_Term -> coq_Plc -> coq_Evidence -> coq_RawEv -> coq_UUID ->
                coq_AppResultC **)

            fun run_appraisal_client t p et re addr =
              am_sendReq'_app addr t p et re


              *)




               (*
               
                   val my_amconfig = ManifestUtils.get_AM_config ()
                   val da_manifest = 
                        case my_amconfig of Coq_mkAmConfig m _ _ _ _ _ => m 
                   val _ = print ("Manifest from AM Config: \n" ^ (pretty_print_manifest_simple da_manifest) ^ "\n\n")




                   (*

                   val my_amlib = ManifestUtils.get_local_amLib ()

                   *)
                   val my_amconfig_app_cb = case my_amconfig of Coq_mkAmConfig _ _ appcb _ _ _ => appcb

                   val app_cb_resultT = my_amconfig_app_cb (Coq_asp_paramsC attest1_id [] coq_P1 sys) coq_P1 passed_bs [passed_bs]

                   val _ = case app_cb_resultT of 
                            Coq_resultC _ => print "\n\nAPP CB Succeeded\n\n"
                          | Coq_errC Unavailable => print "\n\nAPP CB Error (Unavailable)\n\n"
                                             

                   (*
                   val my_amlib_app_map = case my_amlib of 
                                            Build_AM_Library _ _ _ _ _ _ _ _ _ app_map _ _ => app_map

                   val libresCbMaybe = 
                        map_get 
                            (pair_EqClass coq_Eq_Class_ID_Type coq_Eq_Class_ID_Type)
                            my_amlib_app_map
                            (Coq_pair coq_P1 attest1_id)

                    val _ = case libresCbMaybe of 
                            Some cb => print "\n\nFound app CB in AM Library\n\n"
                            | _ => print "\n\nDid NOT find app CB in AM Library\n\n"


                  *)






                   val et = eval example_phrase_p2_appraise coq_P0 (Coq_nn O) (* eval example_phrase_p2_appraise coq_P2 (Coq_nn O) *)
                   val _ = print ("\n\nPerforming inline appraisal via ASP with ID: " ^ aspid ^ "\n\n")

                (*
                   val et = Coq_uu 
                                coq_P1 
                                EXTD 
                                (Coq_asp_paramsC attest1_id [] coq_P1 sys)
                                (Coq_nn O)
                            (*
                            Coq_uu 
                                coq_P1 
                                EXTD 
                                (Coq_asp_paramsC attest1_id [] coq_P1 sys)
                                Coq_mt (* (Coq_nn O) *)
                            *)
                   *)

                   (* val e =  [passed_bs, my_nonceval] *)
                   
                   
                   val _ = print ("\nEvidence candidate: \n" ^ (evToString et) ^ "\n\n")
                   val _ = print ("\nRawEv sequence candidate: \n" ^ (rawEvToString e) ^ "\n\n")
                   

                   val my_nonceval = (BString.fromString "anonce") : coq_BS

            (*
                   val et1 = Coq_uu 
                                coq_P1 
                                EXTD 
                                (Coq_asp_paramsC attest1_id [] coq_P1 sys)
                                Coq_mt (* (Coq_nn O) *)
                            (* (Coq_nn O) *)
                            (*
                            Coq_uu 
                                coq_P1 
                                EXTD 
                                (Coq_asp_paramsC attest1_id [] coq_P1 sys)
                                Coq_mt (* (Coq_nn O) *)
                            *)

                   val e1 = [passed_bs] (* [passed_bs, my_nonceval] *)

                   val _ = print ("\nEvidence candidate: \n" ^ (evToString et1) ^ "\n\n")
                   val _ = print ("\nRawEv sequence candidate: \n" ^ (rawEvToString e1) ^ "\n\n")

                   *)

                   (* 

                   SS_E (UU_E P1 EXTD (ASP_PARAMS attest1_aspid [] P1 sys_targid) (N 0))
                        (UU_E P1 EXTD (ASP_PARAMS attest1_aspid [] P1 sys_targid) (N 0))
                   


                   datatype coq_Evidence =
                    Coq_mt 
                    | Coq_nn coq_N_ID
                    | Coq_uu coq_Plc coq_FWD coq_ASP_PARAMS coq_Evidence
                    | Coq_ss coq_Evidence coq_Evidence
                   *)
                   

                   val amcomp = (* gen_appraise_AM et1 e1 *)
                                gen_appraise_AM et e
                   val my_noncemap = [(Coq_pair O my_nonceval)] : (coq_N_ID, coq_BS) coq_MapC

                   (*

                   val da_manifest = 
                        case my_amconfig of Coq_mkAmConfig m _ _ _ _ _ => m 
                   val _ = print ("Manifest: \n" ^ (pretty_print_manifest_simple da_manifest) ^ "\n\n")
                   val om = lib_omits_manifest my_amlib da_manifest
                   val _ = print ("OMITTED Manifest fields: \n" ^ (pretty_print_manifest_simple om) ^ "\n\n")

                   *)

                   val my_amst = Coq_mkAM_St my_noncemap (S O) my_amconfig
                        (* empty_amst *)
                   val appres = run_am_app_comp_init amcomp my_amst Coq_mtc_app True
                   val _ = print ("Appraised Evidence structure:  \n" ^ (evidenceCToString appres) ^ "\n\n")








                   *)
                   
                   in
                   Coq_resultC (passed_bs)
               end
