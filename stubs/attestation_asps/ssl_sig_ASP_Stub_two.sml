(* Stub code for ASP with asp ID:  ssl_sig_aspid *)

(* ssl_sig_asp_stub_two :: coq_ASP_PARAMS -> coq_RawEv -> coq_BS *)
fun ssl_sig_asp_stub_two (ps : coq_ASP_PARAMS) (e : coq_RawEv) =
    case ps of Coq_asp_paramsC aspid args tpl tid =>
        let val _ = () in
            print ("NEW VERSION OF SSL SIG STUB\n");
            print ("Matched aspid:  " ^ aspid ^ "\n");
            let val data = coq_RawEv_to_stringT e
                val privKey = ManifestUtils.get_myPrivateKey()
                val sigRes = Crypto.signMsg privKey (BString.unshow data)
            in
                Coq_resultC (sigRes)
            end
        end
