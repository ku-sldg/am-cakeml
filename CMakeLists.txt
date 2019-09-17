cmake_minimum_required(VERSION 3.11.2)
set(CMAKE_USER_MAKE_RULES_OVERRIDE "DefaultConfig.cmake")
project(CakemlAM C ASM)

# Config stuff - edit with ccmake
set(CAKE_DIR ~/cake-x64-64 CACHE PATH "Directory containing cake executable and basis_ffi.c")
if(APPLE)
    set(default_os "macOS")
else()
    set(default_os "linux")
endif()
set(TARGET_OS ${default_os} CACHE STRING "Options are: linux, macOS, and seL4 (case sensitive). Affects which system calls are performed.")
set(cakec ${CAKE_DIR}/cake)
set(basis ${CAKE_DIR}/basis_ffi.c)
mark_as_advanced(FORCE CMAKE_INSTALL_PREFIX)
mark_as_advanced(CLEAR
    CMAKE_C_COMPILER CMAKE_ASM_COMPILER CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG
    CMAKE_C_FLAGS_RELEASE CMAKE_EXE_LINKER_FLAGS CMAKE_VERBOSE_MAKEFILE
)

# Bring in other CMake stuff (notably after we set up our variables!)
include(CakemlHelper.cmake)
add_subdirectory(crypto)

# CakeML source/dependency lists
set(core_src
    util/ByteString.sml crypto/CryptoFFI.sml crypto/Aes256.sml crypto/Random.sml
    sockets/SocketFFI.sml util/CoqDefaults.sml interp/CoplandLang.sml
    am/Measurements.sml am/CommTypes.sml JSON/Json.sml JSON/CoplandToJson.sml
    JSON/JsonToCopland.sml am/CommUtil.sml interp/Eval.sml interp/Instr.sml
)
set(server_src ${core_src} am/Server.sml)
set(client_src ${core_src} am/ClientTest.sml)
set(vmTest_src ${core_src} tests/vmTest.sml)
set(test_src   ${core_src} tests/Main.sml)


# Targets
gen_cakeml(server ${server_src})
target_sources(server PUBLIC ${basis} sockets/socket_ffi.c)
target_link_libraries(server crypto)

gen_cakeml(client ${client_src})
target_sources(client PUBLIC ${basis} sockets/socket_ffi.c)
target_link_libraries(client crypto)

gen_cakeml(test ${test_src})
target_sources(test PUBLIC ${basis} sockets/socket_ffi.c)
target_link_libraries(test crypto)

gen_cakeml(vmTest ${vmTest_src})
target_sources(vmTest PUBLIC ${basis} sockets/socket_ffi.c)
target_link_libraries(vmTest crypto)

add_custom_target(am DEPENDS server client)
