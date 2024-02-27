(* Stub code for ASP with asp ID:  cal_ak_aspid *)

(* cal_ak_asp_stub :: coq_ASP_PARAMS -> coq_RawEv -> (coq_BS, coq_DispatcherErrors) coq_ResultT *)
fun cal_ak_asp_stub ps e =
    case ps of Coq_asp_paramsC aspid args tpl tid =>
               let val _ = () in
                   print ("Matched aspid:  " ^ aspid ^ "\n");
                   let val setupSuccess = Crypto.tpmSetup ()
                       val cal_akSuccess = Crypto.tpmCreateSigKey () in
                       if cal_akSuccess 
                       then Coq_resultC (BString.fromString "0") else Coq_resultC (BString.fromString "1")
                   end
               end
