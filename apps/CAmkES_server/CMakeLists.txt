cmake_minimum_required(VERSION 3.10.2)

get_files(server_src ${server_am_src_tpm} Server.sml)
build_posix_am_tpm("camkes_server" ${server_src})

