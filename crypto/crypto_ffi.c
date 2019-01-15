// FFI interface to our verified crypto algorithms. Note, this file does not
// replace basis_ffi.c. Both files need to be linked against the compiled
// CakeML code.

#include <assert.h>   // asserts
#include <stdint.h>   // uint8_t and uint32_t types

#ifdef __linux__
    // getRandom()
    #include <sys/random.h>
#elif __APPLE__
    // open, read, close:
    #include <sys/types.h>
    #include <sys/uio.h>
    #include <fcntl.h>
    #include <unistd.h>
#endif

#include "sha512.h"
#include "aes256.h"

// c <- message, returns hash in a
void ffisha512(uint8_t * c, long clen, uint8_t * a, long alen) {
    // sha512 hash length = 512 bits = 64 bytes
    assert(alen >= 64);
    sha512(c, clen, a);
}

#ifdef __linux__
// This may block right after a fresh boot until the entropy pool is
// sufficiently large
void ffiurand(uint8_t * c, long clen, uint8_t * a, long alen) {
    // This performs a syscall, drawing entropy from "urandom" (aka /dev/urandom)
    // http://man7.org/linux/man-pages/man2/getrandom.2.html
    ssize_t len = getrandom(a, alen, 0);

    // For now, we will assert that we must get as many bytes as we asked for.
    // In the future, we may wish to recover from such an error rather than
    // purposefully crashing.
    assert(len == alen);
}

#elif __APPLE__
void ffiurand(uint8_t * c, long clen, uint8_t * a, long alen) {
    // On macOS, /dev/random and /dev/urandom are synonymous, with urandom only
    // existing for linux compatibility
    int fd = open("/dev/random", O_RDONLY);
    assert(fd != -1);
    size_t len = read(fd, a, alen);
    assert(len == alen);
    close(fd);
}

#else
void ffiurand(uint8_t * c, long clen, uint8_t * a, long alen) {
    assert(!"No support at the moment for this OS");
}
#endif

// Helper functions for copying between byte and 32-bit word arrays, and vice versa.
// (casting and memcpy both result in unexpected ordering due to endianness)
void cpyBytesToWords(uint8_t * bytes, uint32_t * words, int numWords){
  for (int i = 0; i < numWords; i++){
    words[i]  = ((uint32_t)bytes[4*i])   << 24;
    words[i] |= ((uint32_t)bytes[4*i+1]) << 16;
    words[i] |= ((uint32_t)bytes[4*i+2]) << 8;
    words[i] |=  (uint32_t)bytes[4*i+3];
  }
}
void cpyWordsToBytes(uint32_t * words, uint8_t * bytes, int numWords){
  for (int i = 0; i < numWords; i++){
    bytes[4*i]   = (uint8_t)( words[i] >> 24);
    bytes[4*i+1] = (uint8_t)((words[i] >> 16) & 0xFF);
    bytes[4*i+2] = (uint8_t)((words[i] >>  8) & 0xFF);
    bytes[4*i+3] = (uint8_t)((words[i]) & 0xFF);
  }
}

// c <- key, returns xkey in a
void ffiaes256_expand_key(uint8_t * c, long clen, uint8_t * a, long alen) {
    assert(clen >= 32);
    assert(alen >= 240);

    uint32_t key[8];
    cpyBytesToWords(c, key, 8);

    uint32_t xkey[60];
    aes256_expand_key(key, xkey);
    cpyWordsToBytes(xkey, a, 60);
}

// c[0..15] <- message block, c[16..254] <- xkey
void ffiaes256(uint8_t * c, long clen, uint8_t * a, long alen) {
    assert(clen >= 255);
    assert(alen >= 16);

    uint32_t pt[4];
    cpyBytesToWords(c, pt, 4);

    uint32_t xkey[60];
    // FYI, (c+16) == &c[16]    (or if you like esoteric code, &16[c])
    cpyBytesToWords(c+16, xkey, 60);

    uint32_t ct[4];
    aes256_block_enc(pt, xkey, ct);
    cpyWordsToBytes(ct, a, 4);
}
