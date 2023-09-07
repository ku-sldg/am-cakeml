#include <assert.h>
#include <stdint.h>
#include <stddef.h>

#include <camkes.h>

#define FFI_SUCCESS 0
#define FFI_FAILURE 1

// memcpy variants for volatile buffers
volatile void * memcpy_v(volatile void *dest, const volatile void *src, size_t n) {
    for (int i = 0; i < n; i++)
        ((uint8_t *)dest)[i] = ((uint8_t *)src)[i];
    return dest;
}
volatile void * memcpy_vdest(volatile void *dest, const void *src, size_t n) {
    for (int i = 0; i < n; i++)
        ((uint8_t *)dest)[i] = ((uint8_t *)src)[i];
    return dest;
}
void * memcpy_vsrc(void *dest, const volatile void *src, size_t n) {
    for (int i = 0; i < n; i++)
        ((uint8_t *)dest)[i] = ((uint8_t *)src)[i];
    return dest;
}


typedef struct Connection {
    volatile void * data;
    int length;
    void (*wait)(void);
    void (*emit)(void);
} Connection_t;

// This array needs to be edited to match the particular CAmkES component
#define CONNS_LEN 2
Connection_t conns[CONNS_LEN];

void ffiinitDataports(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    conns[0] = (Connection_t){.data = inspect_dp, .length = 4096, .wait = &measurement_done_wait, .emit = &measurement_request_emit};
    conns[1] = (Connection_t){.data = client_dp, .length = 4096, .wait = &client_ready_wait, .emit = &client_done_emit};
}

void ffiwriteDataport(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    assert(clen >= 2);
    assert(alen >= 1);

    int conn_id = byte2_to_int(c);
    Connection_t conn = conns[conn_id];

    if (conn.data == NULL) {
        a[0] = FFI_FAILURE;
        return;
    }

    // Should we fail instead of truncating if input is too long?
    int cpy_len = (clen-2) < conn.length ? (clen-2) : conn.length;
    memcpy_vdest(conn.data, (const void *)(c+2), cpy_len);

    a[0] = FFI_SUCCESS;
}

void ffireadDataport(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    assert(clen >= 2);
    assert(alen >= 1);

    int conn_id = byte2_to_int(c);
    Connection_t conn = conns[conn_id];

    if (conn.data == NULL) {
        a[0] = FFI_FAILURE;
        return;
    }

    // Should we fail if output buffer is too long?
    int cpy_len = (alen-1) < conn.length ? (alen-1) : conn.length;
    memcpy_vsrc((void *)(a+1), conn.data, cpy_len);

    a[0] = FFI_SUCCESS;
}

void ffiwaitDataport(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    assert(clen >= 2);
    assert(alen >= 1);

    int conn_id = byte2_to_int(c);
    Connection_t conn = conns[conn_id];

    if (conn.wait == NULL) {
        a[0] = FFI_FAILURE;
        return;
    }

    conn.wait();
    a[0] = FFI_SUCCESS;
}

void ffiemitDataport(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    assert(clen >= 2);
    assert(alen >= 1);

    int conn_id = byte2_to_int(c);
    Connection_t conn = conns[conn_id];

    if (conn.emit == NULL) {
        a[0] = FFI_FAILURE;
        return;
    }

    conn.emit();
    a[0] = FFI_SUCCESS;
}
