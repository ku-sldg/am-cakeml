#include <stdint.h>
#include <stdlib.h>

void ffisystem(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
  system((char*)c);
}