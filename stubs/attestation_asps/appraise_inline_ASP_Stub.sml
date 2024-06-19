(* Stub code for ASP with asp ID:  appraise_inline_id *)

(* appraise_inline_asp_stub :: coq_ASP_PARAMS -> coq_RawEv -> coq_BS *)
fun appraise_inline_asp_stub ps e =
    case ps of Coq_asp_paramsC aspid args tpl tid =>
               let val _ = (print ("Matched aspid:  " ^ aspid ^ "\n");
                            print ("Performing ASP " ^ aspid ^ "\n\n")) 

                    val my_amlib = ManifestUtils.get_local_amLib ()

                    val argsNull = List.null args 

                    val res = 
                    if (argsNull) 
                    then (print "\n\nError:  expected singleton list arg list in 'appraise_inline_asp_stub'...\n\n";  Coq_resultC (failed_bs)) 
                    else (

                    let val appServerAddr = 
                          case my_amlib of  
                            Build_AM_Library addr _ _ _ _ => addr

                        val appRequestString =
                          case map_get coq_Eq_Class_ID_Type args "APPR_INLINE" of
                            Some s => s
                          | None => raise (Exception "Error:  expected 'APPR_INLINE' arg in 'appraise_inline_asp_stub'...")
                        
                        val inStrJson = case Json.parse appRequestString of
                                          Err e => raise (Exception e)
                                        | Ok j => case cakeML_JSON_to_coq_JSON j of
                                                    Coq_errC s => raise (Exception s)
                                                  | Coq_resultC r => r
                        val appReq = case (coq_JSON_to_ProtocolAppraiseRequest inStrJson) of
                                      Coq_errC s => raise (Exception s)
                                    | Coq_resultC r => r

                        val res' = 
                        case appReq of 
                          
                          Coq_mkPAReq t p et _ (*ev*) => 
                            (let val appresult = case (run_appraisal_client t p et e appServerAddr) of
                                                  Coq_errC s => raise (Exception s)
                                                | Coq_resultC r => r

                                val _ = print ("\n\nAppraised Evidence structure:  \n" ^ (coq_AppResultC_to_stringT appresult) ^ "\n\n")
                                val _ = print ("\n\n\n\n\n\n\n\n\n\n DECODED APP REQUEST in 'appraise_inline_asp_stub...\n\n\n\n\n\n\n\n\n\n")
                                in
                                  Coq_resultC (passed_bs)
                             end)
                             in res' 
                      end) in 
                        res
                 end

                