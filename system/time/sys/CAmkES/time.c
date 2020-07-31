#include <camkes.h>
#include <stdint.h>
#include <string.h>

// Gives a timestamp in microseconds
void ffitimestamp(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    uint64_t t = timer_time(); // Gets time in nanoseconds
    t /= 1e3; // nano is 10^-9, micro is 10^-6
    memcpy((void *)a, (const void *)(&t), 8);
}