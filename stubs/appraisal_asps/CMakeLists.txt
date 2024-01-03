cmake_minimum_required(VERSION 3.10.2)

get_files(appraisal_asps ./appraise_kim_meas_ASP.sml 
  appraise_ssl_sig_ASP.sml appraise_tpm_sig_ASP.sml
  appraise_attest_meas_ASP.sml appraise_appraise_meas_ASP.sml 
  appraise_cert_meas_ASP.sml appraise_cache_meas_ASP.sml
  
  # For the demo phrase
  appraise_attest1_meas_ASP.sml 
  appraise_attest2_meas_ASP.sml
  )
 
get_files(posix_cm_appraisal_asp
    appraise_cm_meas_ASP_posix.sml
)

get_files(camkes_cm_appraisal_asp
    appraise_cm_meas_ASP_camkes.sml
)

