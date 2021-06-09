cmake_minimum_required(VERSION 3.10.2)

get_files(client_src ${server_am_src} ../blockchain/Blockchain.sml ClientTest.sml)
build_posix_am("client" ${client_src})

get_files(server_src ${server_am_src} Server.sml)
build_posix_am("server" ${server_src})

get_files(setHash_src ${util_src} ../../system/posix/sockets/SocketFFI.sml ../blockchain/Blockchain.sml SetHash.sml)
build_posix_am("setHash" ${setHash_src})

get_files(setHash_c_src ../../system/posix/sockets/socket_ffi.c)
target_sources(setHash PRIVATE ${setHash_c_src})