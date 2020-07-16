// Author:  Adam Petz

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

    int digest_len = 64;  // TODO:  make this a parameter, not hardcoded

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

                memcpy(message+digest_len,digest,digest_len);

                Hacl_Hash_SHA2_hash_512(message, digest_len*2, digest);

                DEBUG_PRINT("HASH FINAL added for path: %s\n",newPath);

                memcpy(message,digest,digest_len);

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
