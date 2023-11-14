#include <assert.h>
#include <stdint.h>
#include <stddef.h>

#include <camkes.h>

#define FFI_SUCCESS 0
#define FFI_FAILURE 1

/* // memcpy variants for volatile buffers */
/* void * memcpy_volatile_src(void *dest, const volatile void *src, size_t n) { */
/*     for (int i = 0; i < n; i++) */
/*         ((uint8_t *)dest)[i] = ((uint8_t *)src)[i]; */
/*     return dest; */
/* } */

bool ffisendCoplandRequest(const uint8_t * c, const long clen, uint8_t * a, const long alen)
{
    assert(clen >= 2);
    assert(alen >= 1);
    //int meas_id = byte2_to_int(c); //from the cakeml_basis.c

    //decode the input string as "ip:port:request_json"
    char* ip = c;
    char* port = 0;
    char* json_request = NULL;
    int numNullCharsSeen = 0;

    for(int i=0; i<4096; i++)
    {
        char ptr = c[i];
        if(ptr=='\0')
        {
            if(numNullCharsSeen==0)
            {
                port = c+i+1;
            }
            else if(numNullCharsSeen==1)
            {
                json_request = c+i+1;
                break;
            }
            numNullCharsSeen++;
        }
    }

    if(ip==NULL || port==0 || json_request==NULL)
    {
        printf("Failed to extract ip or port or json_request in fficoplandSend.\n");
        a[0] = FFI_FAILURE;
        return;
    }

    printf("DEBUG: ip port json is\n%s\n%s\n%s\n", ip, port, json_request);

    /* char* response = NULL; // we are bound to free this */
    /* bool rpc_result = comm_util_do_what_do( ip, port, json_request, &response ); */
    /* if(!rpc_result) */
    /* { */
    /*     a[0] = FFI_FAILURE; */
    /*     return; */
    /* } */

    /* // Should we fail if output buffer is too long? */
    /* memcpy_volatile_src((void *)(a+1), response, alen-1); */

    /* // We are bound to free this. */
    /* free(response); */

    a[0] = FFI_SUCCESS;
}


bool ffisendCoplandAppRequest(const uint8_t * c, const long clen, uint8_t * a, const long alen)
{
    assert(clen >= 2);
    assert(alen >= 1);
    //int meas_id = byte2_to_int(c); //from the cakeml_basis.c

    //decode the input string as "ip:port:request_json"
    char* ip = c;
    char* port = 0;
    char* json_request = NULL;
    int numNullCharsSeen = 0;

    for(int i=0; i<4096; i++)
    {
        char ptr = c[i];
        if(ptr=='\0')
        {
            if(numNullCharsSeen==0)
            {
                port = c+i+1;
            }
            else if(numNullCharsSeen==1)
            {
                json_request = c+i+1;
                break;
            }
            numNullCharsSeen++;
        }
    }

    if(ip==NULL || port==0 || json_request==NULL)
    {
        printf("Failed to extract ip or port or json_request in fficoplandSend.\n");
        a[0] = FFI_FAILURE;
        return;
    }

    printf("DEBUG: ip port json is\n%s\n%s\n%s\n", ip, port, json_request);

    /* char* response = NULL; // we are bound to free this */
    /* bool rpc_result = comm_util_do_what_do_app( ip, port, json_request, &response ); */
    /* if(!rpc_result) */
    /* { */
    /*     a[0] = FFI_FAILURE; */
    /*     return; */
    /* } */

    /* // Should we fail if output buffer is too long? */
    /* memcpy_volatile_src((void *)(a+1), response, alen-1); */

    /* // We are bound to free this. */
    /* free(response); */

    a[0] = FFI_SUCCESS;
}
