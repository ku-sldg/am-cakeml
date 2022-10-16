(* Stub code for ASP with asp ID:  ssl_sig_aspid *)


fun get_prikey ps = (* BString.empty *)
    let val name  = CommandLine.name ()
        val usage = ("Usage: " ^ name ^ " configurationFile\n"
                     ^ "e.g.   " ^ name ^ " config.ini\n")

    in case CommandLine.arguments () of
           [fileName] => (
            case parseIniFile fileName of
                Err e  =>  let val _ = O in
                               TextIOExtra.printLn_err e; BString.empty
                           end
              | Ok ini =>
                let val opt_key_string = Map.lookup ini "privateKey"
                    val key_bytes = case opt_key_string of
                                         Some v => BString.unshow v
                                       | _ =>
                                         let val _ = TextIOExtra.printLn_err "\nError:  no 'privateKey' field configured for ini\n\n"
                                         in BString.empty
                                         end
                in key_bytes
                end)
    end






(* ssl_sig_asp_stub :: coq_ASP_PARAMS -> coq_RawEv -> coq_BS *)
fun ssl_sig_asp_stub ps e =
    case ps of Coq_asp_paramsC aspid args tpl tid =>
               let val _ = () in
                   print ("Matched aspid:  " ^ aspid ^ "\n");
                   let val data = encode_RawEv e
		       val myPriKey = get_prikey ps (* privGood *) (* privBad *)
                       val sigRes = Crypto.signMsg myPriKey data (* Crypto.tpmSign data *) in
                       sigRes
                   end
               end
