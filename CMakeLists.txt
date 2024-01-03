cmake_minimum_required(VERSION 3.10.2)
set(CMAKE_USER_MAKE_RULES_OVERRIDE "DefaultConfig.cmake")


set(CMAKE_OSX_ARCHITECTURES "x86_64" CACHE STRING "Used for MacOS to configure the architecture")
project(CakemlAM C ASM)

include(CakeMLHelper.cmake)

function(get_real_file file real_name)
    if(EXISTS ${file})
        get_filename_component(TESTVAR "${file}" REALPATH)
        set(${real_name} ${TESTVAR} PARENT_SCOPE)

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

get_files(util_src util/CoqDefaults.sml util/Extra.sml
    util/ByteString.sml util/Misc.sml util/Parser.sml util/Json.sml
    util/BinaryParser.sml util/Http.sml)

get_files(crypto_src 
system/crypto/openssl/CryptoFFI.sml
system/crypto/openssl/Random.sml)

get_files(crypto_src_hacl 
system/crypto/evercrypt/CryptoFFI.sml
system/crypto/evercrypt/Random.sml)

get_files(crypto_src_tpm 
system/crypto/tpm/CryptoFFI.sml
system/crypto/tpm/Random.sml)


get_files (posix_src_cake 
system/posix/sockets/SocketFFI.sml
system/posix/time/TimeFFI.sml 
system/posix/meas/MeasFFI.sml 
system/posix/sys/SysFFI.sml)

get_files(posix_src ${crypto_src} 
${posix_src_cake})

get_files(posix_src_hacl ${crypto_src_hacl}
${posix_src_cake})

get_files(posix_src_tpm ${crypto_src_tpm}
${posix_src_cake})

# Includes the CMakeLists for the specific asps types (modularity)
include(./stubs/appraisal_asps/CMakeLists.txt)
include(./stubs/attestation_asps/CMakeLists.txt)

get_files(cop_src_pre_platform_stubs
    stubs/BS.sml
    stubs/StringT.sml
    stubs/ErrorStringConstants.sml
    extracted/Specif.cml
    extracted/Datatypes.cml
    extracted/EqClass.cml
    extracted/List.cml
    stubs/AbstractedTypes.sml
    extracted/Term_Defs_Core.cml
    extracted/Eqb_Evidence.cml
    stubs/Params_Admits_hardcoded.sml
    extracted/Term_Defs.cml
    extracted/Anno_Term_Defs.cml
    copland/CoplandUtil.sml
    copland/json/CoplandToJson.sml
    copland/json/JsonToCopland.sml
    stubs/CvmJson_Admits.sml
    extracted/Maps.cml
    stubs/Maps.sml
    stubs/Manifest_Admits_Stubs.sml
    extracted/ErrorStMonad_Coq.cml
    stubs/Example_Phrases_Pre_Admits.sml
    extracted/Example_Phrases_Pre.cml
    stubs/Example_Phrases_Admits.sml
    extracted/Manifest_Set.cml
    extracted/Manifest.cml
    extracted/EnvironmentM.cml
    extracted/Manifest_Union.cml
    extracted/Manifest_Generator_Helpers.cml
    extracted/Manifest_Generator.cml
    extracted/Manifest_Generator_Facts.cml
    extracted/ManCompSoundness_Helpers.cml
    extracted/ManCompSoundness.cml
    extracted/Manifest_Generator_Union.cml
    extracted/Manifest_Compiler.cml
    extracted/Cvm_St.cml
    extracted/AM_St.cml
    copland/json/ManifestJsonConfig.sml
    util/ManifestUtils.sml
)

get_files(cop_src_post_platform_stubs
    am/CoplandCommUtil.sml
    stubs/IO_Stubs.sml
    stubs/Axioms_Io.sml
    extracted/Evidence_Bundlers.cml
    extracted/Cvm_Monad.cml
    extracted/Cvm_Impl.cml
    extracted/Cvm_Run.cml
    stubs/Appraisal_IO_Stubs.sml
    extracted/AM_Monad.cml
    extracted/Appraisal_Defs.cml
    extracted/Impl_appraisal.cml
    stubs/Example_Phrases_Demo_Admits.sml
    extracted/Example_Phrases.cml
    extracted/Example_Phrases_Demo.cml
    stubs/IO_Stubs_extra.sml
    am/CommTypes.sml
    extracted/AM_Helpers.cml
    extracted/Client_AM_Local.cml
    extracted/Server_AM.cml
    stubs/ManGenConfig.sml
)

