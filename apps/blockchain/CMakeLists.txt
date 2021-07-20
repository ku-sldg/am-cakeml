cmake_minimum_required(VERSION 3.10.2)

get_files(blockchain_client_src ${server_am_src} ../../util/Http.sml Blockchain.sml Client.sml)
build_posix_am("blockchainClient" ${blockchain_client_src})

get_files(blockchain_server_src ${server_am_src} Server.sml)
build_posix_am("blockchainServer" ${blockchain_server_src})

get_files(blockchain_setHash_src ${util_src} ${posix_src} ../../util/Http.sml Blockchain.sml SetHash.sml)
build_posix_am("blockchainSetHash" ${blockchain_setHash_src})

add_custom_target(blockchain DEPENDS blockchainServer blockchainClient blockchainSetHash)

get_files(blockchain_addUser_src ${util_src} ${posix_src} ../../util/Http.sml Blockchain.sml AddUser.sml)
build_posix_am("blockchainAddUser" ${blockchain_addUser_src})

get_files(blockchain_removeUser_src ${util_src} ${posix_src} ../../util/Http.sml Blockchain.sml RemoveUser.sml)
build_posix_am("blockchainRemoveUser" ${blockchain_removeUser_src})

get_files(blockchain_CA_src ${util_src} ${posix_src} CA.sml)
build_posix_am("blockchainCA" ${blockchain_CA_src})

get_files(blockchain_CA_client_src ${util_src} ${posix_src} CAClient.sml)
build_posix_am("blockchainCAClient" ${blockchain_CA_client_src})

add_custom_target(blockchainCAAll DEPENDS blockchainCA blockchainCAClient)

add_custom_target(blockchainAll DEPENDS blockchain blockchainAddUser blockchainRemoveUser blockchainCAAll)
