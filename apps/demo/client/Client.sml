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
				     val auth_token = (* BString.fromString "auth_tok" *)
                                         let val res = run_cvm_rawEv ssl_sig myPl [] (* [BString.empty] *) in
                                             res
                                         end
                                     val _ = print ("\n\nauth_token sent: " ^ (rawEvToString auth_token) ^ "\n\n")
                                     val initEv = List.@ auth_token [nonceVal]
                                     val rawev_res = sendReq term myPl toPl nsMap initEv (* [auth_token, nonceVal] *)
                                     val _ = print "\n\nStarting Evidence Appraisal...\n\n"
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
                                                         (Coq_ggc_app _ _ sigcheckres
                                                                      (Coq_ggc_app _ _ _
                                                                      (Coq_ggc_app _ _ kimcheckres _))) =>
                                             if (sigcheckres = passed_bs)
                                             then if (kimcheckres = passed_bs)
                                                  then True
                                                  else False
                                             else False
                                           | _ => let val _ = print ("\nFailed to match expected Appraisal Evidence structure\n") in False
                                                  end
                                     val _ = case bool_res of
                                                 True =>
                                                 let val _ = print "\nSending Client data to Server ... \n"
                                                     val client_data = BString.fromString "client data"
                                                     val client_phrase = client_data_phrase
                                                     val initEv_Client = List.@ auth_token [client_data]
                                                     val _ = sendReq client_phrase myPl toPl
                                                                     nsMap initEv_Client (* [auth_token, client_data] *)
                                                                     
                                                                     
                                                 in () (* (print ("\nSent data to appraised server...\n")) *)
                                                 end
                                               | _ =>
                                                 (print ("\nAppraisal of Server FAILED.\n")) in
                                     ()
                                                     
                                 end
                                     
         )
            | _ => let val _ = O in
                       TextIOExtra.printLn_err usage
                   end
    end
        
val _ = main ()      





(*
List.null: 'a list -> bool
List.length: 'a list -> int
List.rev: 'a list -> 'a list
List.@: 'a list -> 'a list -> 'a list
List.hd: 'a list -> 'a
List.tl: 'a list -> 'a list
List.last: 'a list -> 'a
List.getItem: 'a list -> ('a * 'a list) option
List.nth: 'a list -> int -> 'a
List.take: 'a list -> int -> 'a list
List.drop: 'a list -> int -> 'a list
*)
