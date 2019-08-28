set(PRIVATE_KEY_MODULUS 0xF5AB9DD3 CACHE STRING "Private key modulus")
set(PRIVATE_KEY_EXPONENT 0x21EF175D CACHE STRING "Private key exponent")

add_executable(genKeys EXCLUDE_FROM_ALL
    sig/rsa/genKeys.c sig/rsa/rsa.c sig/rsa/rsaInterface.c sig/rsa/utils.c)
target_link_libraries(genKeys m)

set(goodOS ((${TARGET_OS} STREQUAL "linux") OR (${TARGET_OS} STREQUAL "macOS") OR (${TARGET_OS} STREQUAL "seL4")))
if (NOT goodOS)
    message(FATAL_ERROR "TARGET_OS must be set to \"linux\", \"macOS\", or \"seL4\".")
endif()

add_library(crypto STATIC
    aes256.c crypto_ffi.c sys/${TARGET_OS}/crypto_ffi.c sha512.c sig/sig.c
    sig/rsa/rsa.c sig/rsa/rsaInterface.c sig/rsa/utils.c sig/sha512/hasher.c
    sig/sha512/toBinary.c)
target_link_libraries(crypto m)
add_definitions(
    -DPRIVATE_KEY_MODULUS=${PRIVATE_KEY_MODULUS}
    -DPRIVATE_KEY_EXPONENT=${PRIVATE_KEY_EXPONENT}
)
