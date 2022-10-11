cmake_minimum_required(VERSION 3.10.2)

get_files(tests_src_hacl ${server_am_src_hacl} Main_hacl.sml)
build_posix_am_hacl("tests_hacl" ${tests_src_hacl})

get_files(tests_src ${util_src} ${posix_src} Main.sml)
build_posix_am("tests" ${tests_src})

get_files(tests_src_tpm ${server_am_src_tpm} Main_tpm.sml)
build_posix_am_tpm("tests_tpm" ${tests_src_tpm})