get_files(cop_src
    ${cop_src_pre_platform_stubs}
    ${cop_src_post_platform_stubs}
    ${attestation_asps}
    ${appraisal_asps}
)

get_files(cop_src_noasps
    ${cop_src_pre_platform_stubs}
    ${cop_src_post_platform_stubs}
)

get_files(server_am_src_noasps ${util_src} ${posix_src} ${cop_src_noasps})

get_files(server_am_src ${util_src} ${posix_src} ${cop_src})
get_files(server_am_src_hacl ${util_src} ${posix_src_hacl} ${cop_src})
get_files(server_am_src_tpm ${util_src} ${posix_src_tpm} ${cop_src})
get_files(server_am_src_camkes 
    ${util_src}
    util/Log.sml
    system/camkes/measurement_RPC/Measurement_RPC.sml
    system/camkes/fileserver_RPC/FileServer_RPC.sml
    ${crypto_src_hacl}
    ${cop_src_pre_platform_stubs}
    system/camkes/commutil_RPC/CommUtil_RPC.sml
    am/seL4CommUtil.sml
    ${cop_src_post_platform_stubs}
    ${attestation_asps}
    ${camkes_cm_attestation_asp}
    ${appraisal_asps}
    ${camkes_cm_appraisal_asp}
)
get_files(client_am_src_camkes
    ${util_src}
    util/Log.sml
    ${posix_src_hacl}
    ${cop_src_pre_platform_stubs}
    copland/json/BashFunctions.sml
    system/posix/dataports/DataportFFI.sml
    am/PosixCommUtil.sml
    ${cop_src_post_platform_stubs}
    ${attestation_asps}
    ${posix_cm_attestation_asp}
    ${appraisal_asps}
    ${posix_cm_appraisal_asp}
)

get_files(posix_c_files_base
    system/posix/sockets/socket_ffi.c
    system/posix/time/time_ffi.c
    system/posix/meas/meas_ffi.c
    system/posix/sys/sys_ffi.c
    system/posix/dataports/dataport_ffi.c
)


get_files(posix_c_files_noasps
    ${BASIS_FILE}
    system/crypto/openssl/crypto_ffi.c
    ${posix_c_files_base}
)

get_files(posix_c_files
    ${BASIS_FILE}
    system/crypto/openssl/crypto_ffi.c
    ${posix_c_files_base}
)
get_files(posix_c_files_hacl
    ${BASIS_FILE}
    system/crypto/evercrypt/crypto_ffi.c
    ${posix_c_files_base}
)
get_files(posix_c_files_tpm
    ${BASIS_FILE}
    system/crypto/tpm/crypto_ffi.c
    ${posix_c_files_base}
)
get_files(camkes_c_files
    system/camkes/basis_ffi.c
    system/crypto/evercrypt/crypto_ffi.c
    system/camkes/measurement_RPC/measurement_RPC.c
    system/camkes/fileserver_RPC/fileserver_RPC.c
    system/camkes/commutil_RPC/commutil_RPC.c
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

function(build_posix_am_noasps name)
    build_cake("${name}.cake" SOURCES "${ARGN}")
    add_executable(${name} ${posix_c_files_noasps})
    if(${STATIC_LINKING})
        set(link_flags "-static-libgcc -static -lcrypto")
    else()
        set(link_flags "-lcrypto")
    endif()
    target_link_libraries(${name} "${name}.cake" ${link_flags})
endfunction()

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

if(IS_CAMKES_AM)
    add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/camkes_apps/server)
elseif(IS_VM_USERAM)
    add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/camkes_apps/client)
else()
    file(GLOB appdirs apps/*)
    foreach(appdir ${appdirs})
        if(EXISTS "${appdir}/CMakeLists.txt")
            add_subdirectory(${appdir})
        endif()
    endforeach()

    get_real_file("./build/CMakeLists.txt" temp)
    if (EXISTS ${temp})
    add_subdirectory("build")
    endif()
endif()
