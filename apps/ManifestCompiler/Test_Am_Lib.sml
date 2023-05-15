
val aspMapping = (Map.fromList coq_ID_Type_ordering 
  [
    (cal_ak_aspid, 
      fn par => fn plc => fn bs => fn rawEv => cal_ak_asp_stub par rawEv),
    (get_data_aspid,
      fn par => fn plc => fn bs => fn rawEv => get_data_asp_stub par rawEv),
    (tpm_sig_aspid,
      fn par => fn plc => fn bs => fn rawEv => tpm_sig_asp_stub par rawEv),
    (ssl_enc_aspid,
      fn par => fn plc => fn bs => fn rawEv => ssl_enc_asp_stub par rawEv),
    (pub_bc_aspid,
      fn par => fn plc => fn bs => fn rawEv => pub_bc_asp_stub par rawEv),
    (store_clientData_aspid,
      fn par => fn plc => fn bs => fn rawEv => store_clientData_asp_stub par rawEv),
    (ssl_sig_aspid,
      fn par => fn plc => fn bs => fn rawEv => 
        let val _ = print "TEST\n" 
        in
          ssl_sig_asp_stub par rawEv
        end),
    (kim_meas_aspid,
      fn par => fn plc => fn bs => fn rawEv => kim_meas_asp_stub par rawEv)
  ]
  ) : ((coq_ASP_ID, coq_CakeML_ASPCallback) coq_MapC)


(** val do_asp : coq_ASP_Address -> coq_ASP_PARAMS -> coq_RawEv -> coq_BS **)
fun do_asp asp_server_addr ps e =
    let val _ = print ("Running ASP with params: \n" ^ (aspParamsToString ps) ^ "\n")
        val res = 
            case ps of Coq_asp_paramsC aspid args tpl tid =>
              (print ("Matched OTHER aspid:  " ^ aspid ^ "\n");
                    raise (Exception ("TODO: Dispatch this request to ASP server at '" ^ asp_server_addr ^ "'\n")))
    in
        res
    end

val aspServer_cb = (fn aspServerAddr => fn aspParams => fn plc => fn bs => fn rawEv => do_asp aspServerAddr aspParams rawEv) : (coq_ASP_Address -> coq_CakeML_ASPCallback)

val pubKeyServer_cb = (fn _ => fn _ => BString.unshow "OUTPUT_PUBKEY") :  (coq_ASP_Address -> coq_CakeML_PubKeyCallback)

val plcServer_cb = (fn plcServerAddr => fn plc => 
  case (plc = "1") of
    True => "localhost:5001"
    | _ => 
      let val _ = print ("Encountered Plc not in Local Plcs: '" ^ plc ^ "'\n") 
      in 
        raise (Exception ("TODO: Dispatch this request to Plc server at '" ^ plcServerAddr ^ "'\n"))
      end
  ) : (coq_ASP_Address ->  coq_CakeML_PlcCallback)

val uuidServer_cb = (fn _ => fn _ => "OUTPUT_PLC") : (coq_ASP_Address -> coq_CakeML_uuidCallback)

val client_am_library = 
  (Build_AM_Library 
    aspMapping aspServer_cb pubKeyServer_cb plcServer_cb uuidServer_cb) : coq_AM_Library
