cmake_minimum_required(VERSION 3.10.2)
# cmake_policy(SET CMP0076 NEW)
set(CMAKE_USER_MAKE_RULES_OVERRIDE "DefaultConfig.cmake")
project(CakemlAM C ASM)

include(CakeMLHelper.cmake)

set(util_src util/ByteString.sml util/CoqDefaults.sml util/Json.sml util/Misc.sml)
set(cop_src ${util_src} copland/Instr.sml copland/AM.sml copland/VM.sml
    copland/json/CoplandToJson.sml copland/json/JsonToCopland.sml)
# TODO: separate meas from crypto
set(crypto_src system/crypto/CryptoFFI.sml)
set(socket_src system/sockets/SocketFFI.sml)
# set(time_src system/time/TimeFFI.sml)
# set(dataport_src system/dataports/DataportFFI.sml)
set(server_am_src ${cop_src} ${crypto_src} system/crypto/MeasFFI.sml am/Measurements.sml ${socket_src}
    am/CommTypes.sml am/ServerAm.sml)
set(standalone_am_src ${cop_src} ${crypto_src} am/CommTypes.sml)

#set(tests_src  ${server_am_src} apps/tests/Main.sml)
#set(client_src ${server_am_src} apps/serverClient/ClientTest.sml)
#set(server_src ${server_am_src} apps/serverClient/Server.sml)

#set(gs_src  ${server_am_src} apps/case/Groundstation.sml)
#set(uav_src ${server_am_src} ${time_src} system/dataports/UavDataportFFI.sml apps/case/Uav.sml)

set(case2_client_src apps/case2/DtuGolden.sml ${server_am_src} apps/case2/Protocol.sml apps/case2/Provision.sml apps/case2/Client.sml)
# set(provision_src apps/case2/GoldenHashes.sml ${server_am_src} apps/case2/Protocol.sml apps/case2/Provision.sml)
set(heli_src ${standalone_am_src} apps/case2/HamrFFI.sml apps/case2/GoldenHashes.sml apps/case2/Heli.sml)

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

    # Arch Config
    set(TARGET_ARCH "native" CACHE STRING "Options: \"native\", \"armv7\", \"armv8\", or \"other\".")
    string(TOLOWER ${TARGET_ARCH} target_arch_lower)

    string(COMPARE NOTEQUAL "${target_arch_lower}" "native" default_static_linking)
    set(STATIC_LINKING default_static_linking CACHE BOOL "")

    mark_as_advanced(FORCE CMAKE_INSTALL_PREFIX)
    mark_as_advanced(CLEAR
        CMAKE_C_COMPILER CMAKE_ASM_COMPILER CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG
        CMAKE_C_FLAGS_RELEASE CMAKE_EXE_LINKER_FLAGS CMAKE_VERBOSE_MAKEFILE
    )

    set(BASIS_FILE "" CACHE FILEPATH "File path to `basis_ffi.c`. If empty, will use default.")
    if ("${BASIS_FILE}" STREQUAL "")
	set(basis_file system/basis_ffi.c)
    else()
        set(basis_file ${BASIS_FILE})
    endif()

    # Add targets
    add_subdirectory(system/crypto)
    function(build_am_exe name)
        build_cake("${name}.cake" SOURCES "${ARGN}")
        add_executable(${name} ${basis_file} system/sockets/socket_ffi.c)
        if(${STATIC_LINKING})
            set(link_flags "-static-libgcc -static")
        endif()
        target_link_libraries(${name} "${name}.cake" crypto ${link_flags})
    endfunction()
    function(build_am_lib name)
        build_cake("${name}.cake" SOURCES "${ARGN}")
        #add_library(${name} system/basis_ffi.c)
        if(${STATIC_LINKING})
            set(link_flags "-static-libgcc -static")
        endif()
        #target_link_libraries(${name} "${name}.cake" crypto ${link_flags})
    endfunction()


    # build_am_thing("tests"  ${tests_src})

    # build_am_thing("server" ${server_src})
    # build_am_thing("client" ${client_src})
    # add_custom_target(am DEPENDS server client)
    
    # build_am_thing("gs_am"  ${gs_src})
    # build_am_thing("uav_am" ${uav_src})

    build_am_exe("client"  ${case2_client_src})
    #build_am_lib("heli_am" ${heli_src})

    # build_am_exe("provision" ${provision_src})

    build_cake("heli_am.cake" SOURCES "${heli_src}")
    add_executable(fake_heli_am ${basis_file} apps/case2/fake_ffi.c)
    if(${STATIC_LINKING})
        set(link_flags "-static-libgcc -static")
    endif()
    target_link_libraries(fake_heli_am "heli_am.cake" crypto ${link_flags})

    build_cake("heli_am" SOURCES "${heli_src}")
    target_link_libraries(heli_am crypto)

    add_custom_target(case DEPENDS client heli_am)
endif()
