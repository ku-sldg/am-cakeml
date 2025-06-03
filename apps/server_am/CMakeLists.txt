cmake_minimum_required(VERSION 3.10.2)

get_files(AM_src ${server_am_src} 
  server_am.sml)
build_posix_am("server_am" ${AM_src})
