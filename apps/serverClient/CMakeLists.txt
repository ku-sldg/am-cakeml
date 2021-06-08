cmake_minimum_required(VERSION 3.19)

get_files(client_src ${server_am_src} ../blockchain/Blockchain.sml ClientTest.sml)
build_posix_am("client" ${client_src})

get_files(server_src ${server_am_src} Server.sml)
build_posix_am("server" ${server_src})

get_files(setHash_src ${util_src} ../blockchain/Blockchain.sml SetHash.sml)
build_posix_am("setHash" ${setHash_src})