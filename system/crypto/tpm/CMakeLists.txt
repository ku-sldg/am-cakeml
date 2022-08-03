include(ExternalProject)
include(CMakePrintHelpers)

ExternalProject_Add(tpm-tss
    GIT_REPOSITORY https://github.com/ku-sldg/am-tpm/
    GIT_TAG origin/master
    GIT_PROGRESS True
    SOURCE_DIR ${CMAKE_BINARY_DIR}/tpm-tss
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
)

set(tpm_release_dir "${CMAKE_BINARY_DIR}/tpm-tss")
set(tpm_path "${tpm_release_dir}/am-utils")

function(add_tpm target)
    set(tpm_release_dir "${CMAKE_BINARY_DIR}/tpm-tss")
    set(tpm_path "${tpm_release_dir}/am-utils")
    set(tss_headers
        ${tpm_path}/tssauth.h
        ${tpm_path}/tssccattributes.h
        ${tpm_path}/tssdev.h
        ${tpm_path}/tsssocket.h
        ${tpm_path}/ibmtss/tss.h
        ${tpm_path}/ibmtss/tsscryptoh.h
        ${tpm_path}/ibmtss/tsscrypto.h
        ${tpm_path}/ibmtss/tsserror.h
        ${tpm_path}/ibmtss/tssfile.h
        ${tpm_path}/ibmtss/tssmarshal.h
        ${tpm_path}/ibmtss/tssprint.h
        ${tpm_path}/ibmtss/tssprintcmd.h
        ${tpm_path}/tssproperties.h
        ${tpm_path}/ibmtss/tsstransmit.h
        ${tpm_path}/ibmtss/tssresponseecode.h
        ${tpm_path}/ibmtss/tssutils.h
        ${tpm_path}/ibmtss/Unmarshal_fp.h
        ${tpm_path}/ibmtss/Implementation.h
        ${tpm_path}/tss20.h
        ${tpm_path}/tssauth20.h)
    set(tss_files
        ${tpm_path}/tssfile.c
        ${tpm_path}/tsscryptoh.c
        ${tpm_path}/tsscrypto.c
        ${tpm_path}/tssprintcmd.c
        ${tpm_path}/tss.c
        ${tpm_path}/tssproperties.c
        ${tpm_path}/tssmarshal.c
        ${tpm_path}/tssauth.c
        ${tpm_path}/tssutils.c
        ${tpm_path}/tsssocket.c
        ${tpm_path}/tssdev.c
        ${tpm_path}/tsstransmit.c
        ${tpm_path}/tssresponsecode.c
        ${tpm_path}/tssccattributes.c
        ${tpm_path}/tssprint.c
        ${tpm_path}/Unmarshal.c
        ${tpm_path}/CommandAttributeData.c
        ${tpm_path}/tss20.c
        ${tpm_path}/tssauth20.c
        ${tpm_path}/Commands.c
        ${tpm_path}/ntc2lib.c
        ${tpm_path}/tssntc.c)
    set(tss_util_files
        ${tpm_path}/cryptoutils.c
        ${tpm_path}/ekutils.c
        ${tpm_path}/imalib.c
        ${tpm_path}/eventlib.c
        ${tpm_path}/efilib.c)
    set_source_files_properties(${tss_headers} PROPERTIES GENERATED True)
    set_source_files_properties(${tss_files} PROPERTIES GENERATED True)
    set_source_files_properties(${tss_util_files} PROPERTIES GENERATED True)
    target_sources(${target} PRIVATE ${tss_headers} ${tss_files} ${tss_util_files})
    add_compile_definitions(-DTPM_POSIX)
    add_compile_options(-Wl,-z,now)
    add_compile_options(-Wl,-rpath,${tpm_path})
    add_compile_options(-L${tpm_path} -libmtss -libmtssutils)
    target_include_directories(${target} BEFORE PRIVATE ${tpm_path})
    add_dependencies(${target} tpm-tss)
endfunction()
