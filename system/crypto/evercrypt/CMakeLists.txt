include(ExternalProject)

ExternalProject_Add(hacl-star
    GIT_REPOSITORY https://github.com/project-everest/hacl-star/
    # This was the most recent commit on master, at the time of integration.
    # The next release will likely support ARM cross-compilation (as this commit
    # does), and we should switch to that when it arrives.
    GIT_TAG 50db8e4147258a5dc8e18c940c1b045ce5558723
    GIT_PROGRESS True
    SOURCE_DIR ${CMAKE_BINARY_DIR}/hacl-star
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
)

set(hacl_release_dir "${CMAKE_BINARY_DIR}/hacl-star/dist")
set(hacl_path    "${hacl_release_dir}/gcc-compatible")
set(kremlin_path "${hacl_release_dir}/kremlin/include")
set(kremlib_path "${hacl_release_dir}/kremlin/kremlib/dist/minimal")

# Config by arch
if("${target_arch_lower}" STREQUAL "native")
    include(HaclConfig.cmake)
    add_definitions(${comp_defns})
# If building for arm, you'll want to add the c flags "-mfpu=neon" and "-mfloat-abi=hard"
elseif("${target_arch_lower}" STREQUAL "armv7")
    add_definitions(-DIS_ARM_7 -DBROKEN_INTRINSICS -DIS_NOT_X64 -DKRML_VERIFIED_UINT128)
    add_definitions(-DLib_IntVector_Intrinsics_vec256="void *")
elseif("${target_arch_lower}" STREQUAL "armv8")
    add_definitions(-DIS_ARM_8 -DBROKEN_INTRINSICS -DIS_NOT_X64 -DKRML_VERIFIED_UINT128)
    add_definitions(-DLib_IntVector_Intrinsics_vec256="void *")
elseif("${target_arch_lower}" STREQUAL "armv8")
    # TODO: get arm8 values
    add_definitions(-DIS_ARM_7 -DBROKEN_INTRINSICS IS_NOT_X64 -DKRML_VERIFIED_UINT128)
    add_definitions(-DLib_IntVector_Intrinsics_vec256="void *")
elseif("${target_arch_lower}" STREQUAL "other")
    message(WARNING "TARGET_ARCH value \"other\" implies cross-compilation to an unspecified target. The relevant CMake variables will need to be configured manually.")
endif()

set(hacl_sources ${hacl_path}/Hacl_Hash.c ${hacl_path}/Hacl_Ed25519.c ${hacl_path}/Hacl_Curve25519_51.c ${hacl_path}/Hacl_Chacha20_Vec32.c ${hacl_path}/Hacl_Chacha20.c)
set_source_files_properties(${hacl_sources} PROPERTIES GENERATED True)

function(add_hacl target)
    # For some reason these are not in scope unless defined in the function
    set(hacl_release_dir "${CMAKE_BINARY_DIR}/hacl-star/dist") # Better way to reference crypto binary dir?
    set(hacl_path    "${hacl_release_dir}/gcc-compatible")
    set(kremlin_path "${hacl_release_dir}/kremlin/include")
    set(kremlib_path "${hacl_release_dir}/kremlin/kremlib/dist/minimal")
    set(hacl_sources ${hacl_path}/Hacl_Hash.c ${hacl_path}/Hacl_Ed25519.c ${hacl_path}/Hacl_Curve25519_51.c ${hacl_path}/Hacl_Chacha20_Vec32.c ${hacl_path}/Hacl_Chacha20.c)
    set_source_files_properties(${hacl_sources} PROPERTIES GENERATED True)

    target_include_directories(${target} BEFORE PRIVATE ${hacl_path} ${kremlin_path} ${kremlib_path})
    target_sources(${target} PRIVATE ${hacl_sources})
    add_dependencies(${target} hacl-star)
endfunction()

function(add_hacl_camkes component)
    # For some reason these are not in scope unless defined in the function
    set(hacl_release_dir "${CMAKE_BINARY_DIR}/hacl-star/dist") # Better way to reference crypto binary dir?
    set(hacl_path    "${hacl_release_dir}/gcc-compatible")
    set(kremlin_path "${hacl_release_dir}/kremlin/include")
    set(kremlib_path "${hacl_release_dir}/kremlin/kremlib/dist/minimal")
    set(hacl_sources ${hacl_path}/Hacl_Hash.c ${hacl_path}/Hacl_Ed25519.c ${hacl_path}/Hacl_Curve25519_51.c ${hacl_path}/Hacl_Chacha20_Vec32.c ${hacl_path}/Hacl_Chacha20.c)
    # set_source_files_properties(${hacl_sources} PROPERTIES GENERATED True)
    # set_source_files_properties(${hacl_sources} TARGET_DIRECTORY CAmkESComponent_${component} PROPERTIES GENERATED True)
    set_source_files_properties(${hacl_sources} DIRECTORY ${CMAKE_SOURCE_DIR} PROPERTIES GENERATED True)
    # foreach(file ${hacl_sources})
    #     add_dependencies(${file} hacl-source)
    # endforeach()
    add_custom_command(OUTPUT ${hacl_sources} COMMAND "" DEPENDS hacl-star)

    # One can call DeclareCAmkESComponent multiple times to add information
    DeclareCAmkESComponent(
        ${component}
        SOURCES ${hacl_sources}
        INCLUDES ${hacl_path} ${kremlin_path} ${kremlib_path}
        # DEPENDS hacl-star
    )
    # target_sources(CAmkESComponent_${component} ${hacl_sources})
    # add_dependencies(CAmkESComponent_${component} hacl-star)
endfunction()

# Small standalone executable to generate keys for Ed25519
add_executable(keyGen EXCLUDE_FROM_ALL key_gen.c)
add_hacl(keyGen)
