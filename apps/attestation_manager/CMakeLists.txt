cmake_minimum_required(VERSION 3.10.2)

get_files(AM_src ${server_am_src} 
  attestation_manager.sml)
build_posix_am("attestation_manager" ${AM_src})
