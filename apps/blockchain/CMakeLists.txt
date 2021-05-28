cmake_minimum_required(VERSION 3.10.2)

# This sets our CakeML source to just these two files
get_files(blockchain_src ../../util/Json.sml blockchain.sml)

# This version would instead add all of the CakeML source files used by linux AMs:
# get_files(blockchain_src ${server_am_src} blockchain.sml)

# This will build an executable from your list of CakeML sources
# (it also links against several C FFI files for posix system calls)
build_posix_am("blockchain_test" ${blockchain_src})
