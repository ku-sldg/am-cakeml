#include <assert.h>
#include <stdint.h>
#include <stddef.h>

#include <camkes.h>

#define FFI_SUCCESS 0
#define FFI_FAILURE 1

bool ffimeasurementRequest(const uint8_t * c, const long clen, uint8_t * a, const long alen)
{
    assert(clen >= 2);
    assert(alen >= 1);
    int meas_id = byte2_to_int(c); //from the cakeml_basis.c
    bool appraisal_result = introspective_measurement_request( meas_id );
    if(appraisal_result)
    {
        a[0] = FFI_SUCCESS;
    }
    else
    {
        a[0] = FFI_FAILURE;
    }
}

