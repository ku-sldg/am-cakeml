(* Stub code for ASP with asp ID:  ssl_sig_aspid *)

(* ssl_sig_asp_stub :: coq_ASP_PARAMS -> coq_RawEv -> coq_BS *)
fun ssl_sig_asp_stub (ps : coq_ASP_PARAMS) (e : coq_RawEv) =
    case ps of Coq_asp_paramsC aspid args tpl tid =>
        let val _ = () in
            print ("Matched aspid:  " ^ aspid ^ "\n");
            let val data = encode_RawEv e
                val json = get_json ()
                val jsonMap = json_config_to_map json
                val myPriKey = 
                    case (Map.lookup jsonMap "privateKey") of
                      None => raise Undef (* TODO *)
                      | Some k => 
                          case (Json.toString k) of
                            None => raise Undef (* TODO *) 
                            (* We have to do an extra conversion here from hex to bytestring? *)
                            | Some k' => (BString.unshow k')
                val sigRes = Crypto.signMsg myPriKey data in
                sigRes
            end
        end
