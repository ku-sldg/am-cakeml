cmake_minimum_required(VERSION 3.10.2)

get_files(termToJson_src ${server_am_src} ../../extracted/Flexible_Mechanisms.cml TermToJson.sml)
build_posix_am("TermToJson" ${termToJson_src})

add_custom_target(term_to_json DEPENDS TermToJson)
