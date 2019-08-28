// FFI interface to our verified crypto algorithms.

#include <assert.h> // asserts
#include <stdint.h> // uint8_t and uint32_t types

#include "sha512.h"
#include "aes256.h"
#include "sig/sig.h"

#define FFI_SUCCESS 0
#define FFI_FAILURE 1

// Arguments: message to be hashed in c
// Returns: hash in a
void ffisha512(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    assert(alen >= 64);
    sha512(c, clen, a);
}

void ffisignMsg(const uint8_t * msg, const long msgLen, uint8_t * signature, const long sigLen) {
    // Prevents complaint about unused arguments
    (void)msgLen;

    assert (sigLen >= 256);
    unsigned long long mySig[64];
    signMsg((char *)msg, mySig);
    sigToByteString(mySig, signature);
}

// Give payload in form:
// first 64 bytes: sig
// null byte
// 64 bytes: file hash
// null byte
// Public Key
void ffisigCheck(const uint8_t * payload, const long payloadLen, uint8_t * a, const long aLen ) {
    // Prevents complaint about unused arguments
    (void)payloadLen; (void)aLen;

    assert(aLen >= 1);

    // check the signature
    if(sigCheck(payload))
        a[0] = FFI_SUCCESS;
    else
        a[0] = FFI_FAILURE;
}

// Helper functions for copying between byte and 32-bit word arrays, and vice versa.
// (casting and memcpy both result in unexpected ordering due to endianness)
void cpyBytesToWords(const uint8_t * bytes, uint32_t * words, const int numWords){
    for (int i = 0; i < numWords; i++){
        words[i]  = ((uint32_t)bytes[4*i])   << 24;
        words[i] |= ((uint32_t)bytes[4*i+1]) << 16;
        words[i] |= ((uint32_t)bytes[4*i+2]) << 8;
        words[i] |=  (uint32_t)bytes[4*i+3];
    }
}
void cpyWordsToBytes(const uint32_t * words, uint8_t * bytes, const int numWords){
    for (int i = 0; i < numWords; i++){
        bytes[4*i]   = (uint8_t)( words[i] >> 24);
        bytes[4*i+1] = (uint8_t)((words[i] >> 16) & 0xFF);
        bytes[4*i+2] = (uint8_t)((words[i] >>  8) & 0xFF);
        bytes[4*i+3] = (uint8_t)((words[i]) & 0xFF);
    }
}

// Arguments: key in c
// Returns: xkey in a
void ffiaes256_expand_key(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    assert(clen >= 32);
    assert(alen >= 240);

    uint32_t key[8];
    cpyBytesToWords(c, key, 8);

    uint32_t xkey[60];
    aes256_expand_key(key, xkey);
    cpyWordsToBytes(xkey, a, 60);
}

// Arguments: message block in first 16 blocks of c, xkey in the next 240
// Returns: ciphertext in a
void ffiaes256(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    assert(clen >= 255);
    assert(alen >= 16);

    uint32_t pt[4];
    cpyBytesToWords(c, pt, 4);

    uint32_t xkey[60];
    cpyBytesToWords(c+16, xkey, 60);

    uint32_t ct[4];
    aes256_block_enc(pt, xkey, ct);
    cpyWordsToBytes(ct, a, 4);
}
