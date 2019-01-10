// This is not a replacement for basis_ffi.c, rather than extension. When
// building, simply compile this file like normal, and then link the object file
// with basis_ffi.o and your CakeML object file.

#include <assert.h>
#include <sys/random.h>
#include "sha512.h"
#include "aes256.h"

void ffisha512(unsigned char * c, long clen, unsigned char * a, long alen) {
    // sha512 hash length = 512 bits = 64 bytes
    assert(alen >= 64);
    sha512(c, clen, a);
}

// This may block right after a fresh boot until the entropy pool is
// sufficiently large
void ffiurand(unsigned char * c, long clen, unsigned char * a, long alen) {
    // This performs a syscall, drawing entropy from "urandom" (aka /dev/urandom)
    // http://man7.org/linux/man-pages/man2/getrandom.2.html
    ssize_t len = getrandom(a, alen, 0);

    // For now, we will assert that we must get as many bytes as we asked for.
    // In the future, we may wish to recover from such an error rather than
    // purposefully crashing.
    assert(len == alen);
}

// c <- key, returns xkey in a
void ffiaes256_expand_key(unsigned char * c, long clen, unsigned char * a, long alen) {
    assert(clen >= 32);
    assert(alen >= 240);
    aes256_expand_key(c, a);
}

// c[0..15] <- message block, c[16..254] <- xkey
void ffiaes256(unsigned char * c, long clen, unsigned char * a, long alen) {
    assert(clen >= 255);
    assert(alen >= 16);
    aes256_block_enc(c, (c+16), a);
}
