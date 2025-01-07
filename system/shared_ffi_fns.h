#ifndef SHARED_FFI_FNS
#define SHARED_FFI_FNS

#include <stdio.h>

// A macro for printing debugging info
#define DEBUG_MODE 1
#if DEBUG_MODE
#define DEBUG_PRINTF(...) fprintf(stderr, __VA_ARGS__)
#else
#define DEBUG_PRINTF(...)
#endif

void int_to_byte2(int i, unsigned char *b);

int byte2_to_int(unsigned char *b);

int qword_to_int(unsigned char *b);

void int_to_qword(int i, unsigned char *b);

void int_to_byte8(int i, unsigned char *b);

int byte8_to_int(unsigned char *b);

#endif