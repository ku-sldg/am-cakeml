#include <assert.h> // assert
#include <stdint.h> // uint8_t

#define FFI_SUCCESS 0
#define FFI_FAILURE 1

// Placeholder function - does not fill a+1 with random bytes
void ffiurand(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    assert(alen >= 1);
    a[0] = FFI_SUCCESS;
}
