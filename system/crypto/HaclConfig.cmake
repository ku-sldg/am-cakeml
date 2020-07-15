# This file is based on the HACL* configuration shell script
# https://github.com/project-everest/hacl-star/blob/50db8e4147258a5dc8e18c940c1b045ce5558723/dist/configure

# Variable definitions
set(blacklist "") # Only used to double-check ourselves
# set(hacl_release_dir "${CMAKE_CURRENT_BINARY_DIR}/hacl-star/dist")
# set(hacl_path    "${hacl_release_dir}/gcc-compatible")
# set(kremlin_path "${hacl_release_dir}/kremlin/include")
# set(kremlib_path "${hacl_release_dir}/kremlin/kremlib/dist/minimal")
set(comp_defns "")

# function(try_cc source)
#     cmake_parse_arguments(
#         PARSE_ARGV
#         1
#         PARSED_ARGS
#         ""
#         "SOURCE"
#         "C_FLAGS"
#         "INCLUDE_DIRECTORIES"
#         "RESULT_VARIABLE"
#         "OUTPUT_VARIABLE"
#     )
#     if(NOT "${PARSED_ARGS_UNPARSED_ARGUMENTS}" STREQUAL "")
#         message(FATAL_ERROR "Unknown arguments to try_cc: ${PARSED_ARGS_UNPARSED_ARGUMENTS}")
#     endif()
#     set(incl "")
#     foreach(i ${PARSED_ARGS_INCLUDE_DIRECTORIES})
#         set(incl "${incl} -I${i}")
#     endforeach()
#
#     add_custom_command(${source}_try_cc_stamp
#         COMMAND ${CMAKE_C_COMPILER} ${incl} ${PARSED_ARGS_C_FLAGS} ${source}
#     )
# endfunction()

function(check_no_bug81300)
    set(CMAKE_C_FLAGS "-march=native -O3 -I${hacl_path} -I${kremlin_path} -I${kremlib_path}")
    try_compile(result_test "${CMAKE_CURRENT_BINARY_DIR}/check_no_bug81300"
        SOURCES "${CMAKE_CURRENT_LIST_DIR}/hacl_tests/testbug81300.c"
        OUTPUT_VARIABLE output_test
    )
    set(CMAKE_C_FLAGS "-DBROKEN_INTRINSICS -march=native -O3 -I${hacl_path} -I${kremlin_path} -I${kremlib_path}")
    try_compile(result_ref "${CMAKE_CURRENT_BINARY_DIR}/check_no_bug81300"
        SOURCES "${CMAKE_CURRENT_LIST_DIR}/hacl_tests/testbug81300.c"
        OUTPUT_VARIABLE output_ref
    )
    # message(STATUS ${output_test})
    # message(STATUS ${output_ref})
    # string(COMPARE EQUAL ${output_test} ${output_ref} return)
    string(COMPARE EQUAL ${result_test} ${result_ref} return)
    set(check_no_bug81300 ${return} PARENT_SCOPE)
endfunction()

function(detect_uint128)
    try_compile(return "${CMAKE_CURRENT_BINARY_DIR}/detect_uint128"
        SOURCES ${CMAKE_CURRENT_LIST_DIR}/hacl_tests/testint128.c
    )
    set(detect_uint128 ${return} PARENT_SCOPE)
endfunction()

function(detect_arm)
    string(REGEX MATCH "(arm(.*))|(aarch64(.*))" return ${CMAKE_HOST_SYSTEM_PROCESSOR})
    set(detect_arm ${return} PARENT_SCOPE)
endfunction()

function(detect_arm_cc)
    try_compile(return "${CMAKE_CURRENT_BINARY_DIR}/detect_arm_cc"
        SOURCES ${CMAKE_CURRENT_LIST_DIR}/hacl_tests/testvec128.c
        CMAKE_FLAGS -DINCLUDE_DIRECTORIES:STRING="${hacl_path}"
                    -DCMAKE_C_FLAGS:STRING="-march=armv8-a+simd"
    )
    set(detect_arm_cc ${return} PARENT_SCOPE)
endfunction()

