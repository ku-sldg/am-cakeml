cmake_minimum_required(VERSION 3.10.2)

get_files(manComp_src ${server_am_src_tpm} Compiler2.sml)
build_posix_am_tpm("manComp_demo" ${manComp_src})

add_custom_target(manifest_compiler DEPENDS manComp_demo)