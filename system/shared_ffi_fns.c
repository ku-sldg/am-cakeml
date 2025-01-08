#include "shared_ffi_fns.h"

void int_to_byte2(int i, unsigned char *b)
{
  /* i is encoded on 2 bytes */
  b[0] = (i >> 8) & 0xFF;
  b[1] = i & 0xFF;
}

int byte2_to_int(unsigned char *b)
{
  return ((b[0] << 8) | b[1]);
}

int qword_to_int(unsigned char *b)
{
  return ((b[0] << 24) | (b[1] << 16) | (b[2] << 8) | b[3]);
}

void int_to_qword(int i, unsigned char *b)
{
  b[0] = (i >> 24) & 0xFF;
  b[1] = (i >> 16) & 0xFF;
  b[2] = (i >> 8) & 0xFF;
  b[3] = i & 0xFF;
}

void int_to_byte8(int i, unsigned char *b)
{
  /* i is encoded on 8 bytes */
  /* i is cast to long long to ensure having 64 bits */
  /* assumes CHAR_BIT = 8. use static assertion checks? */
  b[0] = ((long long)i >> 56) & 0xFF;
  b[1] = ((long long)i >> 48) & 0xFF;
  b[2] = ((long long)i >> 40) & 0xFF;
  b[3] = ((long long)i >> 32) & 0xFF;
  b[4] = ((long long)i >> 24) & 0xFF;
  b[5] = ((long long)i >> 16) & 0xFF;
  b[6] = ((long long)i >> 8) & 0xFF;
  b[7] = (long long)i & 0xFF;
}

int byte8_to_int(unsigned char *b)
{
  return (((long long)b[0] << 56) | ((long long)b[1] << 48) |
          ((long long)b[2] << 40) | ((long long)b[3] << 32) |
          (b[4] << 24) | (b[5] << 16) | (b[6] << 8) | b[7]);
}