function(check_explicit_bzero)
    try_compile(return "${CMAKE_CURRENT_BINARY_DIR}/check_explicit_bzero"
        SOURCES ${CMAKE_CURRENT_LIST_DIR}/hacl_tests/testbzero.c
        CMAKE_FLAGS -DCMAKE_C_FLAGS:STRING="-Werror"
    )
    set(check_explicit_bzero ${return} PARENT_SCOPE)
endfunction()

detect_arm()
if(${detect_arm})
    message(STATUS "HACL* Config: Detected ARM platform")
    message(STATUS "HACL* Config: ${CMAKE_HOST_SYSTEM_PROCESSOR} does not support 256-bit arithmetic")
    file(GLOB 256-bit_arith "${hacl_path}/*CP256*.c" "${hacl_path}/*_256.c" "${hacl_path}/*_Vec256.c")
    list(APPEND blacklist ${256-bit_arith})
    message(STATUS "HACL* Config: ${CMAKE_HOST_SYSTEM_PROCESSOR} does not support legacy vale stubs")
    list(APPEND blacklist "${hacl_path}/evercrypt_vale_stubs.c")
    # add_compile_definitions(Lib_IntVector_Intrinsics_vec256="void *")
    list(APPEND comp_defns "Lib_IntVector_Intrinsics_vec256=\"void *\"")
    detect_arm_cc()
    if(${detect_arm_cc})
        message(STATUS "HACL* Config: ${CMAKE_C_COMPILER} can cross-compile to ARM64 with SIMD")
        set(CFLAGS_128 "-march=armv8-a+simd") #TODO: Do something with this
        # add_compile_definitions(IS_ARM_8)
        list(APPEND comp_defns "IS_ARM_8")
    else()
        message(STATUS "HACL* Config: ${CMAKE_C_COMPILER} cannot compile 128-bit vector arithmetic, disabling")
        file(GLOB 128-bit_arith "${hacl_path}/*CP128*.c" "${hacl_path}/*_128.c" "${hacl_path}/*_Vec128.c")
        list(APPEND blacklist ${128-bit_arith})
    endif()
endif()

if(NOT (${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL "x86_64"))
    message(STATUS "HACL* Config: ${CMAKE_HOST_SYSTEM_PROCESSOR} does not support x64 assembly, disabling Curve64")
    file(GLOB curve64 "${hacl_path}/Hacl_HPKE_Curve64_*.c")
    list(APPEND blacklist ${curve64})
    message(STATUS "HACL* Config: ${CMAKE_HOST_SYSTEM_PROCESSOR} does not support _addcarry_u64, using a C implementation")
    # add_compile_definitions(BROKEN_INTRINSICS IS_NOT_X64)
    list(APPEND comp_defns "BROKEN_INTRINSICS IS_NOT_X64")
else()
    if((${CMAKE_C_COMPILER_ID} STREQUAL "Clang") AND (${CMAKE_C_COMPILER_VERSION} STREQUAL "1000.11.45.5"))
        message(STATUS "HACL* Config: Found broken XCode version, known to refuse to compile our inline ASM, disabling")
        # add_compile_definitions(BROKEN_INLINE_ASM)
        list(APPEND comp_defns "BROKEN_INLINE_ASM")
    endif()
    check_no_bug81300()
    if(NOT ${check_no_bug81300})
        message(STATUS "HACL* Config: Found broken GCC < 5.5 with bug 81300, disabling subborrow + addcarry")
        # add_compile_definitions(BROKEN_INTRINSICS)
        list(APPEND comp_defns "BROKEN_INTRINSICS")
    endif()
endif()

detect_uint128()
if(NOT ${detect_uint128})
    message(STATUS "HACL* Config: ${CMAKE_C_COMPILER} does not support unsigned __int128 -- using a fallback verified implementation")
    # add_compile_definitions(KRML_VERIFIED_UINT128)
    list(APPEND comp_defns "KRML_VERIFIED_UINT128")
endif()

if(${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Linux")
    check_explicit_bzero()
    if(NOT ${check_explicit_bzero})
        message(STATUS "HACL* Config: Toolchain does not support explicit_bzero")
        # add_compile_definitions(LINUX_NO_EXPLICIT_BZERO)
        list(APPEND comp_defns "LINUX_NO_EXPLICIT_BZERO")
    endif()
endif()
