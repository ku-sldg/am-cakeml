#include <stdint.h>
#include <stddef.h>
#include <stdio.h>

#include "Hacl_Ed25519.h"

#define PRIV_LEN 32
#define PUB_LEN  64

#define FFI_SUCCESS 0
#define FFI_FAILURE 1

// Defined in sys/.../crypto_ffi.c
void ffiurand(const uint8_t * c, const long clen, uint8_t * a, const long alen);

void print_bytes(uint8_t * bytes, int len) {
    // printf("0x");
    for (int i = 0; i < len; i++)
        printf("%02X", bytes[i]);
}

// Borrows the ffi interface to multi-platform prng to generate the private key.
// The private key is then generated from the private key.
int main(void) {
    const long buf_len = PRIV_LEN + 1;
    uint8_t buf[buf_len];
    ffiurand((const uint8_t *)NULL, (const long)0, (uint8_t *)buf, buf_len);
    if (buf[0] == FFI_FAILURE) {
        printf("Failed to generate public key.\n");
        return 1;
    }
    uint8_t * priv = (uint8_t *)buf + 1;

    printf("Private key (hexadecimal):\n");
    print_bytes(priv, PRIV_LEN);
    printf("\n\n");

    uint8_t pub[PUB_LEN];
    Hacl_Ed25519_secret_to_public((uint8_t *)pub, priv);

    printf("Public key (hexadecimal):\n");
    print_bytes(pub, PUB_LEN);
    printf("\n");

    return 0;
}
