cmake_minimum_required(VERSION 3.10.2)

get_files(AM_src ${server_am_src} 
  json_handler.sml)
build_posix_am("json_handler" ${AM_src})
