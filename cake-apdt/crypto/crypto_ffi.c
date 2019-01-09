// This is not a replacement for basis_ffi.c, rather than extension. When
// building, simply compile this file like normal, and then link the object file
// with basis_ffi.o and your CakeML object file.

#include <assert.h>
#include <sys/random.h>
#include "sha512.h"

void ffisha512(unsigned char * c, long clen, unsigned char * a, long alen) {
    // sha512 hash length = 512 bits = 64 bytes
    assert(alen >= 64);
    sha512(c, clen, a);
}

void ffinonce(unsigned char * c, long clen, unsigned char * a, long alen) {
    // This performs a syscall, drawing entropy from "urandom" (aka /dev/urandom) 
    // http://man7.org/linux/man-pages/man2/getrandom.2.html
    getrandom(a, alen, 0);
}
