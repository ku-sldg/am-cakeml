(* *)


(** val run_cvm_rawEv : coq_Term -> coq_Plc -> coq_RawEv -> coq_RawEv **)

(** fun run_cvm_json : Json.json -> Json.json *)
fun run_cvm_json (j : Json.json) = 
    let val cvmin = jsonToCvmIn j in 
    case cvmin of 
        CVM_IN t ev => 
            let val resev = run_cvm_rawEv t "" ev
                val cvmout = CVM_OUT resev in
                    cvmOutMessageToJson cvmout
            end 
    end


(** fun run_cvm_rawev_json : coq_Term -> coq_RawEv -> coq_RawEv *)
fun run_cvm_rawev_json (t:coq_Term) (ev:coq_RawEv) = 
    let val cvmin = CVM_IN t ev 
        val cvmin_json = cvmInMessageToJson cvmin
        val cvmout_json = run_cvm_json cvmin_json 
        val cvmout = jsonToCvmOut cvmout_json in 
        case cvmout of 
            CVM_OUT ev' => ev'
    end