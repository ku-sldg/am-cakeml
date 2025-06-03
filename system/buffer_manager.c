#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <limits.h>
#include <string.h>
#include "shared_ffi_fns.h"
#include "buffer_manager.h"

// NOTE: These constants are strongly bound
#define NUM_BUFFERS 256
#define BUFFER_HEADER_SIZE 4
// Assert that number of buffers is less than or equal (2^(BUFFER_HEADER_SIZE * 8))
#if NUM_BUFFERS > (1 << (BUFFER_HEADER_SIZE * 8))
#error "NUM_BUFFERS must be less than 2^(BUFFER_HEADER_SIZE * 8)"
#endif

static void *buffer_registry[NUM_BUFFERS]; // Simple buffer registry

static int next_buffer_id = 0;

void get_buffer_by_id(const int buffer_id, const long length, char *out_buffer)
{
  // First, check that the buffer index is valid
  if (buffer_id < 0 || buffer_id >= NUM_BUFFERS)
  {
    DEBUG_PRINTF("get_buffer_by_id: Invalid buffer ID %d\n", buffer_id);
    return;
  }

  // Next, try to retrieve the buffer
  void *buffer_entry = buffer_registry[buffer_id];
  if (buffer_entry == NULL)
  {
    DEBUG_PRINTF("get_buffer_by_id: No buffer found for ID %d\n", buffer_id);
    return;
  }

  // We have a valid buffer, so we can copy "length" bytes into the output buffer
  if (out_buffer == NULL)
  {
    DEBUG_PRINTF("get_buffer_by_id: Invalid parameters (length: %zu, out_buffer: %p)\n", length, out_buffer);
    return;
  }

  DEBUG_PRINTF("get_buffer_by_id: Copying %zu bytes from buffer ID %d\n", length, buffer_id);
  memcpy(out_buffer, buffer_entry, length);
  DEBUG_PRINTF("get_buffer_by_id: Successfully copied data to output buffer\n");
  // Free the old buffer
  free(buffer_entry);
  buffer_entry = NULL;
  buffer_registry[buffer_id] = NULL; // Clear the registry entry
}

int find_first_free_buffer()
{
  // Iterate through the buffer registry to find the first free slot
  for (int i = 0; i < NUM_BUFFERS; i++)
  {
    if (buffer_registry[i] == NULL)
    {
      DEBUG_PRINTF("find_first_free_buffer: Found free buffer at ID %d\n", i);
      return i; // Return the index of the first free buffer
    }
  }

  DEBUG_PRINTF("find_first_free_buffer: No free buffers available\n");
  return -1; // Return -1 if no free buffers are found
}

int set_new_buffer(const long length, char *const buffer)
{
  // Validate input parameters
  if (length <= 0 || buffer == NULL)
  {
    DEBUG_PRINTF("set_new_buffer: Invalid parameters (length: %ld, buffer: %p)\n", length, buffer);
    return -1; // Error code for invalid parameters
  }

  // Check for available buffer slots
  int next_buffer_id = find_first_free_buffer();
  if (next_buffer_id < 0)
  {
    DEBUG_PRINTF("set_new_buffer: No free buffer slots available\n");
    return -2; // Error code for no free buffers
  }

  // Allocate memory for the new buffer
  buffer_registry[next_buffer_id] = buffer;

  DEBUG_PRINTF("set_new_buffer: Successfully allocated new buffer with ID %d and size %ld\n", next_buffer_id, length);

  return next_buffer_id; // Return the ID of the newly created buffer
}

void ffiget_buffer_by_id(const char *in, const long in_length, char *ret, const long ret_length)
{
  DEBUG_PRINTF("ffiget_buffer_by_id: Starting buffer retrieval\n");

  // Validate input parameters
  if (in_length != BUFFER_HEADER_SIZE || ret_length <= 0)
  {
    DEBUG_PRINTF("ffiget_buffer_by_id: Invalid input parameters (in_length: %ld, out_length: %ld)\n", in_length, ret_length);
    return;
  }

  // Extract buffer ID from the input
  int buffer_id = qword_to_int((unsigned char *)in);
  DEBUG_PRINTF("ffiget_buffer_by_id: Buffer ID requested: %d\n", buffer_id);

  // Retrieve the buffer and copy it to the output
  get_buffer_by_id(buffer_id, ret_length, ret);
}
