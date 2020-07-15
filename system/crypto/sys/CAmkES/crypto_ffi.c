#include <assert.h> // assert
#include <stdint.h> // uint8_t

#define FFI_SUCCESS 0
#define FFI_FAILURE 1

static const uint8_t rands[] = {0x4e, 0xf6, 0x22, 0xf8, 0x7c, 0xf1, 0xfa, 0x77,
                                0xf6, 0x77, 0x83, 0xf6, 0xd6, 0xd5, 0xdd, 0xa2};
static const int rands_len = 16;

// Temporary demo implementation. Recycles a static pool of randomness
void ffiurand(const uint8_t * c, long clen, uint8_t * a, long alen) {
    static int rands_idx;

    assert(alen >= 1);
    a[0] = FFI_SUCCESS;
    a++; alen--;

    for (int i = 0; i <= alen; i++, rands_idx = (rands_idx+1) % rands_len)
        a[i] = rands[rands_idx];
}
