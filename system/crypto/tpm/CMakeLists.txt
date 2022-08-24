include(ExternalProject)
include(CMakePrintHelpers)

ExternalProject_Add(tpm-tss
    GIT_REPOSITORY https://github.com/ku-sldg/am-tpm/
    GIT_TAG origin/main
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
        ${tpm_path}/tssauth20.h
        ${tpm_path}/powerup.h
        ${tpm_path}/startup.h 
        ${tpm_path}/createprimary.h 
        ${tpm_path}/create.h
        ${tpm_path}/load.h
        ${tpm_path}/sign.h
        ${tpm_path}/flushcontext.h
        ${tpm_path}/verifysignature.h
        ${tpm_path}/objecttemplates.h)
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
        ${tpm_path}/efilib.c
        ${tpm_path}/powerup.c
        ${tpm_path}/startup.c 
        ${tpm_path}/createprimary.c 
        ${tpm_path}/create.c 
        ${tpm_path}/load.c 
        ${tpm_path}/sign.c
        ${tpm_path}/flushcontext.c 
        ${tpm_path}/verifysignature.c 
        ${tpm_path}/objecttemplates.c)
    set_source_files_properties(${tss_headers} PROPERTIES GENERATED True)
    set_source_files_properties(${tss_files} PROPERTIES GENERATED True)
    set_source_files_properties(${tss_util_files} PROPERTIES GENERATED True)
    target_sources(${target} PRIVATE ${tss_headers} ${tss_files} ${tss_util_files})
    add_compile_definitions(TPM_POSIX TPM_TPM20)
    # add_library(ibmtss ${tss_headers} ${tss_files})
    # add_library(ibmtssutils ${tss_headers} ${tss_util_files})
    target_include_directories(${target} BEFORE PRIVATE ${tpm_path})
    target_sources(${target} PRIVATE ${tss_headers} ${tss_files} ${tss_util_files})
    add_dependencies(${target} tpm-tss)
endfunction()
