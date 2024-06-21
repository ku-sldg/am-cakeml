#include <assert.h>
#include <stdint.h>
#include <stddef.h>

#include <camkes.h>

#define FFI_SUCCESS 0
#define FFI_FAILURE 1

// memcpy variants for volatile buffers
void * memcpy_vlatile_src(void *dest, const volatile void *src, size_t n) {
    for (int i = 0; i < n; i++)
        ((uint8_t *)dest)[i] = ((uint8_t *)src)[i];
    return dest;
}

bool ffireadFile(const uint8_t * c, const long clen, uint8_t * a, const long alen)
{
    assert(clen >= 2);
    assert(alen >= 1);
    const char* filepath = (char*)c;
    int size = 0;
    bool query_result = file_read_query(filepath, &size);
    if(!query_result)
    {
        printf("Error! No file at that filepath.\n");
        return FFI_FAILURE;
    }
    if(size > 4096)
    {
        printf("Error! File requested was too large.\n");
        return FFI_FAILURE;
    }
    char* file = malloc(size);
    if(file == NULL)
    {
        printf("Error! Malloc returned NULL.\n");
        return FFI_FAILURE;
    }
    for(int i=0; i<size; i++)
    {
        file[i] = 0x1;
    }
    bool result = file_read_request(filepath, &file, size);
    if(!result)
    {
        printf("Error! No file at that filepath.");
        free(file);
        return FFI_FAILURE;
    }
    memcpy_volatile_src((void*)a+1, (void*)file, size);
    a[0] = FFI_SUCCESS;
    free(file);
    return;
}

