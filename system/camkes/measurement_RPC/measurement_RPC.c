#include <assert.h>
#include <stdint.h>
#include <stddef.h>

#include <camkes.h>

#define FFI_SUCCESS 0
#define FFI_FAILURE 1

// memcpy variants for volatile buffers
void * memcpy_volatile_src(void *dest, const volatile void *src, size_t n) {
    for (int i = 0; i < n; i++)
        ((uint8_t *)dest)[i] = ((uint8_t *)src)[i];
    return dest;
}

void ffimeasurementRequest(const uint8_t * c, const long clen, uint8_t * a, const long alen)
{
    assert(clen >= 2);
    assert(alen >= 1);
    int meas_id = byte2_to_int(c); //from the cakeml_basis.c
    //'zero' out the shared memory where the evidence will be written
    memset(evidence, '\1', 4096);
    bool rpc_result = introspective_measurement_request( meas_id );
    if(!rpc_result)
    {
        a[0] = FFI_FAILURE;
        return;
    }
    for(int i=1; i<4096; i++)
    {
        ((char*)a)[i] = ((char*)evidence)[i];
    }
    a[0] = FFI_SUCCESS;
}

void ffimeasurementAppraise(const uint8_t * c, const long clen, uint8_t * a, const long alen)
{
    assert(clen >= 2);
    assert(alen >= 1);
    int meas_id = byte2_to_int(c); //from the cakeml_basis.c
    char* appraisal_report = NULL;

    bool rpc_result = introspective_measurement_appraise( meas_id, &appraisal_report );
    if(!rpc_result)
    {
        a[0] = FFI_FAILURE;
        return;
    }

    printf("Appraisal Result: %s\n", appraisal_report);

    // Should we fail if output buffer is too long?
    memcpy_volatile_src((void *)(a+1), appraisal_report, alen-1);

    // We are bound to free this.
    free(appraisal_report);

    a[0] = FFI_SUCCESS;
}

