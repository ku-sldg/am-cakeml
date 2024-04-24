#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

#define MAX_BUFFER_SIZE 4096

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

// c is the input
// a is the output (answer)
char * ffipopen(const uint8_t *c, const long clen, uint8_t* a, const long alen) {
    FILE *fp;
    char *output = (char *)malloc(MAX_BUFFER_SIZE * sizeof(char));
    if (output == NULL) {
        perror("Failed to allocate memory");
        exit(EXIT_FAILURE);
    }
    
    memset(output, 0, MAX_BUFFER_SIZE);

    fp = popen(executable_path, "r");
    if (fp == NULL) {
        perror("Failed to execute command");
        exit(EXIT_FAILURE);
    }

    fread(output, sizeof(char), MAX_BUFFER_SIZE, fp);

    if (pclose(fp) == -1) {
        perror("Failed to close stream");
        exit(EXIT_FAILURE);
    }

    return output;
}

