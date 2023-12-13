get_files(client_src 
    ${client_am_src_camkes}
    ${CMAKE_CURRENT_LIST_DIR}/Test_Am_Lib_Cm.sml
    Client.sml
)
build_posix_am_hacl(useram ${client_src})
