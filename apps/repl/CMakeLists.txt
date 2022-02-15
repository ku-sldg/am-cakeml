cmake_minimum_required(VERSION 3.10.2)

get_files(repl_src ${server_am_src} main.sml)
# get_files(repl_src ${server_am_src})
# get_files(repl_src ../../util/Extra.sml ../../util/ByteString.sml ../../util/Misc.sml ../../util/Parsing.sml ../../util/Ini.sml)

build_posix_am("repl" ${repl_src})
