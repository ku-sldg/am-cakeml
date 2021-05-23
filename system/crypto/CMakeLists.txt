include(ExternalProject)

# OS-specific configuration
if(${CAmkES})
    set(sys "CAmkES")
    set(cryptoLinks "muslc")
else()
    if(${target_os_lower} STREQUAL "linux")
        set(sys "linux")
    elseif(${target_os_lower} STREQUAL "macos")
        set(sys "macOS")
    endif()
    # set(cryptoLinks "m")
endif()

#set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DDEBUGPRINT")

# Fetch hacl-star v0.2.1
# ExternalProject_Add(hacl-star
#     URL https://github.com/project-everest/hacl-star/releases/download/v0.2.1/hacl-star-v0.2.1.tar.bz2
#     SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/hacl-star
#     CONFIGURE_COMMAND ""
#     BUILD_COMMAND ""
#     INSTALL_COMMAND ""
# )
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

# Config by arch
if("${target_arch_lower}" STREQUAL "native")
    include(HaclConfig.cmake)
    add_definitions(${comp_defns})
elseif("${target_arch_lower}" STREQUAL "armv7")
    # Make sure whole-project is hard-float
    add_definitions(-DIS_ARM_7 -DBROKEN_INTRINSICS IS_NOT_X64 -DKRML_VERIFIED_UINT128)
    add_definitions(-DLib_IntVector_Intrinsics_vec256="void *")
elseif("${target_arch_lower}" STREQUAL "other")
    message(WARNING "TARGET_ARCH value \"other\" implies cross-compilation to an unspecified target. The relevant CMake variables will need to be configured manually.")
endif()

# set(hacl_sources ${hacl_path}/Hacl_Hash.c ${hacl_path}/Hacl_Ed25519.c ${hacl_path}/Hacl_Curve25519_51.c)
set(hacl_sources ${hacl_path}/Hacl_Hash.c ${hacl_path}/Hacl_Ed25519.c ${hacl_path}/Hacl_Curve25519_51.c ${hacl_path}/Hacl_Chacha20_Vec32.c ${hacl_path}/Hacl_Chacha20.c)
set_source_files_properties(${hacl_sources} PROPERTIES GENERATED True)

# Crypto library
# TODO: separate meas from crypto, or make meas optional
add_library(crypto STATIC crypto_ffi.c meas.c sys/${sys}/crypto_ffi.c ${hacl_sources})
include_directories(BEFORE ${hacl_path} ${kremlin_path} ${kremlib_path})
target_link_libraries(crypto ${cryptoLinks})
add_dependencies(crypto hacl-star)


# Small standalone executable to generate keys for Ed25519
add_executable(keyGen EXCLUDE_FROM_ALL
    key_gen.c sys/${sys}/crypto_ffi.c
    ${hacl_path}/Hacl_Hash.c ${hacl_path}/Hacl_Ed25519.c ${hacl_path}/Hacl_Curve25519_51.c
)
add_dependencies(keyGen hacl-star)
