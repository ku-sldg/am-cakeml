cmake_minimum_required(VERSION 3.10.2)

cakeml_component(
    server_am
    CML_SOURCES
       ${server_am_src_camkes}
       ${CMAKE_CURRENT_LIST_DIR}/../../tests/DemoFiles/Cm/Test_Am_Lib_Cm.sml
       ${CMAKE_CURRENT_LIST_DIR}/Server.sml
    C_SOURCES
        ${camkes_c_files}
    LIBS
)

add_hacl_camkes(server_am)

