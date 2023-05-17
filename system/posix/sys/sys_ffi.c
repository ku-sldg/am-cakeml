#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

void ffisystem(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
  int out = system((char*)c);
  // Cast down to a uint8_t return address
  uint8_t truncatedErrCode = (out & 0xff);
  if (truncatedErrCode > 0) {
    *a = truncatedErrCode;
  } else if (out > 0) {
    // We somehow truncated too much and lost the fact that it was an error!
    *a = 0xff;
  }
}