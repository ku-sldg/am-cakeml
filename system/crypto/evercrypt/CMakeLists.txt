include(hacl.cmake)

# Small standalone executable to generate keys for Ed25519
add_executable(keyGen EXCLUDE_FROM_ALL key_gen.c)
add_hacl(keyGen)
