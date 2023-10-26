# This file handles gathering all the source files for the AM.
# It defines a couple functions for internal use,
# and then it sets variables corresponding to sets of files.

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

get_files(cop_src_pre_aspStubs
    stubs/BS.sml
    stubs/StringT.sml
    extracted/Specif.cml
    extracted/Datatypes.cml
    extracted/EqClass.cml
    extracted/List.cml
    stubs/AbstractedTypes.sml
    extracted/Term_Defs_Core.cml
    extracted/Eqb_Evidence.cml
    stubs/Params_Admits_hardcoded.sml
    extracted/Term_Defs.cml
    extracted/Maps.cml
    stubs/Maps.sml
    stubs/Manifest_Admits_Stubs.sml
    extracted/ErrorStMonad_Coq.cml
    stubs/Example_Phrases_Admits.sml
    extracted/Manifest_Set.cml
    extracted/Manifest.cml
    extracted/Manifest_Compiler.cml
    extracted/EnvironmentM.cml
    extracted/Manifest_Union.cml
    copland/CoplandUtil.sml
    stubs/Example_Phrases_Demo_Admits.sml
    extracted/Example_Phrases.cml
    extracted/Example_Phrases_Demo.cml
    stubs/IO_Stubs_extra.sml
    am/CommTypes.sml
    copland/json/CoplandToJson.sml
    copland/json/JsonToCopland.sml
    extracted/Manifest_Generator_Helpers.cml
    extracted/Manifest_Generator.cml
    extracted/Manifest_Generator_Union.cml
    copland/json/ManifestJsonConfig.sml
    util/ManifestUtils.sml
)

get_files(cop_src_post_aspStubs
    stubs/CvmJson_Admits.sml
    stubs/ErrorStringConstants.sml
    extracted/Cvm_St.cml
    extracted/AM_St.cml
    stubs/Appraisal_IO_Stubs.sml
    stubs/Axioms_Io.sml
    extracted/StMonad_Coq.cml
    stubs/Cvm_St_Utils.sml
    extracted/AM_Monad.cml
    extracted/Appraisal_Defs.cml
    extracted/Evidence_Bundlers.cml
    am/CoplandCommUtil.sml
    stubs/IO_Stubs.sml
    extracted/Cvm_Monad.cml
    extracted/Cvm_Impl.cml
    extracted/Cvm_Run.cml
    extracted/Impl_appraisal.cml
    extracted/AM_Helpers.cml
    extracted/Client_AM_Local.cml
    extracted/Server_AM.cml
)

get_files(cop_src
    ${cop_src_pre_aspStubs}
    ${attestation_asps}
    ${appraisal_asps}
    ${cop_src_post_aspStubs}
)

get_files(cop_src_noasps
    ${cop_src_pre_aspStubs}
    ${cop_src_post_aspStubs}
)

get_files(server_am_src_noasps ${util_src} ${posix_src_cake} ${cop_src_noasps})

get_files(server_am_src ${util_src} ${posix_src} ${cop_src})
get_files(server_am_src_hacl ${util_src} ${posix_src_hacl} ${cop_src})
get_files(server_am_src_tpm ${util_src} ${posix_src_tpm} ${cop_src})

get_files(posix_c_files_base
    system/posix/sockets/socket_ffi.c
    system/posix/time/time_ffi.c
    system/posix/meas/meas_ffi.c
    system/posix/sys/sys_ffi.c
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

