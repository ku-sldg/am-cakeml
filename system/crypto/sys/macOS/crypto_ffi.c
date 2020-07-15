#include <assert.h>    // assert
#include <stdint.h>    // uint8_t
#include <sys/types.h> // read
#include <sys/uio.h>   // read
#include <fcntl.h>     // open
#include <unistd.h>    // read, close

#define FFI_SUCCESS 0
#define FFI_FAILURE 1

void ffiurand(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    // Prevents complaint about unused arguments
    (void)c; (void)clen;

    // We need at least enough space to return success/fail.
    assert(alen >= 1);

    int fd = open("/dev/urandom", O_RDONLY);
    if(fd == -1) {
        close(fd);
        a[0] = FFI_FAILURE;
        return;
    }

    size_t want = (size_t)alen-1;
    ssize_t got = read(fd, a+1, want);
    if(got < 0 || (size_t)got != want)
        a[0] = FFI_FAILURE;
    else
        a[0] = FFI_SUCCESS;
    close(fd);
}
