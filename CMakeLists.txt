cmake_minimum_required(VERSION 3.10.2)
cmake_policy(SET CMP0076 NEW)
set(CMAKE_USER_MAKE_RULES_OVERRIDE "DefaultConfig.cmake")
project(CakemlAM C ASM)

include(CakeMLHelper.cmake)

# CakeML source/dependency lists
set(core_src
    util/ByteString.sml crypto/CryptoFFI.sml crypto/Aes256.sml crypto/Random.sml
    sockets/SocketFFI.sml util/CoqDefaults.sml interp/CoplandLang.sml
    am/Measurements.sml am/CommTypes.sml JSON/Json.sml JSON/CoplandToJson.sml
    JSON/JsonToCopland.sml am/CommUtil.sml interp/Eval.sml interp/Instr.sml
)
set(server_src ${core_src} am/Server.sml)
set(client_src ${core_src} am/ClientTest.sml)
set(vmTest_src ${core_src} tests/VmTest.sml)
set(camkes_src ${core_src} tests/CAmkESTest.sml)
set(tests_src  ${core_src} tests/Main.sml)
set(uav_src    ${core_src} uav/Cache.sml uav/Demo.sml)

# Unfortunately, the build process will diverge significantly between
# standalone executables and CAmkES components
if(${CAmkES})
    add_subdirectory(crypto)
    cakeml_component(AM
        CML_SOURCES "${camkes_src}"
        C_SOURCES "sockets/dummy_ffi.c"
        LIBS "camkescakeml;crypto"
    )

# Standalone executables
else()
    # Config
    if(${APPLE})
        set(default_os "macOS")
    else()
        set(default_os "linux")
    endif()
    set(TARGET_OS ${default_os} CACHE STRING "Options are: linux, macOS. Affects which system calls are performed.")
    string(TOLOWER ${TARGET_OS} target_os_lower)
    if(NOT (${target_os_lower} STREQUAL "linux" OR ${target_os_lower} STREQUAL "macos"))
        message(FATAL_ERROR "TARGET_OS value \"${TARGET_OS}\" is invalid. Please select from: linux, macOS.")
    endif()
    find_file(BASIS NAMES "basis_ffi.c" PATHS "~/cake-x64-64/" "/cake-x64-64/" "~/cake-x64-32/" "/cake-x64-32/"
                    DOC "The \"basis_ffi.c\" file bundled with the CakeML compiler.")
    if("${BASIS}" STREQUAL "basis-NOTFOUND")
        message(WARNING "No \"basis_ffi.c\" file found! Please set the \"BASIS\" variable manually.")
    endif()

    mark_as_advanced(FORCE CMAKE_INSTALL_PREFIX)
    mark_as_advanced(CLEAR
        CMAKE_C_COMPILER CMAKE_ASM_COMPILER CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG
        CMAKE_C_FLAGS_RELEASE CMAKE_EXE_LINKER_FLAGS CMAKE_VERBOSE_MAKEFILE
    )

    # Add targets
    add_subdirectory(crypto)
    function(build_am_thing name)
        build_cake("${name}.cake" SOURCES "${ARGN}")
        add_executable(${name} ${BASIS} sockets/socket_ffi.c)
        target_link_libraries(${name} "${name}.cake" crypto)
    endfunction()
    build_am_thing("server" ${server_src})
    build_am_thing("client" ${client_src})
    build_am_thing("vmTest" ${vmTest_src})
    build_am_thing("tests"  ${tests_src})
    build_am_thing("uav"    ${uav_src})
    add_custom_target(am DEPENDS server client)
endif()
