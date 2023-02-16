cmake_minimum_required(VERSION 3.10.2)

get_files(client_src ${server_am_src_tpm} Client.sml)
build_posix_am_tpm("camkes_client" ${client_src})

