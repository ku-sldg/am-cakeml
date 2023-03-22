cmake_minimum_required(VERSION 3.10.2)

cakeml_component(
    server_am
    CML_SOURCES
       ${server_am_src_camkes}
       ${CMAKE_CURRENT_LIST_DIR}/example_server-ini.sml
       ${CMAKE_CURRENT_LIST_DIR}/camkes_server.sml
    C_SOURCES
        ${camkes_c_files}
    LIBS
)

add_hacl_camkes(server_am)

