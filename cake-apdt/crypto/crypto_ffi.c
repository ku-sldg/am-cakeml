// This is not a replacement for basis_ffi.c, rather than extension. When
// building, simply compile this file like normal, and then link the object file
// with basis_ffi.o and your CakeML object file.

#include <assert.h>
#include <sys/random.h>
// #include <bsd/stdlib.h>
#include "sha512.h"

void ffisha512(unsigned char * c, long clen, unsigned char * a, long alen) {
    // sha512 hash length = 512 bits = 64 bytes
    assert(alen >= 64);
    sha512(c, clen, a);
}


void ffinonce(unsigned char * c, long clen, unsigned char * a, long alen) {
    // This performs a syscall, drawing entropy from "urandom" (aka /dev/urandom)
    // http://man7.org/linux/man-pages/man2/getrandom.2.html
    ssize_t len = getrandom(a, alen, 0);

    // Rather than making a syscall each time, we could use something like
    // arc4random, which is a userspace prng that periodically reseeds from
    // urandom. However, this is not in libc (we would need to link against
    // libbsd), and some old versions are based on a now insecure algorithm.

    // For now, we will assert that we must get as many bytes as we asked for.
    // In the future, we may wish to recover from such an error rather than
    // purposefully crashing.
    assert(len == alen);
}
