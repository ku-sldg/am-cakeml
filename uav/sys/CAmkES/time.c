#include <camkes.h>
#include <stdint.h>
#include <string.h>

void ffitimestamp(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    uint64_t t = timer_time();
    memcpy((void *)a, (const void *)(&t), 8);
}
