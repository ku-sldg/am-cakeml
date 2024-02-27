cmake_minimum_required(VERSION 3.10.2)

get_files(attestation_asps
    get_data_ASP_Stub.sml
    ssl_enc_ASP_Stub.sml
    store_clientData_ASP_Stub.sml
    ssl_sig_ASP_Stub.sml
    ssl_sig_ASP_Stub_two.sml
    kim_meas_ASP_Stub.sml
    attest_ASP_Stub.sml
    appraise_ASP_Stub.sml
    appraise_inline_ASP_Stub.sml
    cert_ASP_Stub.sml
    cache_ASP_Stub.sml
    sig_ASP_Stub.sml
    cm_ASP_Stub.sml
    check_ssl_sig_ASP_Stub.sml

    # For Demo Phrase
    attest1_ASP_Stub.sml
    attest2_ASP_Stub.sml
)
