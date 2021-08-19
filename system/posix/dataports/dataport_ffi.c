#include <assert.h>
#include <stdbool.h>
#include <string.h>
#include <stdint.h>

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include <stdio.h>

#define FFI_SUCCESS 0
#define FFI_FAILURE 1

// TODO: remove ffi_asserts. They don't clean up (close fd and munmap)

void ffiwriteDataport(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    assert(clen >= 2);
    assert(alen >= 1);

    const char * name = (const char *)c;
    size_t nameSize = strnlen(name, clen) + 1;
    void * msg = (void *)(name + nameSize);
    size_t length = (size_t)clen - nameSize;

    // Why does write-only open lead to failure on subsequent mmap?
    // Same thing in emitDataport
    // int fd = open(name, O_WRONLY);
    int fd = open(name, O_RDWR);
    if (fd == -1) {
        a[0] = FFI_FAILURE;
        return;
    }

    void * dataport = mmap(NULL, length, PROT_WRITE, MAP_SHARED, fd, getpagesize());
    if (dataport == (void *)(-1)) {
        close(fd);
        a[0] = FFI_FAILURE;
        return;
    }

    memcpy(dataport, msg, length);

    munmap(dataport, length);
    close(fd);

    a[0] = FFI_SUCCESS;
}

void ffireadDataport(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    assert(clen >= 1);
    assert(alen >= 2);

    const char * name = (const char *)c;

    int fd = open(name, O_RDONLY);
    if (fd == -1) {
        a[0] = FFI_FAILURE;
        return;
    }

    void * dataport = mmap(NULL, alen-1, PROT_READ, MAP_SHARED, fd, getpagesize());
    if (dataport == (void *)(-1)) {
        close(fd);
        a[0] = FFI_FAILURE;
        return;
    }

    memcpy((void *)(a+1), dataport, alen-1);

    munmap(dataport, alen-1);
    close(fd);

    a[0] = FFI_SUCCESS;
}

void ffiwaitDataport(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    assert(clen >= 1);
    assert(alen >= sizeof(int) + 1);

    const char * name = (const char *)c;

    int fd = open(name, O_RDONLY);
    if (fd == -1) {
        a[0] = FFI_FAILURE;
        return;
    }

    int val;
    int result = read(fd, &val, sizeof(int));
    if (result != sizeof(int)) {
        close(fd);
        a[0] = FFI_FAILURE;
        return;
    }

    memcpy((void *)a+1, (const void *)(&val), sizeof(int));
    a[0] = FFI_SUCCESS;
}


// Note: emitDataport seems to break when compiled for 32-bit ARM on a 64-bit ARM architecture.
//   The dataport write will trigger a SIGSEGV or SIGILL signal
void ffiemitDataport(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    assert(clen >= 1);
    assert(alen >= 1);

    const char * name = (const char *)c;

    // int fd = open(name, O_WRONLY);
    int fd = open(name, O_RDWR);
    if (fd == -1) {
        a[0] = FFI_FAILURE;
        return;
    }

    void * dataport = mmap(NULL, 1, PROT_WRITE, MAP_SHARED, fd, 0);
    if (dataport == (void *)(-1)) {
        close(fd);
        a[0] = FFI_FAILURE;
        return;
    }

    *((uint8_t *)dataport) = 1;

    munmap(dataport, 1);
    close(fd);

    a[0] = FFI_SUCCESS;
}