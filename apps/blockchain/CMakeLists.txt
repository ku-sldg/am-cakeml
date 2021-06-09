cmake_minimum_required(VERSION 3.10.2)

# This sets our CakeML source to just these two files
get_files(blockchain_src ${util_src} ../../system/posix/sockets/SocketFFI.sml Blockchain.sml)
build_posix_am("blockchain" ${blockchain_src})

# This will build an executable from your list of CakeML sources
# (it also links against several C FFI files for posix system calls)
get_files(blockchain_c_src ../../system/posix/sockets/socket_ffi.c)
target_sources(blockchain PRIVATE ${blockchain_c_src})
