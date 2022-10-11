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
                       | Ok nsMap => let val _ = O in
                                         print "\nSending Request in Client\n\n";
                                         let val nonceVal = BString.fromString "anonce"
                                             (* val badNonceVal = BString.fromString "badnonce" *)
					     (* sendReq --> am/CoplandCommUtil.sml *)
                                             val rawev_res = sendReq term myPl toPl nsMap [nonceVal]
                                             (* val et_computed = eval term myPl Coq_mt *)
                                             val appraise_res = run_gen_appraise_w_nonce
									term myPl nonceVal rawev_res in
                                             (* print ("Evidence Type computed: \n" ^
                                                    (evToString et_computed) ^ "\n\n"); *)
                                             print ("Appraisal Evidence Summary Structure: \n" ^
                                                    evidenceCToString appraise_res ^ "\n\n")
                                         end
                                        
                                     end
              )
           | _ => let val _ = O in
                       TextIOExtra.printLn_err usage
                  end
    end

        
val _ = main ()      
