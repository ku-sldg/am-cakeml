cmake_minimum_required(VERSION 3.10.2)

get_files(client_src ${server_am_src_tpm} ClientTest.sml)
build_posix_am_tpm("client" ${client_src})

#add_custom_target(am DEPENDS server client)
