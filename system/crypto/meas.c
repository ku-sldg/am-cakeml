// Author:  Adam Petz

// Linux/MacOS-specific measurements

#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <dirent.h>
#include <stdlib.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <string.h>

#include "debug.h"
#include "Hacl_Hash.h"
#include "meas.h"

#define FFI_SUCCESS 0
#define FFI_FAILURE 1
#define ffi_assert(cond) {if (!(cond)) { a[0] = FFI_FAILURE; return; }}

#define DIGEST_LEN 64

void ffifileHash(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    DEBUG_PRINT("calling ffifileHash\n\n");
    assert(alen >= 65);

    const char * filename = (const char *)c;
    // DEBUG_PRINT("Filename: %s\n", filename);

    size_t file_size = 0;

    void * file = mapFileContents(filename, &file_size);
    ffi_assert(file != NULL);
    DEBUG_PRINT("file_size after rfc(%s): %i\n",filename,file_size);
    DEBUG_PRINT("file contents after rfc: %s\n",file);

    Hacl_Hash_SHA2_hash_512((uint8_t *)file, (uint32_t)file_size, a+1);

    int err = munmap(file, file_size);
    if (err == -1) {
        DEBUG_PRINT("Failed to unmap file: %s\n",filename);
    }

    a[0] = FFI_SUCCESS;
}

void ffidirHash(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    DEBUG_PRINT("Calling ffidirHash\n\n");

    char * path = (char *)c;
    char * exclPath = path + strlen(path);

    DEBUG_PRINT("path: \n%s\n", path);
    DEBUG_PRINT("excludePath: \n%s\n", exclPath);

    uint8_t message[DIGEST_LEN *2] = {0}; // initializes to zero

    DEBUG_PRINT("\ncalling doCompositeHashh\n");
    int good = doCompositeHash(path, exclPath, a+1, (uint8_t *)message);
    ffi_assert(good);
    DEBUG_PRINT("After doCompositeHash\n");

    a[0] = FFI_SUCCESS;  // TODO: this should depend on a result from doCompositeHash?
}

int doCompositeHash(const char *basePath, const char *excludePath, uint8_t *digest, uint8_t *message)
{
    if(!strcmp(basePath,excludePath)){
        return 1;
    }

    DEBUG_PRINT("Start of doCompositeHash: %s\n",basePath);
    char path[1000];
    struct dirent **namelist;
    int n = scandir(basePath, &namelist, NULL, alphasort);
    if(n == -1){
        DEBUG_PRINT("Not a directory\n");
        // This seems like a problem if it is a top-level call, but not otherwise.
        return 1;
    }

    for(int k = 0; k < n; k++){

        if (strcmp(namelist[k]->d_name, ".") != 0
          && strcmp(namelist[k]->d_name, "..") != 0){

            if (namelist[k]->d_type == DT_REG) {

                char newPath[1000];
                strcpy(newPath, basePath);
                strcat(newPath, "/");
                strcat(newPath, namelist[k]->d_name);

                DEBUG_PRINT("Adding hash for: %s\n",newPath);

                if (!hash_file_contents(newPath, digest)) {
                    for (int i = k; i < n; i++)
                        free(namelist[i]);
                    free(namelist);
                    return 0;
                }

                DEBUG_PRINT("HASH added for path: %s\n",newPath);

                memcpy(message + DIGEST_LEN, digest, DIGEST_LEN);

                Hacl_Hash_SHA2_hash_512(message, DIGEST_LEN*2, digest);

                DEBUG_PRINT("HASH FINAL added for path: %s\n",newPath);

                memcpy(message,digest,DIGEST_LEN);

            }
            // Construct new path from our base path
            strcpy(path, basePath);
            strcat(path, "/");
            strcat(path, namelist[k]->d_name);

            if (!doCompositeHash(path,excludePath,digest,message))
                return 0;
        }
        free(namelist[k]);
    }
    free(namelist);
    return 1;
}

int hash_file_contents(const char * filename, uint8_t * digest) {
    size_t file_size = 0;

    void * file = mapFileContents(filename, &file_size);
    if(!file && file_size != 0)
        return 0;

    DEBUG_PRINT("file_size after rfc(%s): %i\n",filename,file_size);
    DEBUG_PRINT("file contents after rfc: %s\n",file);

    Hacl_Hash_SHA2_hash_512((uint8_t *)file, (uint32_t)file_size, digest);

    if (file && munmap(file, file_size) == -1) {
        DEBUG_PRINT("Failed to unmap file: %s\n",filename);
    }

    return 1;
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
