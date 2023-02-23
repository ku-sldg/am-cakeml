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
#define ffi_assert(cond) {if (!(cond)) { close(fd); a[0] = FFI_FAILURE; return; }}

void ffiwriteDataport(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    assert(clen >= 2);
    assert(alen >= 1);

    const char * name = (const char *)c;
    size_t nameSize = strnlen(name, clen) + 1;
    void * msg = (void *)(name + nameSize);
    size_t length = (size_t)clen - nameSize;

    int fd = open((const char *)c, O_RDWR);
    ffi_assert(fd >= 0);

    void * dataport = mmap(NULL, length, PROT_WRITE, MAP_SHARED, fd, getpagesize());
    ffi_assert(dataport != (void *)(-1));

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
    ffi_assert(fd >= 0);

    void * dataport = mmap(NULL, alen-1, PROT_READ, MAP_SHARED, fd, getpagesize());
    ffi_assert(dataport != (void *)(-1));

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
    ffi_assert(fd >= 0);

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
//
// Note: emitDataport seems to break when compiled for 32-bit ARM on a 64-bit ARM architecture.
//   The dataport write will trigger a SIGSEGV or SIGILL signal
void ffiemitDataport(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    assert(clen >= 1);
    assert(alen >= 1);

    const char * name = (const char *)c;

    // int fd = open(name, O_WRONLY);
    int fd = open(name, O_RDWR);
    ffi_assert(fd >= 0);

    void * dataport = mmap(NULL, 1, PROT_WRITE, MAP_SHARED, fd, 0);
    ffi_assert(dataport != (void *)(-1));

    *((uint8_t *)dataport) = 1;

    munmap(dataport, 1);
    close(fd);

    a[0] = FFI_SUCCESS;
}








// write the contents of c to the dataport
void ffidataport_write( unsigned char* c, long clen, unsigned char* a, long alen )
{
    char *dataport_name = "/dev/uio0";
    int length = strlen( c );
    assert(length > 0);

    int fd = open(dataport_name, O_RDWR);
    assert(fd >= 0);

    char *dataport;
    if ((dataport = mmap(NULL, length, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 1 * getpagesize())) == (void *) -1) {
        printf("mmap failed\n");
        close(fd);
    }

    for( int i=0; i<length; i++ )
    {
        dataport[i] = c[i];
    }
    dataport[length] = '\0';

    munmap(dataport, length);
    close(fd);
}

// input a byte array of size 4096 as c
// length is always understood to be the size of the dataport buffer
// c is then filled up with the contents of the dataport
void ffidataport_read( unsigned char* c, long clen, unsigned char* a, long alen )
{
    char* name = "/dev/uio0";
    int length = (size_t)4096;

    int fd = open(name, O_RDWR);
    ffi_assert(fd >= 0);

    char* dataport = mmap(NULL, length, PROT_WRITE, MAP_SHARED, fd, getpagesize());
    ffi_assert(dataport != (void *)(-1));

    void* msg = (const char *)c;
    memcpy(msg, dataport, length);

    munmap(dataport, length);
    close(fd);

    a[0] = FFI_SUCCESS;
}

// let the other end of the dataport know we're done writing
void ffiemit_event( unsigned char* a, long alen, unsigned char* b, long blen)
{
    char* connection_name = "/dev/uio0";

    int fd = open(connection_name, O_RDWR);
    assert(fd >= 0);

    char *connection;
    if ((connection = mmap(NULL, 0x1000, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0 * getpagesize())) == (void *) -1) {
        printf("mmap failed\n");
        close(fd);
    }

    /* Write at register address 0 to trigger an emit signal */
    connection[0] = 1;

    munmap(connection, 0x1000);
    close(fd);

    return 0;
}
