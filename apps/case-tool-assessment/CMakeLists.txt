cmake_minimum_required(VERSION 3.10.2)

ExternalProject_Add(hacl-star2
    GIT_REPOSITORY https://github.com/project-everest/hacl-star/
    # This was the most recent commit on master, at the time of integration.
    # The next release will likely support ARM cross-compilation (as this commit
    # does), and we should switch to that when it arrives.
    GIT_TAG 50db8e4147258a5dc8e18c940c1b045ce5558723
    GIT_PROGRESS True
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/hacl-star
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
)

set(hacl_release_dir "${CMAKE_CURRENT_BINARY_DIR}/hacl-star/dist")
set(hacl_path    "${hacl_release_dir}/gcc-compatible")
set(kremlin_path "${hacl_release_dir}/kremlin/include")
set(kremlib_path "${hacl_release_dir}/kremlin/kremlib/dist/minimal")

set(hacl_sources ${hacl_path}/Hacl_Hash.c ${hacl_path}/Hacl_Ed25519.c ${hacl_path}/Hacl_Curve25519_51.c)
set_source_files_properties(${hacl_sources} PROPERTIES GENERATED True)

# Heli build
get_files(heli_src_nocrypto ${cop_src} HamrStandard.sml GoldenHashes.sml FakeCrypto.sml Heli.sml)
get_files(heli_c_src_nocrypto fake_crypto_ffi.c)
build_cake("heli_am_nocrypto"
    ENTRY_NAME "run"
    SOURCES "${heli_src_nocrypto}"
    C_SOURCES "${heli_c_src_nocrypto}"
)

get_files(heli_src ${cop_src} ${crypto_src} HamrStandard.sml GoldenHashes.sml RealCrypto.sml Heli.sml)
get_files(heli_c_src "../../system/crypto/crypto_ffi.c;${hacl_sources}")
build_cake("heli_am"
    ENTRY_NAME "run"
    SOURCES "${heli_src}"
    C_SOURCES "${heli_c_src}"
)
target_include_directories("heli_am" BEFORE PRIVATE ${hacl_path} ${kremlin_path} ${kremlib_path})
add_dependencies("heli_am" hacl-star2)

# User build
get_files(user_src_nocrypto ${cop_src} HamrStandard.sml GoldenHashes.sml FakeCrypto.sml User.sml)
get_files(user_c_src_nocrypto fake_crypto_ffi.c)
build_cake("user_am_nocrypto"
    ENTRY_NAME "run"
    SOURCES "${user_src_nocrypto}"
    C_SOURCES "${user_c_src_nocrypto}"
)

get_files(user_src ${cop_src} ${crypto_src} HamrStandard.sml GoldenHashes.sml RealCrypto.sml User.sml)
get_files(user_c_src "../../system/crypto/crypto_ffi.c;${hacl_sources}")
build_cake("user_am"
    ENTRY_NAME "run"
    SOURCES "${user_src}"
    C_SOURCES "${user_c_src}"
)
target_include_directories("user_am" BEFORE PRIVATE ${hacl_path} ${kremlin_path} ${kremlib_path})
add_dependencies("user_am" hacl-star2)

add_custom_target(tool_assessment_nocrypto DEPENDS heli_am_nocrypto user_am_nocrypto)
add_custom_target(tool_assessment DEPENDS heli_am user_am)