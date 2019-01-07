// This is not a replacement for basis_ffi.c, rather than extension. When
// building, simply compile this file like normal, and then link the object file
// with basis_ffi.o and your CakeML object file.

#include <assert.h>
#include "sha512.h"

void ffisha512(unsigned char * c, long clen, unsigned char * a, long alen) {
    // sha512 hash length = 512 bits = 64 bytes
    assert(alen >= 64);
    sha512(c, clen, a);
}
