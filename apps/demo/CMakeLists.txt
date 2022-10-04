cmake_minimum_required(VERSION 3.10.2)

get_files(client_src ${server_am_src_tpm} client/ClientTest.sml)
build_posix_am_tpm("clientdemo" ${client_src})

get_files(server_src ${server_am_src_tpm} server/Server.sml)
build_posix_am_tpm("serverdemo" ${server_src})

add_custom_target(demo DEPENDS serverdemo clientdemo)
