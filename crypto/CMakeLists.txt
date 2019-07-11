add_executable(genKeys
    sig/rsa/genKeys.c sig/rsa/rsa.c sig/rsa/rsaInterface.c sig/rsa/utils.c)
target_link_libraries(genKeys m)
add_custom_target(runGenKeys
    COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/sig/rsa/primes.txt ${CMAKE_CURRENT_BINARY_DIR}
    COMMAND ./genKeys
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/sig/rsa/primes.txt genKeys
)   

add_library(crypto STATIC
    aes256.c crypto_ffi.c sha512.c sig/sig.c sig/rsa/rsa.c
    sig/rsa/rsaInterface.c sig/rsa/utils.c sig/sha512/hasher.c
    sig/sha512/toBinary.c)
target_link_libraries(crypto m)
add_dependencies(crypto runGenKeys)
add_definitions(-DPRIVATE_KEY_FILE="${CMAKE_CURRENT_BINARY_DIR}/working/myPrivateKey.txt")
