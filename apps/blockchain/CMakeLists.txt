cmake_minimum_required(VERSION 3.10.2)

get_files(blockchain_client_src ${server_am_src} ../../util/Http.sml Blockchain.sml Client.sml)
build_posix_am("blockchainClient" ${blockchain_client_src})

get_files(blockchain_server_src ${server_am_src} Server.sml)
build_posix_am("blockchainServer" ${blockchain_server_src})

get_files(blockchain_setHash_src ${util_src} ${posix_src} ../../util/Http.sml Blockchain.sml SetHash.sml)
build_posix_am("blockchainSetHash" ${blockchain_setHash_src})

get_files(blockchain_setHash_c_src ../../system/posix/sockets/socket_ffi.c)
target_sources(blockchainSetHash PRIVATE ${blockchain_setHash_c_src})

add_custom_target(blockchain DEPENDS blockchainServer blockchainClient blockchainSetHash)
