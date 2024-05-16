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
                            Build_AM_Library _ _ _ _ addr _ _ _ _ _ _ _ _ => addr

                        val appRequestArg = List.hd args 
                        val appRequestString =
                          case appRequestArg of 
                            Arg_ID s => s
                        val inStrJson = strToJson appRequestString 
                        val appReq = jsonToAppRequest inStrJson

                        

                        val res' = 
                        case appReq of 
                          REQ_APP t p et _ (*ev*) => 
                            (let val appresult = run_appraisal_client 
                                             t 
                                             p 
                                             et 
                                             e 
                                             appServerAddr

                                val _ = print ("\n\nAppraised Evidence structure:  \n" ^ (evidenceCToString appresult) ^ "\n\n")
                                val _ = print ("\n\n\n\n\n\n\n\n\n\n DECODED APP REQUEST in 'appraise_inline_asp_stub...\n\n\n\n\n\n\n\n\n\n")
                                in
                                  Coq_resultC (passed_bs)
                             end)
                             in res' 
                      end) in 
                        res
                 end

                