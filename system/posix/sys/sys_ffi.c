#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <limits.h>
#include <string.h>
#include "../../shared_ffi_fns.h"
#include "../../buffer_manager.h"

#define SUCCESS 0x00
#define BUFFER_OVERFLOW 0xe0
#define PATH_ERROR 0xe1
#define FAILED_TO_READ_FILE 0xed
#define FAILED_TO_REALLOC_BUFFER 0xee
#define FAILED_TO_ALLOCATE_BUFFER 0xef
#define INSUFFICIENT_OUTPUT 0xf0
#define NEED_MORE_THAN_32_BITS_FOR_LENGTH 0xf1
#define FILE_READ_ERROR 0xfe
#define FILE_CLOSE_ERROR 0xff

/**
 * Function to read an entire file until EOF
 * Returns:
 *
 * 0x00 = Success
 * 0xe0 = Buffer overflow (should not happen with proper sizing)
 * 0xed = Failed to read from file properly
 * 0xee = Buffer reallocation error
 * 0xef = Failed to allocate initial buffer
 *
 * Note: On error, *buffer is set to NULL and any allocated memory is freed.
 */
uint8_t read_until_eof(FILE *file, size_t INITIAL_BUFFER_SIZE, char **buffer, size_t *total_read)
{
  // Input validation
  if (file == NULL || buffer == NULL || total_read == NULL)
  {
    DEBUG_PRINTF("read_until_eof: Invalid input parameters\n");
    if (buffer != NULL)
      *buffer = NULL;
    if (total_read != NULL)
      *total_read = 0;
    return FAILED_TO_ALLOCATE_BUFFER;
  }

  // Ensure minimum buffer size
  if (INITIAL_BUFFER_SIZE < 64)
  {
    INITIAL_BUFFER_SIZE = 64;
  }

  size_t buffer_size = INITIAL_BUFFER_SIZE;
  *total_read = 0;
  *buffer = malloc(buffer_size);

  if (*buffer == NULL)
  {
    DEBUG_PRINTF("read_until_eof: Failed to allocate initial buffer of size %zu\n", buffer_size);
    return FAILED_TO_ALLOCATE_BUFFER;
  }

  size_t bytes_read;
  while ((bytes_read = fread(
              *buffer + *total_read,         // Start writing at the start of the buffer + any offset for what we've already read
              1,                             // Read 1 byte at a time
              buffer_size - *total_read - 1, // Read all the way to the end of the buffer - the items already read - 1 for null terminator
              file)) > 0)
  {
    *total_read += bytes_read;

    // Check if we need to resize the buffer
    if (*total_read + 1 > buffer_size)
    {
      // This should never happen, but just in case
      DEBUG_PRINTF("read_until_eof: Buffer overflow detected\n");
      free(*buffer);
      *buffer = NULL;
      return BUFFER_OVERFLOW;
    }
    else if (*total_read >= (buffer_size - 1))
    {
      buffer_size *= 2;
      DEBUG_PRINTF("read_until_eof: Resizing buffer from %zu to %zu bytes\n", buffer_size / 2, buffer_size);
      // Resize and reallocate (safely moves the ptrs)
      char *new_buffer = realloc(*buffer, buffer_size);

      // Checks if realloc fails
      if (new_buffer == NULL)
      {
        DEBUG_PRINTF("read_until_eof: Failed to reallocate buffer to %zu bytes\n", buffer_size);
        // Ptr wasn't properly moved, so we need to free the old buffer
        free(*buffer);
        *buffer = NULL;
        return FAILED_TO_REALLOC_BUFFER;
      }

      // Update the buffer ptr, (realloc already freed the old buffer)
      *buffer = new_buffer;
    }
  }

  // Handle errors in fread
  if (ferror(file))
  {
    DEBUG_PRINTF("read_until_eof: Error reading from file\n");
    free(*buffer);
    *buffer = NULL;
    return FAILED_TO_READ_FILE;
  }

  // Null-terminate the buffer
  (*buffer)[*total_read] = '\0';

  return SUCCESS;
}

/**
 * FFI function to execute a command via popen and return its output.
 *
 * Input:
 * - commandIn: Null-terminated command string (must be absolute path)
 * - clen: Length of command string
 * - a: Output buffer
 * - alen: Length of output buffer
 *
 * Output format in buffer 'a':
 * [  Success_Code  : 1 Byte ;
 *    OutputLength  : 4 Bytes (little-endian);
 *    OutputBuffId  : 4 Bytes (little-endian);
 * ]
 *
 * Return codes:
 * 0x00 = Success
 * 0xe1 = Invalid path (must be absolute, no '..' allowed)
 * 0xf0 = Insufficient space for output
 * 0xf1 = Output too large (>UINT32_MAX bytes)
 * 0xfe = Failed to open pipe or command execution error
 * 0xff = Command execution failed (non-zero exit)
 * 0xed-0xef = Buffer allocation/read errors
 */
