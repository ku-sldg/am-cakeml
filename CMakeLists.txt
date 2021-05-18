cmake_minimum_required(VERSION 3.10.2)
# cmake_policy(SET CMP0076 NEW)
include(ExternalProject)
set(CMAKE_USER_MAKE_RULES_OVERRIDE "DefaultConfig.cmake")
project(CakemlAM C ASM)

include(CakeMLHelper.cmake)

set(util_src util/ByteString.sml util/CoqDefaults.sml util/Json.sml util/Misc.sml)
set(cop_src ${util_src} copland/Instr.sml copland/AM.sml copland/VM.sml
    copland/json/CoplandToJson.sml copland/json/JsonToCopland.sml)
set(crypto_src system/crypto/CryptoFFI.sml)
set(socket_src system/sockets/SocketFFI.sml)
set(server_am_src ${cop_src} ${crypto_src} system/crypto/MeasFFI.sml am/Measurements.sml ${socket_src}
    am/CommTypes.sml am/ServerAm.sml)
set(standalone_am_src ${cop_src} ${crypto_src} am/CommTypes.sml)

set(heli_src ${standalone_am_src} apps/case2/HamrFFI.sml apps/case2/GoldenHashes.sml apps/case2/Heli.sml)

mark_as_advanced(FORCE CMAKE_INSTALL_PREFIX)
mark_as_advanced(CLEAR
    CMAKE_C_COMPILER CMAKE_ASM_COMPILER CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG
    CMAKE_C_FLAGS_RELEASE CMAKE_EXE_LINKER_FLAGS CMAKE_VERBOSE_MAKEFILE
)

ExternalProject_Add(hacl-star
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

add_definitions(-DIS_ARM_7 -DBROKEN_INTRINSICS -DKRML_VERIFIED_UINT128)
add_definitions(-DLib_IntVector_Intrinsics_vec256="void *")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -march=armv7 -mfpu=neon -mfloat-abi=softfp")

include_directories(BEFORE ${hacl_path} ${kremlin_path} ${kremlib_path})
build_cake("heli_am" ENTRY_NAME "run" SOURCES "${heli_src}" C_SOURCES "system/crypto/crypto_ffi.c;system/crypto/sys/CAmkES/crypto_ffi.c;${hacl_sources}")
add_dependencies("heli_am" hacl-star)