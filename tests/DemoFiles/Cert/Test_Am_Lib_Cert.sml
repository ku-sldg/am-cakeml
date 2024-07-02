
val aspMapping = (mapC_from_pairList 
  [
    (ssl_enc_aspid, (Local_ASP "/home/w732t351/repos/asp-libs/attestation_asps/test_asp.out")),
    (store_clientData_aspid, (Local_ASP "/home/w732t351/repos/asp-libs/attestation_asps/test_asp.out")),
    (ssl_sig_aspid, (Local_ASP "/home/w732t351/repos/asp-libs/attestation_asps/test_asp.out")),
    (kim_meas_aspid, (Local_ASP "/home/w732t351/repos/asp-libs/attestation_asps/test_asp.out")),
    (attest_id, (Local_ASP "/home/w732t351/repos/asp-libs/attestation_asps/test_asp.out")),
    (appraise_id, (Local_ASP "/home/w732t351/repos/asp-libs/attestation_asps/test_asp.out")),
    (cert_id, (Local_ASP "/home/w732t351/repos/asp-libs/attestation_asps/test_asp.out"))
  ]) : ((coq_ASP_ID, coq_ASP_Locator) coq_MapC)


val appAspMapping = (mapC_from_pairList [

      ((Coq_pair coq_P1 attest_id), (Local_ASP "/home/w732t351/repos/asp-libs/attestation_asps/test_asp.out")),
      ((Coq_pair coq_P2 appraise_id), (Local_ASP "/home/w732t351/repos/asp-libs/attestation_asps/test_asp.out")),
      ((Coq_pair coq_P2 cert_id), (Local_ASP "/home/w732t351/repos/asp-libs/attestation_asps/test_asp.out")),
      ((Coq_pair coq_P1 kim_meas_aspid), (Local_ASP "/home/w732t351/repos/asp-libs/attestation_asps/test_asp.out"))
]) : (((coq_Plc, coq_ASP_ID) prod, coq_ASP_Locator) coq_MapC)

val am_library = 
  (Build_AM_Library 
    "localhost:5003"
    
    aspMapping
    appAspMapping
    (mapD_from_pairList [("P0", "localhost:5005"),("P1", "localhost:5001"),("P2", "localhost:5002"),("P3", "localhost:5003")])

    (mapD_from_pairList [("P0", (BString.unshow "3082010a0282010100c822fb2b7842e61fa6a779a48f2164793e21d640687146b48ac4e977a4a69f90383c94f3ea5e5336052b728f0a83151603edef890b2a6099376ae87a384a6b236ed51c7f19d94c8b4acb9b00de6cb1c6fc40ff9fec7967ebdbc48cd9b15103411a3b8978d93e59988a7baa21dd3e6fa220359e228f847b81be77bf2467bea40496135a8d06a42c3416bffec3646c8fda7eee19a74275fa2b21bfaa5c8b0dc8e82511b2d8b9a7b760b1d0ae0be03cd98615f3e6c2bc51b1ab11f5b87aad9b44264a2470f26a3a55e4dbd1fa6ea52e66093b4a3eae73bcd7237f07b1ea394a9f893b32d6da15a46f5d7e77c5a6b12ebf41cc7743f4cc241266e58566645dfbbd210203010001")),
                         ("P1", (BString.unshow "3082010a0282010100c822fb2b7842e61fa6a779a48f2164793e21d640687146b48ac4e977a4a69f90383c94f3ea5e5336052b728f0a83151603edef890b2a6099376ae87a384a6b236ed51c7f19d94c8b4acb9b00de6cb1c6fc40ff9fec7967ebdbc48cd9b15103411a3b8978d93e59988a7baa21dd3e6fa220359e228f847b81be77bf2467bea40496135a8d06a42c3416bffec3646c8fda7eee19a74275fa2b21bfaa5c8b0dc8e82511b2d8b9a7b760b1d0ae0be03cd98615f3e6c2bc51b1ab11f5b87aad9b44264a2470f26a3a55e4dbd1fa6ea52e66093b4a3eae73bcd7237f07b1ea394a9f893b32d6da15a46f5d7e77c5a6b12ebf41cc7743f4cc241266e58566645dfbbd210203010001")), 
                         ("P2", (BString.unshow "3082010a0282010100c822fb2b7842e61fa6a779a48f2164793e21d640687146b48ac4e977a4a69f90383c94f3ea5e5336052b728f0a83151603edef890b2a6099376ae87a384a6b236ed51c7f19d94c8b4acb9b00de6cb1c6fc40ff9fec7967ebdbc48cd9b15103411a3b8978d93e59988a7baa21dd3e6fa220359e228f847b81be77bf2467bea40496135a8d06a42c3416bffec3646c8fda7eee19a74275fa2b21bfaa5c8b0dc8e82511b2d8b9a7b760b1d0ae0be03cd98615f3e6c2bc51b1ab11f5b87aad9b44264a2470f26a3a55e4dbd1fa6ea52e66093b4a3eae73bcd7237f07b1ea394a9f893b32d6da15a46f5d7e77c5a6b12ebf41cc7743f4cc241266e58566645dfbbd210203010001")),
                         ("P3", (BString.unshow "3082010a0282010100c822fb2b7842e61fa6a779a48f2164793e21d640687146b48ac4e977a4a69f90383c94f3ea5e5336052b728f0a83151603edef890b2a6099376ae87a384a6b236ed51c7f19d94c8b4acb9b00de6cb1c6fc40ff9fec7967ebdbc48cd9b15103411a3b8978d93e59988a7baa21dd3e6fa220359e228f847b81be77bf2467bea40496135a8d06a42c3416bffec3646c8fda7eee19a74275fa2b21bfaa5c8b0dc8e82511b2d8b9a7b760b1d0ae0be03cd98615f3e6c2bc51b1ab11f5b87aad9b44264a2470f26a3a55e4dbd1fa6ea52e66093b4a3eae73bcd7237f07b1ea394a9f893b32d6da15a46f5d7e77c5a6b12ebf41cc7743f4cc241266e58566645dfbbd210203010001"))])
    ) : coq_AM_Library