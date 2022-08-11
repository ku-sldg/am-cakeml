cmake_minimum_required(VERSION 3.10.2)
set(CMAKE_USER_MAKE_RULES_OVERRIDE "DefaultConfig.cmake")
project(CakemlAM C ASM)

include(CakeMLHelper.cmake)

function(get_real_file file real_name)
    if(EXISTS ${file})
        set(${real_name} ${file} PARENT_SCOPE)
    elseif(EXISTS ${CMAKE_CURRENT_LIST_DIR}/${file})
        set(${real_name} "${CMAKE_CURRENT_LIST_DIR}/${file}" PARENT_SCOPE)
    endif()
endfunction()

# Gets absolute paths, and preserves order
function(get_files list_name)
    set(get_files_list "")
    foreach (file ${ARGN})
        get_real_file(${file} temp)
        list(APPEND get_files_list ${temp})
    endforeach()
    set(${list_name} ${get_files_list} PARENT_SCOPE)
endfunction()

set(BASIS_FILE "${CMAKE_CURRENT_SOURCE_DIR}/system/basis_ffi.c" CACHE PATH "Filepath of basis_ffi.c to use (associated with the compiler version).")

#[[get_files(util_src util/Extra.sml util/ByteString.sml util/Misc.sml
util/CoqDefaults.sml util/Parser.sml util/Json.sml util/Ini.sml) ]]
get_files(util_src util/CoqDefaults.sml util/Extra.sml util/ByteString.sml util/Misc.sml util/Parser.sml util/Json.sml util/Ini.sml)
#[[get_files(cop_src ${util_src} stubs/BS.sml extracted/Datatypes.sml
copland/Instr.sml copland/AM.sml copland/VM.sml copland/json/CoplandToJson.sml copland/json/JsonToCopland.sml
copland/Parser.sml) ]]
#[[
get_files(cop_src ${util_src} stubs/BS.sml extracted/Datatypes.sml extracted/Term_Defs_Core.cml
copland/AM.sml copland/VM.sml copland/json/CoplandToJson.sml
copland/json/JsonToCopland.sml copland/Parser.sml) ]]

get_files(cop_src ${util_src} stubs/BS.sml
extracted/Datatypes.cml
extracted/Term_Defs_Core.cml stubs/Params_Admits_hardcoded.cml
extracted/Term_Defs.cml copland/CoplandUtil.sml stubs/Axioms_Io.cml
extracted/Evidence_Bundlers.cml extracted/StMonad_Coq.cml
extracted/Cvm_St.cml extracted/IO_Type.cml stubs/IO_Stubs.sml
extracted/Cvm_Monad.cml extracted/Cvm_Impl.cml extracted/Cvm_Run.cml
copland/CvmUtil.sml stubs/Example_Phrases_Demo_Admits.cml
extracted/Example_Phrases_Demo.cml)

#[[
copland/AM.sml copland/VM.sml copland/json/CoplandToJson.sml
copland/json/JsonToCopland.sml copland/Parser.sml) ]]


get_files(crypto_src system/crypto/openssl/CryptoFFI.sml system/crypto/openssl/Random.sml)
get_files(crypto_src_hacl system/crypto/evercrypt/CryptoFFI.sml system/crypto/evercrypt/Random.sml)
get_files(crypto_src_tpm system/crypto/tpm/CryptoFFI.sml system/crypto/tpm/Random.sml)
get_files(posix_src ${crypto_src} system/posix/sockets/SocketFFI.sml system/posix/time/TimeFFI.sml system/posix/meas/MeasFFI.sml)
get_files(posix_src_hacl ${crypto_src_hacl} system/posix/sockets/SocketFFI.sml system/posix/time/TimeFFI.sml system/posix/meas/MeasFFI.sml)
get_files(posix_src_tpm ${crypto_src_tpm}
system/posix/sockets/SocketFFI.sml system/posix/time/TimeFFI.sml
system/posix/meas/MeasFFI.sml)