void ffipopen_string(const char *commandIn, const long clen, char *a, const long alen)
{
  const uint8_t RESPONSE_CODE_START = 0;
  const uint8_t RESPONSE_CODE_LENGTH = 1;
  const uint8_t OUTPUT_LENGTH_START = RESPONSE_CODE_START + RESPONSE_CODE_LENGTH;
  const uint8_t OUTPUT_LENGTH_LENGTH = 4;
  const uint8_t OUTPUT_BUFFER_ID_START = OUTPUT_LENGTH_START + OUTPUT_LENGTH_LENGTH;
  const uint8_t OUTPUT_BUFFER_ID_LENGTH = 4; // Not used in this implementation, but reserved for future use
  const uint8_t HEADER_LENGTH = OUTPUT_BUFFER_ID_START + OUTPUT_BUFFER_ID_LENGTH;

  // Input validation
  if (commandIn == NULL || a == NULL || alen != HEADER_LENGTH || clen <= 0)
  {
    DEBUG_PRINTF("ffipopen_string: Invalid input parameters\n");
    DEBUG_PRINTF("ffipopen_string: commandIn: %p, clen: %ld, a: %p, alen: %ld\n",
                 commandIn, clen, a, alen);
    if (a != NULL && alen >= 1)
    {
      a[RESPONSE_CODE_START] = FILE_READ_ERROR;
    }
    return;
  }

  // Validate command length consistency
  size_t actual_len = strlen(commandIn);
  if (actual_len != (size_t)clen)
  {
    DEBUG_PRINTF("ffipopen_string: Command length mismatch (expected %ld, actual %zu)\n", clen, actual_len);
    a[RESPONSE_CODE_START] = PATH_ERROR;
    return;
  }

  // Print debugging info
  DEBUG_PRINTF("ffipopen_string: Command: %s\n", commandIn);
  DEBUG_PRINTF("ffipopen_string: Command Length: %ld\n", clen);
  DEBUG_PRINTF("ffipopen_string: Output buffer size: %ld\n", alen);

  // Validate command path - reject relative paths and potentially dangerous patterns
  if (commandIn[0] != '/' || strstr(commandIn, "..") != NULL)
  {
    DEBUG_PRINTF("ffipopen_string: Invalid path detected (must be absolute and not contain '..'): %s\n", commandIn);
    a[RESPONSE_CODE_START] = PATH_ERROR;
    return;
  }

  // Open a pipe to the command
  FILE *fp = popen((char *)commandIn, "r");
  if (fp == NULL)
  {
    DEBUG_PRINTF("ffipopen_string: Failed to open pipe for command: %s\n", commandIn);
    a[RESPONSE_CODE_START] = FILE_READ_ERROR;
    return;
  }

  // Read the output from the command into a buffer
  char *buffer = NULL;
  size_t output_length = 0;
  uint8_t out_code = read_until_eof(fp, alen - HEADER_LENGTH, &buffer, &output_length);
  DEBUG_PRINTF("ffipopen_string: Read %zu bytes from command output\n", output_length);

  // Close the pipe and check for command execution errors
  int ret = pclose(fp);
  if (ret != 0)
  {
    DEBUG_PRINTF("ffipopen_string: Command failed with exit code %d\n", ret);
    if (buffer != NULL)
    {
      free(buffer);
    }
    a[RESPONSE_CODE_START] = FILE_CLOSE_ERROR;
    return;
  }

  // Check if read_until_eof encountered an error
  if (out_code != SUCCESS)
  {
    DEBUG_PRINTF("ffipopen_string: Error reading command output: %d\n", out_code);
    if (buffer != NULL)
    {
      free(buffer);
    }
    a[RESPONSE_CODE_START] = out_code;
    return;
  }

  // Ensure we have a valid buffer
  if (buffer == NULL)
  {
    DEBUG_PRINTF("ffipopen_string: No buffer allocated despite SUCCESS status\n");
    a[RESPONSE_CODE_START] = FAILED_TO_ALLOCATE_BUFFER;
    return;
  }

  // Cast the output length to a 32-bit integer, with error if too large
  if (output_length > UINT32_MAX)
  {
    DEBUG_PRINTF("ffipopen_string: Output length %zu exceeds UINT32_MAX\n", output_length);
    free(buffer);
    a[RESPONSE_CODE_START] = NEED_MORE_THAN_32_BITS_FOR_LENGTH;
    return;
  }

  // uint32_t output_size = (uint32_t)output_length + HEADER_LENGTH;

  // // Check if we have enough space in the output array
  // if (output_size > alen)
  // {
  //   DEBUG_PRINTF("ffipopen_string: Insufficient space for output (need %u, have %ld)\n", output_size, alen);
  //   DEBUG_PRINTF("ffipopen_string: Output content (truncated): %.100s%s\n",
  //                buffer, output_length > 100 ? "..." : "");
  //   free(buffer);
  //   a[RESPONSE_CODE_START] = INSUFFICIENT_OUTPUT;
  //   return;
  // }

  // Store the buffer in our buffer manager
  int buffer_id = set_new_buffer(output_length, buffer);
  DEBUG_PRINTF("ffipopen_string: Successfully copying %zu bytes to buffer %d\n", output_length, buffer_id);

  // Store output length in the header (little-endian format)
  // OUTPUT_LENGTH_START to (OUTPUT_LENGTH_START + OUTPUT_LENGTH_LENGTH)
  assert(sizeof(uint32_t) == OUTPUT_LENGTH_LENGTH);
  assert(sizeof(uint32_t) == OUTPUT_BUFFER_ID_LENGTH);
  int_to_qword(output_length, (unsigned char *)&a[OUTPUT_LENGTH_START]);
  int_to_qword(buffer_id, (unsigned char *)&a[OUTPUT_BUFFER_ID_START]);
  // for (int i = 0; i < OUTPUT_LENGTH_LENGTH; i++)
  // {
  //   // Store the length of the payload, not including headers
  //   a[OUTPUT_LENGTH_START + i] = (output_length >> (i * 8)) & 0xff;
  // }
  // for (int i = 0; i < OUTPUT_BUFFER_ID_LENGTH; i++)
  // {
  //   // Store the buffer ID in little-endian format
  //   a[OUTPUT_BUFFER_ID_START + i] = (buffer_id >> (i * 8)) & 0xff;
  // }

  // Copy the buffer content to the output array
  a[RESPONSE_CODE_START] = SUCCESS;
  // Clean up and return
  DEBUG_PRINTF("ffipopen_string: Function completed successfully\n");
  return;
}