cmake_minimum_required(VERSION 3.10.2)

get_files(client_am_src ${server_am_src} client_am.sml)
build_posix_am("client_am" ${client_am_src})
