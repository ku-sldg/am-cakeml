(* Depends on: util, copland, am/Measurements, am/ServerAm *)

val term = demo_phrase

(* main :: () -> () *)                                                 
fun main () = (* sendReq term *)

    let val name  = CommandLine.name ()
        val usage = ("Usage: " ^ name ^ " configurationFile\n"
                    ^ "e.g.   " ^ name ^ " config.ini\n")
        val toPl = source_plc
        val myPl = dest_plc

     in case CommandLine.arguments () of
              [fileName] => (
             case parseIniFile fileName of
                 Err e  =>  let val _ = O in
                                TextIOExtra.printLn_err e
                            end
               | Ok ini =>
                 case (iniServerAm ini) of
                     Err e => let val _ = O in
                                  TextIOExtra.printLn_err e
                              end
                   | Ok nsMap => let val _ = (print "\nSending Request in Client\n\n")
                                     val nonceVal = BString.fromString "anonce"
                                     (* val badNonceVal = BString.fromString "badnonce" *)
				     (* sendReq --> am/CoplandCommUtil.sml *)
                                     val rawev_res = sendReq term myPl toPl nsMap [nonceVal]
                                     (* val et_computed = eval term myPl Coq_mt *)
                                     val appraise_res = run_gen_appraise_w_nonce
							    term myPl nonceVal rawev_res
                                     (* print ("Evidence Type computed: \n" ^
                                        (evToStr ing et_computed) ^ "\n\n"); *)
                                     val _ = print ("Appraisal Evidence Summary Structure: \n" ^
                                                    evidenceCToString appraise_res ^ "\n\n")
                                     val bool_res =
                                         case appraise_res of
                                             Coq_eec_app _ _ _
                                                         (Coq_ggc_app _ _ sigcheckres _) =>
                                             (sigcheckres = passed_bs)
                                           | _ => let val _ = print ("\nFailed to match expected Appraisal Evidence structure\n") in False
                                                  end
                                     val _ = case bool_res of
                                                 True =>
                                                 let val client_data = BString.fromString "client secret"
                                                     val client_phrase = client_data_phrase
                                                     val _ = sendReq client_phrase myPl toPl
                                                                     nsMap [client_data]
                                                                     
                                                                     
                                                 in (print ("\nSent data to appraised server...\n"))
                                                 end
                                               | _ =>
                                                 (print ("\nAppraisal of Server failed.\n")) in
                                     ()
                                                     
                                 end
                                     
         )
            | _ => let val _ = O in
                       TextIOExtra.printLn_err usage
                   end
    end
        
val _ = main ()      
