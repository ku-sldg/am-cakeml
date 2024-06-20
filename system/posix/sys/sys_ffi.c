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

/**
 * Return of 0xff = Failed to open file
 * Return of 0xfe = Failed to read from file properly
 */
void ffisystem_string(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
  // Run the program that is given in the input "c" and capture the output to a variable "out"
  char output[1024];
  FILE *fp = popen((char*)c, "r");
  if (fp == NULL) {
    // Error handling
    *a = 0xff;
    return;
  }
  char* ret = fgets(output, sizeof(output), fp);
  if (ret == NULL) {
    // Error handling
    *a = 0xfe;
    return;
  }
  pclose(fp);

  // Copy the output to the destination array "a"
  for (int i = 0; i < alen && output[i] != '\0'; i++) {
    a[i] = (uint8_t)output[i];
  }

  // int out = system((char*)c);
  // // Cast down to a uint8_t return address
  // uint8_t truncatedErrCode = (out & 0xff);
  // if (truncatedErrCode > 0) {
  //   *a = truncatedErrCode;
  // } else if (out > 0) {
  //   // We somehow truncated too much and lost the fact that it was an error!
  //   *a = 0xff;
  // }
}