#[[
get_files(server_am_src ${cop_src} ${posix_src} am/Measurements.sml am/CommTypes.sml am/ServerAm.sml)
get_files(server_am_src_hacl ${cop_src} ${posix_src_hacl} am/Measurements.sml am/CommTypes.sml am/ServerAm.sml)
get_files(server_am_src_tpm ${cop_src} ${posix_src_tpm} am/Measurements.sml am/CommTypes.sml am/ServerAm.sml)
]]

get_files(server_am_src ${cop_src} ${posix_src} )
get_files(server_am_src_hacl ${cop_src} ${posix_src_hacl} )
get_files(server_am_src_tpm ${cop_src} ${posix_src_tpm} )

#get_files(server_am_src ${cop_src})

get_files(posix_c_files
    ${BASIS_FILE}
    system/crypto/openssl/crypto_ffi.c
    system/posix/sockets/socket_ffi.c
    system/posix/time/time_ffi.c
    system/posix/meas/meas_ffi.c
)
get_files(posix_c_files_hacl
    ${BASIS_FILE}
    system/crypto/evercrypt/crypto_ffi.c
    system/posix/sockets/socket_ffi.c
    system/posix/time/time_ffi.c
    system/posix/meas/meas_ffi.c
)
get_files(posix_c_files_tpm
    ${BASIS_FILE}
    system/crypto/tpm/crypto_ffi.c
    system/posix/sockets/socket_ffi.c
    system/posix/time/time_ffi.c
    system/posix/meas/meas_ffi.c
)

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
if(NOT(("${target_arch_lower}" STREQUAL "armv7") OR ("${target_arch_lower}" STREQUAL "armv8")
    OR ("${target_arch_lower}" STREQUAL "native") OR ("${target_arch_lower}" STREQUAL "other")))
    message(FATAL_ERROR "TARGET_ARCH value \"${TARGET_ARCH}\" is invalid. Please select from: \"native\", \"armv7\", \"armv8\", or \"other\".")
endif()

# string(COMPARE NOTEQUAL "${target_arch_lower}" "native" default_static_linking)
# set(STATIC_LINKING default_static_linking CACHE BOOL "")
set(STATIC_LINKING OFF CACHE BOOL "")

mark_as_advanced(FORCE CMAKE_INSTALL_PREFIX)
mark_as_advanced(CLEAR
    CMAKE_C_COMPILER CMAKE_ASM_COMPILER CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG
    CMAKE_C_FLAGS_RELEASE CMAKE_EXE_LINKER_FLAGS CMAKE_VERBOSE_MAKEFILE
)

add_subdirectory(system/crypto/evercrypt)
add_subdirectory(system/crypto/openssl)
add_subdirectory(system/crypto/tpm)

function(build_posix_am name)
    build_cake("${name}.cake" SOURCES "${ARGN}")
    add_executable(${name} ${posix_c_files})
    if(${STATIC_LINKING})
        set(link_flags "-static-libgcc -static -lcrypto")
    else()
        set(link_flags "-lcrypto")
    endif()
    target_link_libraries(${name} "${name}.cake" ${link_flags})
endfunction()

function(build_posix_am_hacl name)
    build_cake("${name}.cake" SOURCES "${ARGN}")
    add_executable(${name} ${posix_c_files_hacl})
    add_hacl(${name})
    if(${STATIC_LINKING})
        set(link_flags "-static-libgcc -static")
    endif()
    target_link_libraries(${name} "${name}.cake" ${link_flags})
endfunction()

function(build_posix_am_tpm name)
    build_cake("${name}.cake" SOURCES "${ARGN}")
    add_executable(${name} ${posix_c_files_tpm})
    add_tpm(${name})
    if(${STATIC_LINKING})
        set(link_flags "-static-libgcc -static -lcrypto")
    else()
        set(link_flags "-lcrypto")
    endif()
    target_link_libraries(${name} "${name}.cake" ${link_flags})
endfunction()

file(GLOB appdirs apps/*)
foreach(appdir ${appdirs})
    if(EXISTS "${appdir}/CMakeLists.txt")
        add_subdirectory(${appdir})
    endif()
endforeach()
