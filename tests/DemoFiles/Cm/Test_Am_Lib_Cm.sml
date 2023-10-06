
val aspMapping = (mapC_from_pairList 
  [
    (ssl_enc_aspid,
      fn par => fn plc => fn bs => fn rawEv => ssl_enc_asp_stub par rawEv),
    (store_clientData_aspid,
      fn par => fn plc => fn bs => fn rawEv => store_clientData_asp_stub par rawEv),
    (ssl_sig_aspid,
      fn par => fn plc => fn bs => fn rawEv => 
        let val _ = print "\nORIGINAL SSL ASP STUB\n"
        in
          ssl_sig_asp_stub par rawEv
        end),
    (kim_meas_aspid,
      fn par => fn plc => fn bs => fn rawEv => kim_meas_asp_stub par rawEv),
    (attest_id,
      fn par => fn plc => fn bs => fn rawEv => attest_asp_stub par rawEv),
    (appraise_id,
      fn par => fn plc => fn bs => fn rawEv => appraise_asp_stub par rawEv),
    (cert_id,
      fn par => fn plc => fn bs => fn rawEv => cert_asp_stub par rawEv), 
    (cm_aspid,
      fn par => fn plc => fn bs => fn rawEv => cm_asp_stub par rawEv), 
    (sig_aspid,
      fn par => fn plc => fn bs => fn rawEv => ssl_sig_asp_stub par rawEv)
  ]
  ) : ((coq_ASP_ID, coq_CallBackErrors coq_ASPCallback) coq_MapC)

val appAspMapping = (mapC_from_pairList [

      ((Coq_pair coq_P0 sig_aspid), 
        fn par => fn p => fn bs => fn rawEv => appraise_ssl_sig par p bs rawEv), 

      ((Coq_pair coq_P1 ssl_sig_aspid), 
        fn par => fn p => fn bs => fn rawEv => appraise_ssl_sig par p bs rawEv), 

      ((Coq_pair coq_P1 kim_meas_aspid), 
        fn par => fn p => fn bs => fn rawEv => appraise_kim_meas_asp_stub par p bs rawEv),

      ((Coq_pair coq_P0 cm_aspid), 
        fn par => fn p => fn bs => fn rawEv => appraise_cm_asp_stub par p bs rawEv)


]) : (((coq_Plc, coq_ASP_ID) prod, coq_CallBackErrors coq_ASPCallback) coq_MapC)



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

val aspServer_cb = (fn aspServerAddr => fn aspParams => fn plc => fn bs => fn rawEv => do_asp aspServerAddr aspParams rawEv) : (coq_ASP_Address -> coq_CallBackErrors coq_ASPCallback)

val pubKeyServer_cb = (fn _ => fn _ => (Coq_resultC (BString.unshow "OUTPUT_PUBKEY"))) :  (coq_ASP_Address -> coq_PubKeyCallback)

val plcServer_cb = (fn plcServerAddr => fn plc => 
  case (plc = "1") of
    True => (Coq_resultC "localhost:5001")
    | _ => 
      let val _ = print ("Encountered Plc not in Local Plcs: '" ^ plc ^ "'\n") 
      in 
        raise (Exception ("TODO: Dispatch this request to Plc server at '" ^ plcServerAddr ^ "'\n"))
      end
  ) : (coq_ASP_Address ->  coq_PlcCallback)

val uuidServer_cb = (fn _ => fn _ => (Coq_resultC "OUTPUT_PLC")) : (coq_ASP_Address -> coq_UUIDCallback)

val am_library = 
  (Build_AM_Library 
    aspServer_cb pubKeyServer_cb plcServer_cb uuidServer_cb
    
    "ASP_SERVER:5000" "PubKeyServer:5000" "PlcServer:5000" "UUIDServer:5000"

    aspMapping
    appAspMapping
    (mapD_from_pairList [("P0", "localhost:5005"),("P1", "localhost:5001"),("P2", "localhost:5002")])

    (mapD_from_pairList [("P0", (BString.unshow "3082010a0282010100c822fb2b7842e61fa6a779a48f2164793e21d640687146b48ac4e977a4a69f90383c94f3ea5e5336052b728f0a83151603edef890b2a6099376ae87a384a6b236ed51c7f19d94c8b4acb9b00de6cb1c6fc40ff9fec7967ebdbc48cd9b15103411a3b8978d93e59988a7baa21dd3e6fa220359e228f847b81be77bf2467bea40496135a8d06a42c3416bffec3646c8fda7eee19a74275fa2b21bfaa5c8b0dc8e82511b2d8b9a7b760b1d0ae0be03cd98615f3e6c2bc51b1ab11f5b87aad9b44264a2470f26a3a55e4dbd1fa6ea52e66093b4a3eae73bcd7237f07b1ea394a9f893b32d6da15a46f5d7e77c5a6b12ebf41cc7743f4cc241266e58566645dfbbd210203010001")),("1", (BString.unshow "3082010a0282010100c822fb2b7842e61fa6a779a48f2164793e21d640687146b48ac4e977a4a69f90383c94f3ea5e5336052b728f0a83151603edef890b2a6099376ae87a384a6b236ed51c7f19d94c8b4acb9b00de6cb1c6fc40ff9fec7967ebdbc48cd9b15103411a3b8978d93e59988a7baa21dd3e6fa220359e228f847b81be77bf2467bea40496135a8d06a42c3416bffec3646c8fda7eee19a74275fa2b21bfaa5c8b0dc8e82511b2d8b9a7b760b1d0ae0be03cd98615f3e6c2bc51b1ab11f5b87aad9b44264a2470f26a3a55e4dbd1fa6ea52e66093b4a3eae73bcd7237f07b1ea394a9f893b32d6da15a46f5d7e77c5a6b12ebf41cc7743f4cc241266e58566645dfbbd210203010001")), ("2", (BString.unshow "3082010a0282010100c822fb2b7842e61fa6a779a48f2164793e21d640687146b48ac4e977a4a69f90383c94f3ea5e5336052b728f0a83151603edef890b2a6099376ae87a384a6b236ed51c7f19d94c8b4acb9b00de6cb1c6fc40ff9fec7967ebdbc48cd9b15103411a3b8978d93e59988a7baa21dd3e6fa220359e228f847b81be77bf2467bea40496135a8d06a42c3416bffec3646c8fda7eee19a74275fa2b21bfaa5c8b0dc8e82511b2d8b9a7b760b1d0ae0be03cd98615f3e6c2bc51b1ab11f5b87aad9b44264a2470f26a3a55e4dbd1fa6ea52e66093b4a3eae73bcd7237f07b1ea394a9f893b32d6da15a46f5d7e77c5a6b12ebf41cc7743f4cc241266e58566645dfbbd210203010001"))])
    ) : coq_AM_Library