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
    else()
        message(FATAL_ERROR "File ${file} does not exist.")
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

get_files(util_src util/Extra.sml
    util/ByteString.sml util/Misc.sml util/Parser.sml util/Json.sml
    util/BinaryParser.sml util/Http.sml)

get_files(copland_am_src
    # Require Extraction Files for Types
    extracted/Datatypes.cml
    extracted/Nat.cml
    extracted/Specif.cml
    extracted/List.cml

    # Random needed stuff (likely extraction bug related)
    stubs/Preamble_Stuff.sml

    # A more faithful extraction of the Coq code following _CoqProject
    extracted/ResultT.cml
    extracted/Serializable.cml

    stubs/Serializable_Class_Admits.sml

    extracted/EqClass.cml
    extracted/ID_Type.cml

    stubs/BS.sml

    extracted/ErrorStringConstants.cml
    extracted/Maps.cml
    extracted/JSON_Type.cml

    stubs/JSON_Admits.sml

    extracted/JSON.cml
    extracted/Term_Defs_Core.cml

    stubs/Params_Admits.sml

    extracted/Term_Defs.cml
    extracted/Interface_Strings_Vars.cml
    extracted/Interface_Types.cml
    extracted/ErrorStMonad_Coq.cml

    stubs/Manifest_Admits.sml

    extracted/Manifest_Set.cml
    extracted/Manifest.cml
    extracted/Manifest_JSON_Vars.cml
    extracted/Manifest_JSON.cml
    extracted/Cvm_St.cml

    stubs/IO_Stubs.sml

    extracted/Anno_Term_Defs.cml
    extracted/CvmJson_Interfaces.cml
    extracted/Manifest_Compiler.cml
    extracted/EnvironmentM.cml
    extracted/Manifest_Union.cml

    stubs/Axioms_Io.sml

    extracted/Evidence_Bundlers.cml
    extracted/Cvm_Monad.cml
    extracted/Cvm_Impl.cml
    extracted/Cvm_Run.cml
    extracted/Manifest_Generator_Helpers.cml
    extracted/Manifest_Generator.cml
    extracted/Manifest_Generator_Union.cml
    extracted/AM_St.cml

    stubs/Appraisal_IO_Stubs.sml

    extracted/AM_Monad.cml
    extracted/Appraisal_Defs.cml
    extracted/Impl_appraisal.cml
    extracted/AM_Json_Interfaces.cml
    extracted/Server_AM.cml
    util/AM_CLI.sml
)

get_files (posix_src_cake 
    system/posix/sockets/SocketFFI.sml
    system/posix/time/TimeFFI.sml 
    system/posix/sys/SysFFI.sml
)

get_files(posix_src_c
    ${BASIS_FILE}
    system/posix/sockets/socket_ffi.c
    system/posix/time/time_ffi.c
    system/posix/sys/sys_ffi.c
)

get_files(server_am_src ${util_src} ${posix_src_cake} ${copland_am_src})


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

function(build_posix_am name)
    build_cake("${name}.cake" SOURCES "${ARGN}")
    add_executable(${name} ${posix_src_c})
    if(${STATIC_LINKING})
        set(link_flags "-static-libgcc -static")
    endif()
    target_link_libraries(${name} "${name}.cake" ${link_flags})
endfunction()

file(GLOB appdirs apps/*)
foreach(appdir ${appdirs})
    if(EXISTS "${appdir}/CMakeLists.txt")
        add_subdirectory(${appdir})
    endif()
endforeach()

# get_real_file("./build/CMakeLists.txt" temp)
if (EXISTS ${temp})
  add_subdirectory("build")
endif()
