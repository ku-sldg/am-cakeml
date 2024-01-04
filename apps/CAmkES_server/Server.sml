(* Depends on: util, copland, system/sockets, am/Measurementsm am/CommTypes,
   am/ServerAm extracted/Term_Defs_Core.cml *)

(* term_policy_check_good :: Coq_Term (extracted/Term_Defs_Core.cml/) -> bool *)
fun term_policy_check_good p termIn = privPolicy p termIn (* TODO: invoke policy code here *)

(* When things go well, this returns a JSON evidence string. When they go wrong,
   it returns a raw error message string. In the future, we may want to wrap
   said error messages in JSON as well to make it easier on the client. *)
fun evalJson s =       (* jsonToStr (responseToJson (RES O O [])) *)
    
    let val (REQ pl1 pl2 map t et ev') = jsonToRequest (strToJson s)
        val ev = ev'
        (* val me = O (* TODO: hardcode ok? *) *)

        val resev = run_am_serve_auth_tok_req t pl1 pl2 ev' et
                     





                     
      (*
    	val ev = List.tl ev'
	val ev_head = List.hd ev'
	val _ = print ("\nReceived request with Auth Token: " ^ (BString.toString ev_head) ^ "\n\n")
*)
      

      (*
        val appraise_res =
            run_gen_appraise (ssl_sig) me (Coq_mt) BString.empty [ev_head]
        val _ = print ("Auth Appraisal Evidence Summary Structure: \n" ^
                       evidenceCToString appraise_res ^ "\n\n")
      *)




(*



                     
        val auth_bool_res = True
      (*
            case appraise_res of
                Coq_ggc_app _ _ sigcheckres _ => (sigcheckres = passed_bs)
              | _ =>
                let val _ =
                        print ("\nFailed to match expected Appraisal Evidence structure\n")
                in False
                end
      *)
                                
        val ev' =
            if (auth_bool_res)
            then
                let val _ = (print "\nPASSED authentication (client request)\n")
                    val policy_check = True (* term_policy_check_good dest_plc t *) in
                    if (policy_check)
                    then
                        let val _= (print "\nPASSED policy check (client request)\n\n") in
                            run_cvm_rawEv t me ev
                        end

                     
                    else
                        let val _= (print "\nFAILED policy check (client request)\n") in
                            []
                        end
                end
            else
                let val _= (print "\nFAILED authentication (client request)\n") in
                    []
                end




                    
                      (*
            case (auth_bool_res) of
                True =>
                let
                    val policy_check = term_policy_check_good dest_plc t in
                    case (policy_check) of
                        True => run_cvm_rawEv t me ev
                      | _ =>  (print "\nFailed policy check for client\n"); []
                      (* Returning empty evidence on failed policy check.
                         TODO:  return error response to client? *)
                end
              | _ => (print "\nFailed to authenticate client\n"); [] *)


*)
            
    in jsonToStr (responseToJson (RES pl2 pl1 resev))
    end
    handle Json.Exn s1 s2 =>
           (TextIO.print_err (String.concat ["JSON error", s1, ": ", s2, "\n"]);
            "Invalid JSON/Copland term")
        (*
         | USMexpn s =>
            (TextIO.print_err (String.concat ["USM error: ", s, "\n"]);
            "USM failure")   *)
              

fun respondToMsg client = Socket.output client (evalJson (Socket.inputAll client))
                                           

fun handleIncoming listener =
    let val client = Socket.accept listener
     in respondToMsg client;
        Socket.close client
    end
    handle Socket.Err s     => TextIOExtra.printLn_err ("Socket failure: " ^ s)
         | Socket.InvalidFD => TextIOExtra.printLn_err "Invalid file descriptor"


                                                       

(* (string, string) map -> (string -> 'a option) -> ('a -> string) -> string -> 'a -> 'a *)
fun lookupOrDefault ini read write k default =
    case Map.lookup ini k of
      None => (
          TextIOExtra.printLn ("No field \"" ^ k ^ "\", defaulting to " ^ write default ^ ".");
          default
      )
    | Some v => (
        case read v of
          None => (
              TextIOExtra.printLn ("Cannot read \"" ^ k ^ "\", defaulting to " ^ write default ^ ".");
              default
          )
        | Some r => r
      )

(* (string, string) map -> () *)
fun startServer ini =
    let val port = lookupOrDefault ini Int.fromString Int.toString "port" 5000
        val qLen = lookupOrDefault ini Int.fromString Int.toString "queueLength" 5
     in case iniServerAm ini of 
          Err e => TextIOExtra.printLn_err e
        | Ok _ => loop handleIncoming (Socket.listen port qLen)
    end
    handle Socket.Err s => TextIO.print_err ("Socket failure on listener instantiation: " ^ s ^ "\n")
         | Crypto.Err s => TextIO.print_err ("Crypto error: " ^ s ^ "\n")
         | _          => TextIO.print_err "Fatal: unknown error\n"

(* () -> () *)
fun main () =
    let val ini = get_ini () in
        startServer ini
    end
        
val () = main ()
