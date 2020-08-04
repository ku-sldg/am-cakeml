cmake_minimum_required(VERSION 3.10.2)
# cmake_policy(SET CMP0076 NEW)
set(CMAKE_USER_MAKE_RULES_OVERRIDE "DefaultConfig.cmake")
project(CakemlAM C ASM)

include(CakeMLHelper.cmake)

set(util_src util/ByteString.sml util/CoqDefaults.sml util/Json.sml)
set(cop_src ${util_src} copland/Instr.sml copland/AM.sml copland/VM.sml
    copland/json/CoplandToJson.sml copland/json/JsonToCopland.sml)
set(crypto_src system/crypto/CryptoFFI.sml)
set(socket_src system/sockets/SocketFFI.sml)
set(time_src system/time/TimeFFI.sml)
set(dataport_src system/dataports/DataportFFI.sml)
set(server_am_src ${cop_src} ${crypto_src} am/Measurements.sml ${socket_src}
    am/CommTypes.sml am/ServerAm.sml)

set(tests_src  ${server_am_src} apps/tests/Main.sml)
set(client_src ${server_am_src} apps/serverClient/ClientTest.sml)
set(server_src ${server_am_src} apps/serverClient/Server.sml)

set(gs_src  ${server_am_src} apps/case/Groundstation.sml)
set(uav_src ${server_am_src} ${time_src} system/dataports/UavDataportFFI.sml apps/case/Uav.sml)

# Unfortunately, the build process will diverge significantly between
# standalone executables and CAmkES components
if(${CAmkES})
    add_subdirectory(system/crypto)
    cakeml_component(AM
        CML_SOURCES "${camkes_src}"
        C_SOURCES "sockets/dummy_ffi.c"
        LIBS "camkescakeml;crypto"
    )

# Standalone executables
else()
    # OS Config
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
    if("${BASIS}" STREQUAL "BASIS-NOTFOUND")
        message(FATAL_ERROR "No \"basis_ffi.c\" file found! Please set the \"BASIS\" variable manually.")
    endif()

    # Arch Config
    set(TARGET_ARCH "native" CACHE STRING "Options: \"native\", \"armv7\", or \"other\".")
    string(TOLOWER ${TARGET_ARCH} target_arch_lower)
    if("${target_arch_lower}" STREQUAL "armv7")
        set(CMAKE_C_FLAGS "-mfloat-abi=hard ${CMAKE_C_FLAGS}")
        find_program (arm-hf-gcc arm-linux-gnueabihf-gcc)
        if("${arm-hf-gcc}" STREQUAL "arm-hf-gcc-NOTFOUND")
            message(WARNING "Cross-compiling to the armv7 architecture requires hard-float support. Please ensure your C compiler supports this.")
        else()
            set(CMAKE_C_COMPILER ${arm-hf-gcc})
        endif()
        unset(arm-hf-gcc)
    elseif(NOT(("${target_arch_lower}" STREQUAL "native") OR ("${target_arch_lower}" STREQUAL "other")))
        message(FATAL_ERROR "TARGET_ARCH value \"${TARGET_ARCH}\" is invalid. Please select from: \"native\", \"armv7\", or \"other\".")
    endif()

    string(COMPARE NOTEQUAL "${target_arch_lower}" "native" default_static_linking)
    set(STATIC_LINKING default_static_linking CACHE BOOL "")

    mark_as_advanced(FORCE CMAKE_INSTALL_PREFIX)
    mark_as_advanced(CLEAR
        CMAKE_C_COMPILER CMAKE_ASM_COMPILER CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG
        CMAKE_C_FLAGS_RELEASE CMAKE_EXE_LINKER_FLAGS CMAKE_VERBOSE_MAKEFILE
    )

    # Add targets
    add_subdirectory(system/crypto)
    function(build_am_thing name)
        build_cake("${name}.cake" SOURCES "${ARGN}")
        add_executable(${name} ${BASIS} system/sockets/socket_ffi.c)
        if(${STATIC_LINKING})
            set(link_flags "-static-libgcc -static")
        endif()
        target_link_libraries(${name} "${name}.cake" crypto ${link_flags})
    endfunction()

    build_am_thing("tests"  ${tests_src})

    build_am_thing("server" ${server_src})
    build_am_thing("client" ${client_src})
    add_custom_target(am DEPENDS server client)
    
    build_am_thing("gs_am"  ${gs_src})
    build_am_thing("uav_am" ${uav_src})
    # Hacky way to prevent CMAKE complaints
    if(NOT "${am_queue}" STREQUAL "")
        set(am_src ${am_queue}/src/am_queue.c)
    endif()
    target_sources("uav_am" PRIVATE
        system/dataports/uav_dataport_ffi.c
        system/time/sys/linux/time.c
        ${am_src}
    )
    target_include_directories("uav_am" PRIVATE ${am_queue}/include)
    add_custom_target(case DEPENDS gs_am uav_am)
endif()
