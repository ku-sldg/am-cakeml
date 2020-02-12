// Alternative FFI interface for systems without sockets. Functions always
// return the failure flag

#include <assert.h> // asserts
#include <stdint.h> // uint8_t and uint32_t types

#define FFI_SUCCESS 0
#define FFI_FAILURE 1

void ffilisten(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    (void)c;
    (void)clen;

    assert(alen > 0);
    a[0] = FFI_FAILURE;
}

void ffiaccept(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    (void)c;
    (void)clen;

    assert(alen > 0);
    a[0] = FFI_FAILURE;
}

void fficonnect(uint8_t * c, const long clen, uint8_t * a, const long alen) {
    (void)c;
    (void)clen;

    assert(alen > 0);
    a[0] = FFI_FAILURE;
}
