add_executable(genKeys EXCLUDE_FROM_ALL
    sig/rsa/genKeys.c sig/rsa/rsa.c sig/rsa/rsaInterface.c sig/rsa/utils.c)
target_link_libraries(genKeys m)

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
    set(cryptoLinks "m")
endif()

add_library(crypto STATIC
    aes256.c crypto_ffi.c sys/${sys}/crypto_ffi.c sha512.c idstring.c sig/sig.c
    sig/rsa/rsa.c sig/rsa/rsaInterface.c sig/rsa/utils.c sig/sha512/hasher.c
    sig/sha512/toBinary.c)
target_link_libraries(crypto ${cryptoLinks})


set(PRIVATE_KEY_MODULUS 0xF5AB9DD3 CACHE STRING "Private key modulus")
set(PRIVATE_KEY_EXPONENT 0x21EF175D CACHE STRING "Private key exponent")
add_definitions(
    -DPRIVATE_KEY_MODULUS=${PRIVATE_KEY_MODULUS}
    -DPRIVATE_KEY_EXPONENT=${PRIVATE_KEY_EXPONENT}
)
