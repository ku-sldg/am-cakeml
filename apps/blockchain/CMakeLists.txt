cmake_minimum_required(VERSION 3.10.2)

get_files(blockchain_client_src ${server_am_src} ../../util/BinaryParser.sml ../../util/Http.sml Blockchain.sml HealthRecord.sml Client.sml)
build_posix_am("blockchainClient" ${blockchain_client_src})

get_files(blockchain_server_src ${server_am_src} Server.sml)
build_posix_am("blockchainServer" ${blockchain_server_src})

get_files(blockchain_setHash_src ${util_src} ${posix_src} ../../util/BinaryParser.sml ../../util/Http.sml Blockchain.sml SetHash.sml)
build_posix_am("blockchainSetHash" ${blockchain_setHash_src})

add_custom_target(blockchain DEPENDS blockchainServer blockchainClient blockchainSetHash)

get_files(blockchain_addUser_src ${util_src} ${posix_src} ../../util/BinaryParser.sml ../../util/Http.sml Blockchain.sml AddUser.sml)
build_posix_am("blockchainAddUser" ${blockchain_addUser_src})

get_files(blockchain_removeUser_src ${util_src} ${posix_src} ../../util/BinaryParser.sml ../../util/Http.sml Blockchain.sml RemoveUser.sml)
build_posix_am("blockchainRemoveUser" ${blockchain_removeUser_src})

get_files(healthrecord_clear_src ${server_am_src} ../../util/BinaryParser.sml ../../util/Http.sml Blockchain.sml HealthRecord.sml Clear.sml)
build_posix_am("healthrecordClear" ${healthrecord_clear_src})

get_files(healthrecord_print_src ${server_am_src} ../../util/BinaryParser.sml ../../util/Http.sml Blockchain.sml HealthRecord.sml Print.sml)
build_posix_am("healthrecordPrint" ${healthrecord_print_src})

get_files(healthrecord_addAppraiser_src ${server_am_src} ../../util/BinaryParser.sml ../../util/Http.sml Blockchain.sml HealthRecord.sml AddAppraiser.sml)
build_posix_am("healthrecordAdd" ${healthrecord_addAppraiser_src})

get_files(healthrecord_removeAppraiser_src ${server_am_src} ../../util/BinaryParser.sml ../../util/Http.sml Blockchain.sml HealthRecord.sml RemoveAppraiser.sml)
build_posix_am("healthrecordRemove" ${healthrecord_removeAppraiser_src})

get_files(CA_src ${util_src} ${posix_src} CA.sml)
build_posix_am("CA" ${CA_src})

get_files(CA_client_src ${util_src} ${posix_src} CAClient.sml)
build_posix_am("CAClient" ${CA_client_src})

add_custom_target(CAAll DEPENDS CA CAClient)

add_custom_target(blockchainAll DEPENDS blockchain blockchainAddUser blockchainRemoveUser)
add_custom_target(healthrecordAll DEPENDS blockchain healthrecordClear healthrecordAdd healthrecordRemove healthrecordPrint)
