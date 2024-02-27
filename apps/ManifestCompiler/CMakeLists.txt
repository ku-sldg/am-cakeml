cmake_minimum_required(VERSION 3.10.2)

get_files(manComp_src ${server_am_src_noasps} Compiler.sml)
build_posix_am_noasps("manComp_demo" ${manComp_src})

add_custom_target(manifest_compiler DEPENDS manComp_demo)