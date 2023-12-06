cmake_minimum_required(VERSION 3.10.2)

get_files(appraisal_asps ./appraise_kim_meas_ASP.sml 
  appraise_ssl_sig_ASP.sml appraise_tpm_sig_ASP.sml
  appraise_attest_meas_ASP.sml appraise_appraise_meas_ASP.sml 
  appraise_cert_meas_ASP.sml appraise_cache_meas_ASP.sml
  appraise_cm_meas_ASP.sml
  appraise_check_ssl_sig_ASP.sml
  
  # For the demo phrase
  appraise_attest1_meas_ASP.sml 
  appraise_attest2_meas_ASP.sml
  )
 
