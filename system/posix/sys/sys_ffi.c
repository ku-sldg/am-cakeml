#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

#define SUCCESS 0x00
#define FAILED_TO_READ_FILE 0xed
#define FAILED_TO_REALLOC_BUFFER 0xee
#define FAILED_TO_ALLOCATE_BUFFER 0xef
#define INSUFFICIENT_OUTPUT 0xf0
#define NEED_MORE_THAN_32_BITS_FOR_LENGTH 0xf1
#define FILE_READ_ERROR 0xfe
#define FILE_CLOSE_ERROR 0xff

void ffisystem(const uint8_t *c, const long clen, uint8_t *a, const long alen)
{
  int out = system((char *)c);
  // Cast down to a uint8_t return address
  uint8_t truncatedErrCode = (out & 0xff);
  if (truncatedErrCode > 0)
  {
    *a = truncatedErrCode;
  }
  else if (out > 0)
  {
    // We somehow truncated too much and lost the fact that it was an error!
    *a = 0xff;
  }
}

/**
 * Function to read an entire file until EOF
 * Returns:
 *
 * 0x00 = Success
 *
 * 0xed = Failed to read from file properly
 * 0xee = Buffer reallocation error
 * 0xef = Failed to allocate initial buffer
 *
 */
uint8_t read_until_eof(FILE *file, size_t INITIAL_BUFFER_SIZE, char **buffer, size_t *total_read)
{
  size_t buffer_size = INITIAL_BUFFER_SIZE;
  *total_read = 0;
  printf("Got to file read malloc\n");
  *buffer = malloc(buffer_size);
  printf("Got after file read malloc\n");

  if (buffer == NULL)
  {
    perror("read_until_eof: Failed to allocate initial buffer");
    return FAILED_TO_ALLOCATE_BUFFER;
  }

  size_t bytes_read;
  while ((bytes_read = fread(*buffer + *total_read, 1, buffer_size - *total_read - 1, file)) > 0)
  {
    printf("Got to start of file read while\n");
    *total_read += bytes_read;

    // Check if we need to resize the buffer
    if (*total_read >= buffer_size - 1)
    {
      buffer_size *= 2;
      // Resize and reallocate (safely moves the ptrs)
      printf("Got to file read realloc\n");
      char *new_buffer = realloc(*buffer, buffer_size);
      printf("Got after file read realloc\n");

      // Checks if realloc fails
      if (new_buffer == NULL)
      {
        perror("read_until_eof: Failed to reallocate buffer");
        // Ptr wasnt properly moved, so we need to free the old buffer
        free(*buffer);
        return FAILED_TO_REALLOC_BUFFER;
      }

      // Update the buffer ptr, (realloc already freed the old buffer)
      *buffer = new_buffer;
    }
  }
  printf("Got after file read while\n");

  // Handle errors in fread
  if (ferror(file))
  {
    perror("read_until_eof: Error reading from file");
    free(buffer);
    return FAILED_TO_READ_FILE;
  }

  // Null-terminate the buffer
  printf("Got to file read null term\n");
  printf("Total Read: %ld\n", *total_read);
  printf("Buffer Size: %ld\n", buffer_size);
  buffer[*total_read] = '\0';
  printf("Got after file read null term\n");

  return SUCCESS;
}

/**
 * We we always return
 * [  Success_Code  : 1 Byte ;
 *    OutputLength  : 4 Bytes ;
 *    Output        : OutputLength Bytes ;
 * ]
 *
 * Return of 0x00 = Success
 *
 * Return of 0xf0 = Insufficient space for output
 * Return of 0xfe = Failed to read from file properly
 * Return of 0xff = Failed to open file
 */
void ffipopen_string(const uint8_t *c, const long clen, uint8_t *a, const long alen)
{
  const uint8_t RESPONSE_CODE_START = 0;
  const uint8_t RESPONSE_CODE_LENGTH = 1;
  const uint8_t OUTPUT_LENGTH_START = 1;
  const uint8_t OUTPUT_LENGTH_LENGTH = 4;
  const uint8_t HEADER_LENGTH = RESPONSE_CODE_LENGTH + OUTPUT_LENGTH_LENGTH;
  // Run the program that is given in the input "c" and capture the output to a variable "out"
  printf("Running command: %s\n", c);
  printf("Command Length: %ld\n", clen);
  printf("Current Output: %s\n", a);
  printf("Output Length: %ld\n", alen);

  // Print out a to debug
  for (int i = 0; i < alen; i++)
  {
    printf("%02x", a[i]);
  }

  FILE *fp = popen((char *)c, "r");
  if (fp == NULL)
  {
    // Error handling
    a[RESPONSE_CODE_START] = FILE_READ_ERROR;
    return;
  }

  // Read the output running the command into a buffer
  char *buffer = NULL;
  size_t output_length = 0;
  printf("Got to file read\n");
  uint8_t out_code = read_until_eof(fp, alen - HEADER_LENGTH, &buffer, &output_length);
  fclose(fp);
  printf("Got past file read\n");
  // Cast the output length to a 32-bit integer, with error if too large
  if (output_length > UINT32_MAX)
  {
    a[RESPONSE_CODE_START] = NEED_MORE_THAN_32_BITS_FOR_LENGTH;
    return;
  }

  uint32_t output_size = (uint32_t)output_length + HEADER_LENGTH;
  printf("Output Size: %d\n", output_size);
  // Storing output size in the
  // OUTPUT_LENGTH_START - (OUTPUT_LENGTH_START + OUTPUT_LENGTH_LENGTH)
  // bytes of the output
  assert(sizeof(output_size) == OUTPUT_LENGTH_LENGTH);
  for (int i = 0; i < OUTPUT_LENGTH_LENGTH; i++)
  {
    // We want to store the length of the payload, not the payload + headers
    // Overall the full response is len(payload) + len(headers)
    a[OUTPUT_LENGTH_START + i] = (output_length >> (i * 8)) & 0xff;
  }

  if (out_code != SUCCESS)
  {
    // We had an error in the read_until_eof function
    a[RESPONSE_CODE_START] = out_code;
    return;
  }

  // Otherwise, we have successfully read the output into the buffer
  if (output_size >= alen)
  {
    // We have insufficient space for the output
    out_code = INSUFFICIENT_OUTPUT;
    a[RESPONSE_CODE_START] = out_code;
    return;
  }

  // By this point, we know we have succeeding in reading
  // the output into the buffer, and we have enough space
  // in the output array to store the output
  // So we copy the buffer into the output array
  a[RESPONSE_CODE_START] = SUCCESS;
  for (int i = 0; i < output_length; i++)
  {
    a[HEADER_LENGTH + i] = (uint8_t)buffer[i];
  }
  printf("Got to final return\n");

  // Print out a to debug, truncated too
  for (int i = 0; i < output_size; i++)
  {
    printf("%02x", a[i]);
  }
  fflush(NULL);

  return;
}