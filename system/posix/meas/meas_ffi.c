// Author:  Adam Petz

// Linux/MacOS-specific measurements

#include <assert.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <dirent.h>
#include <stdlib.h>
#include <stddef.h>
#include <errno.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <grp.h>
#include <sys/wait.h>

// External call to sha512 in `./system/crypto/openssl/crypto_ffi.c`.
bool sha512(const uint8_t *, const size_t, uint8_t *);

#define FFI_SUCCESS 0
#define FFI_FAILURE 1
#define FFI_BUFFER_TOO_SMALL 2
#define ffi_assert(cond) {if (!(cond)) { a[0] = FFI_FAILURE; return; }}

// TODO: add compile-time switch for MacOS-variant
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

void * mapFileContents(const char * filename, size_t * file_size){
    int fd = open(filename, O_RDONLY);
    if (fd == -1)
        return NULL;

    struct stat st;
    int err = stat(filename, &st);
    if (err == -1) {
        close(fd);
        return NULL;
    }
    size_t file_size_v = (size_t)st.st_size;
    if(file_size_v == 0){
        close(fd);
        *file_size = 0;
        return NULL;
    }

    *file_size = file_size_v;
    void * ret = mmap((void *)NULL, file_size_v, PROT_READ, MAP_SHARED, fd, 0);
    close(fd);
    return ret;
}

void ffifileHash(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    assert(alen >= 65);

    const char * filename = (const char *)c;

    size_t file_size = 0;

    void * file = mapFileContents(filename, &file_size);
    ffi_assert(file != NULL || file_size == 0);

    // Hacl_Hash_SHA2_hash_512((uint8_t *)file, (uint32_t)file_size, a+1);
    sha512((uint8_t *)file, file_size, a+1);

    munmap(file, file_size);
    a[0] = FFI_SUCCESS;
}

// Returns 1 (true) for success, 0 (false) for failure
int hash_region(char * pid, long addr, size_t len, uint8_t * hash) {
    char path_buf[256];
    int err = sprintf(path_buf, "/proc/%s/mem", pid);
    if (err < 0) return 0;

    FILE * stream = fopen(path_buf, "r");
    if (!stream)
        return 0;

    void * region = malloc(len);
    err = fseek(stream, addr, SEEK_SET);
    if (err == -1) {
        fclose(stream);
        free(region);
        return 0;
    }
    int numRead = fread(region, 1, len, stream);
    fclose(stream);
    if (numRead < len) {
        free(region);
        return 0;
    }

    // Hacl_Hash_SHA2_hash_512((uint8_t *)region, len, hash);
    sha512((uint8_t *)region, len, hash);

    free(region);
    return 1;
}

void ffihashRegion(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    assert(clen >= 3);
    assert(alen >= 65);

    char * pid = (char *)c;
    char * startHex = pid + strlen(pid) +1;
    char * endHex = startHex + strlen(startHex) +1;

    long addr = strtol(startHex, NULL, 16);
    long len  = strtol(endHex,   NULL, 16) - addr;

    int good = hash_region(pid, addr, (size_t)len, a+1);
    a[0] = good ? FFI_SUCCESS : FFI_FAILURE;
}

// CakeML function `dirEntries : string -> (string * entryType) list`
//  - Takes a filename, and returns a list of entries, along with type (file, dir, etc.)

// First byte of `a` is the error flag, as usual. After that, a list of directory entries
// and their type are encoded as a type-signaling byte, followed by the null-terminated 
// string name. 
#define ENC_DT_UNKNOWN 1
#define ENC_DT_REG     2
#define ENC_DT_DIR     3
#define ENC_DT_FIFO    4
#define ENC_DT_SOCK    5
#define ENC_DT_CHR     6
#define ENC_DT_BLK     7
#define ENC_DT_LNK     8
void ffireadDir(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    assert(clen > 0);
    assert(alen > 0);

    const char * dirName = (const char *)c;
    DIR * dir = opendir(dirName);
    if (!dir) {
        a[0] = FFI_FAILURE;
        return;
    }

    int prev_errno = errno;
    errno = 0;
    long apos = 1;
    for (struct dirent * entry = readdir(dir); entry; entry = readdir(dir)) {
        // Check buffer space remaining
        size_t d_len = strlen(entry->d_name);
        if(apos + d_len + 2 >= alen) {
            closedir(dir);
            a[0] = FFI_BUFFER_TOO_SMALL;
            return;
        }
        
        // Encode entry type
        switch(entry->d_type) {
            case DT_UNKNOWN:
                a[apos] = ENC_DT_UNKNOWN;
                break;
            case DT_REG:
                a[apos] = ENC_DT_REG;
                break;
            case DT_DIR:
                a[apos] = ENC_DT_DIR;
                break;
            case DT_FIFO:
                a[apos] = ENC_DT_FIFO;
                break;
            case DT_SOCK:
                a[apos] = ENC_DT_SOCK;
                break;
            case DT_CHR:
                a[apos] = ENC_DT_CHR;
                break;
            case DT_BLK:
                a[apos] = ENC_DT_BLK;
                break;
            case DT_LNK:
                a[apos] = ENC_DT_LNK;
                break;
            default: 
                assert(!"Unreachable");
        }
        apos++;
        
        // Copy over entry name
        strcpy((char *)(a+apos), entry->d_name);
        apos += d_len+1;
    }
    
    closedir(dir);

    if (errno) {
        a[0] = FFI_FAILURE;
        return;
    }
    errno = prev_errno;
}

bool dropRoot() {
    int nobody = 65534;
    gid_t group = (gid_t)nobody;
    uid_t user = (uid_t)nobody;
    return setgroups(1, (const gid_t *)(&group)) != -1
        && setgid(group) == 0
        && setuid(user) == 0;
}

void ffinewProc(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    assert(alen >= 6);

    // We assume no more than 255 arguments
    char * argv[256] = {0};
    { // parse into argv
        int c_i = 0;
        int argv_i = 0;
        bool in_arg = false;
        for(; c_i < clen && argv_i < 254; c_i++)
            if (in_arg && c[c_i] == (char)0)
                in_arg = false;
            else if (!in_arg && c[c_i] != (char)0) {
                argv[argv_i] = c + c_i;
                argv_i++;
                in_arg = true;
            }
    }

    // printf("c: ");
    // for (int i = 0; i < clen; i++)
    //     if(c[i] == (char)0) 
    //         printf(".");
    //     else
    //         printf("%c", c[i]);
    // printf("\n");

    // printf("argv:\n");
    // for(int i = 0; argv[i] != (char *)NULL; i++)
    //     printf("%d: %s\n", i, argv[i]);
    // printf("\n");

    pid_t pid = fork();
    if (pid == -1) {
        // Fork failed
        a[0] = FFI_FAILURE;
        return;
    }
    else if (pid == 0) {
        // Child process

        // if (!dropRoot())
        //     exit(1);

        execv((const char *)c, argv);
    }
    else {
        // Parent process
        a[0] = FFI_SUCCESS;
        sprintf((char *)(a+1), "%u", (unsigned int)pid);
    }
}

// Writes 'true' to a[0] if child has terminated
void ffichildTerminated(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    assert(alen >= 1);

    pid_t pid = (pid_t)atoi((const char *)c);
    // fprintf(stderr, "\nChecking pid: %u\n", pid);
    pid_t ret = waitpid(pid, (int *)NULL, WEXITED | WNOHANG);
    
    // if (ret == -1)
    //   error
    // fprintf(stderr, "\nwaitpid return: %d\n", ret);

    a[0] = ret != pid; 
}