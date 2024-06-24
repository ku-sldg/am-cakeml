cmake_minimum_required(VERSION 3.10.2)

get_files(AM_src ${server_am_src} AM.sml)
build_posix_am("AttestationManager" ${AM_src})

add_custom_target(attestation_manager DEPENDS AttestationManager)