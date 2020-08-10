// Author:  Adam Petz

// Linux/MacOS-specific measurements

#include <assert.h>
#include <stdint.h>
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

#include "debug.h"
#include "meas.h"

#include "Hacl_Hash.h"

#define FFI_SUCCESS 0
#define FFI_FAILURE 1
#define FFI_BUFFER_TOO_SMALL 2
#define ffi_assert(cond) {if (!(cond)) { a[0] = FFI_FAILURE; return; }}

#define DIGEST_LEN 64

void ffifileHash(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    DEBUG_PRINT("calling ffifileHash\n\n");
    assert(alen >= 65);

    const char * filename = (const char *)c;
    DEBUG_PRINT("Filename: %s\n", filename);

    size_t file_size = 0;

    void * file = mapFileContents(filename, &file_size);
    ffi_assert(file != NULL || file_size == 0);

    DEBUG_PRINT("file_size after rfc(%s): %i\n",filename,file_size);
    DEBUG_PRINT("file contents after rfc: %s\n",file);

    Hacl_Hash_SHA2_hash_512((uint8_t *)file, (uint32_t)file_size, a+1);

    if (file && munmap(file, file_size) == -1)
        DEBUG_PRINT("Failed to unmap file: %s\n",filename);

    a[0] = FFI_SUCCESS;
}

void * mapFileContents(const char * filename, size_t * file_size){
    int fd = open(filename, O_RDONLY);
    if (fd == -1)
        return NULL;

    struct stat st;
    int err = stat(filename, &st);
    if (err == -1)
        return NULL;
    size_t file_size_v = (size_t)st.st_size;
    if(file_size_v == 0){
        DEBUG_PRINT("zero length file\n");
        *file_size = 0;
        return NULL;
    }

    *file_size = file_size_v;
    return mmap((void *)NULL, file_size_v, PROT_READ, MAP_SHARED, fd, 0);
}

// Returns 1 (true) for success, 0 (false) for failure
int hash_region(char * pid, long addr, size_t len, uint8_t * hash) {
    char path_buf[256];
    int err = sprintf(path_buf, "/proc/%s/mem", pid);
    if (err < 0) return 0;

    FILE * stream = fopen(path_buf, "r");
    if (!stream) {
        DEBUG_PRINT("Failed to open %s\n", path_buf);
        return 0;
    }

    void * region = malloc(len);
    err = fseek(stream, addr, SEEK_SET);
    if (err == -1) {
        DEBUG_PRINT("fseek failed\n");
        fclose(stream);
        free(region);
        return 0;
    }
    int numRead = fread(region, 1, len, stream);
    fclose(stream);
    if (numRead < len) {
        DEBUG_PRINT("fread failed\n");
        free(region);
        return 0;
    }

    Hacl_Hash_SHA2_hash_512((uint8_t *)region, len, hash);

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

    DEBUG_PRINT("Pid: %s, Address: %lx, length: %lx\n", pid, addr, len);

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
    if (errno) {
        a[0] = FFI_FAILURE;
        return;
    }
    errno = prev_errno;

    closedir(dir);
}