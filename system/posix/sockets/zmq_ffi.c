// ZeroMQ-based FFI for CakeML attestation manager
// Much more robust than manual socket handling

#include <zmq.h>
#include <assert.h>
#include <string.h>
#include "../../shared_ffi_fns.h"

#define FFI_SUCCESS 0
#define FFI_FAILURE 1

static void *zmq_context = NULL;
static void *zmq_sockets[256]; // Simple socket registry
static int next_socket_id = 1;

// Initialize ZeroMQ context (call once at startup)
void ffizmq_init(uint8_t *c, const long clen, uint8_t *a, const long alen)
{
  DEBUG_PRINTF("[ZMQ_INIT] Starting ZeroMQ initialization\n");
  assert(alen >= 1);

  if (zmq_context == NULL)
  {
    DEBUG_PRINTF("[ZMQ_INIT] Creating new ZeroMQ context\n");
    zmq_context = zmq_ctx_new();
    if (zmq_context)
    {
      DEBUG_PRINTF("[ZMQ_INIT] ZeroMQ context created successfully\n");
      a[0] = FFI_SUCCESS;
    }
    else
    {
      DEBUG_PRINTF("[ZMQ_INIT] ERROR: Failed to create ZeroMQ context\n");
      a[0] = FFI_FAILURE;
    }
  }
  else
  {
    DEBUG_PRINTF("[ZMQ_INIT] ZeroMQ context already exists, reusing\n");
    a[0] = FFI_SUCCESS; // Already initialized
  }
}

// Create a server socket (ZMQ_REP pattern for attestation requests)
void ffizmq_listen(uint8_t *c, const long clen, uint8_t *a, const long alen)
{
  DEBUG_PRINTF("[ZMQ_LISTEN] Starting server socket creation\n");
  assert(clen == 4);
  assert(alen >= 5);

  int port = qword_to_int(c);
  DEBUG_PRINTF("[ZMQ_LISTEN] Port: %d\n", port);

  if (!zmq_context)
  {
    DEBUG_PRINTF("[ZMQ_LISTEN] ERROR: ZeroMQ context not initialized\n");
    a[0] = FFI_FAILURE;
    return;
  }

  void *socket = zmq_socket(zmq_context, ZMQ_REP);
  if (!socket)
  {
    DEBUG_PRINTF("[ZMQ_LISTEN] ERROR: Failed to create ZMQ_REP socket\n");
    a[0] = FFI_FAILURE;
    return;
  }
  DEBUG_PRINTF("[ZMQ_LISTEN] ZMQ_REP socket created successfully\n");

  char endpoint[64];
  snprintf(endpoint, sizeof(endpoint), "tcp://*:%d", port);
  DEBUG_PRINTF("[ZMQ_LISTEN] Binding to endpoint: %s\n", endpoint);

  if (zmq_bind(socket, endpoint) != 0)
  {
    DEBUG_PRINTF("[ZMQ_LISTEN] ERROR: Failed to bind to %s, zmq_errno: %d\n", endpoint, zmq_errno());
    zmq_close(socket);
    a[0] = FFI_FAILURE;
    return;
  }
  DEBUG_PRINTF("[ZMQ_LISTEN] Successfully bound to %s\n", endpoint);

  // Store socket and return ID
  int socket_id = next_socket_id++;
  zmq_sockets[socket_id] = socket;
  DEBUG_PRINTF("[ZMQ_LISTEN] Socket stored with ID: %d\n", socket_id);

  a[0] = FFI_SUCCESS;
  int_to_qword(socket_id, a + 1);
  DEBUG_PRINTF("[ZMQ_LISTEN] Server socket creation completed successfully\n");
}

// Connect to a server (ZMQ_REQ pattern for sending attestation requests)
void ffizmq_connect(uint8_t *c, const long clen, uint8_t *a, const long alen)
{
  DEBUG_PRINTF("[ZMQ_CONNECT] Starting client connection\n");
  assert(clen >= 6); // port (4) + host (at least 2)
  assert(alen >= 5);

  int port = qword_to_int(c);
  char host[256];
  int host_len = clen - 4;
  DEBUG_PRINTF("[ZMQ_CONNECT] Port: %d, Host length: %d\n", port, host_len);

  if (host_len >= sizeof(host))
  {
    DEBUG_PRINTF("[ZMQ_CONNECT] ERROR: Host name too long (%d >= %zu)\n", host_len, sizeof(host));
    a[0] = FFI_FAILURE;
    return;
  }

  memcpy(host, c + 4, host_len);
  host[host_len] = '\0';
  DEBUG_PRINTF("[ZMQ_CONNECT] Host: %s\n", host);

  if (!zmq_context)
  {
    DEBUG_PRINTF("[ZMQ_CONNECT] ERROR: ZeroMQ context not initialized\n");
    a[0] = FFI_FAILURE;
    return;
  }

  void *socket = zmq_socket(zmq_context, ZMQ_REQ);
  if (!socket)
  {
    DEBUG_PRINTF("[ZMQ_CONNECT] ERROR: Failed to create ZMQ_REQ socket\n");
    a[0] = FFI_FAILURE;
    return;
  }
  DEBUG_PRINTF("[ZMQ_CONNECT] ZMQ_REQ socket created successfully\n");

  char endpoint[512];
  snprintf(endpoint, sizeof(endpoint), "tcp://%s:%d", host, port);
  DEBUG_PRINTF("[ZMQ_CONNECT] Connecting to endpoint: %s\n", endpoint);

  if (zmq_connect(socket, endpoint) != 0)
  {
    DEBUG_PRINTF("[ZMQ_CONNECT] ERROR: Failed to connect to %s, zmq_errno: %d\n", endpoint, zmq_errno());
    zmq_close(socket);
    a[0] = FFI_FAILURE;
    return;
  }
  DEBUG_PRINTF("[ZMQ_CONNECT] Successfully connected to %s\n", endpoint);

  int socket_id = next_socket_id++;
  zmq_sockets[socket_id] = socket;
  DEBUG_PRINTF("[ZMQ_CONNECT] Socket stored with ID: %d\n", socket_id);

  a[0] = FFI_SUCCESS;
  int_to_qword(socket_id, a + 1);
  DEBUG_PRINTF("[ZMQ_CONNECT] Client connection completed successfully\n");
}

// Send a message (no need for length prefixes!)
void ffizmq_send(uint8_t *c, const long clen, uint8_t *a, const long alen)
{
  DEBUG_PRINTF("[ZMQ_SEND] Starting message send\n");
  assert(clen >= 5);
  assert(alen >= 1);

  int socket_id = qword_to_int(c);
  DEBUG_PRINTF("[ZMQ_SEND] Socket ID: %d\n", socket_id);

  void *socket = zmq_sockets[socket_id];
  if (!socket)
  {
    DEBUG_PRINTF("[ZMQ_SEND] ERROR: Invalid socket ID %d\n", socket_id);
    a[0] = FFI_FAILURE;
    return;
  }

  int msg_len = clen - 4;
  char *msg_data = (char *)c + 4;
  DEBUG_PRINTF("[ZMQ_SEND] Message length: %d\n", msg_len);
  DEBUG_PRINTF("[ZMQ_SEND] Message data (first 50 chars): %.50s%s\n",
               msg_data, msg_len > 50 ? "..." : "");

  int sent_bytes = zmq_send(socket, msg_data, msg_len, 0);
  if (sent_bytes == msg_len)
  {
    DEBUG_PRINTF("[ZMQ_SEND] Successfully sent %d bytes\n", sent_bytes);
    a[0] = FFI_SUCCESS;
  }
  else
  {
    DEBUG_PRINTF("[ZMQ_SEND] ERROR: Send failed, sent %d bytes (expected %d), zmq_errno: %d\n",
                 sent_bytes, msg_len, zmq_errno());
    a[0] = FFI_FAILURE;
  }
}

// Receive a message (ZeroMQ handles message boundaries automatically)
void ffizmq_recv(uint8_t *c, const long clen, uint8_t *a, const long alen)
{
  DEBUG_PRINTF("[ZMQ_RECV] Starting message receive\n");
  assert(clen >= 4);
  assert(alen >= 5);

  int socket_id = qword_to_int(c);
  DEBUG_PRINTF("[ZMQ_RECV] Socket ID: %d\n", socket_id);

  void *socket = zmq_sockets[socket_id];
  if (!socket)
  {
    DEBUG_PRINTF("[ZMQ_RECV] ERROR: Invalid socket ID %d\n", socket_id);
    a[0] = FFI_FAILURE;
    return;
  }

  // ZeroMQ handles message boundaries - no need for get_message_size!
  int max_msg_size = alen - 5;
  DEBUG_PRINTF("[ZMQ_RECV] Max message size: %d\n", max_msg_size);

  int nbytes = zmq_recv(socket, a + 5, max_msg_size, 0);

  if (nbytes >= 0)
  {
    DEBUG_PRINTF("[ZMQ_RECV] Successfully received %d bytes\n", nbytes);
    if (nbytes > 0)
    {
      DEBUG_PRINTF("[ZMQ_RECV] Message data (first 50 chars): %.50s%s\n",
                   (char *)(a + 5), nbytes > 50 ? "..." : "");
    }
    a[0] = FFI_SUCCESS;
    int_to_qword(nbytes, a + 1);
  }
  else
  {
    DEBUG_PRINTF("[ZMQ_RECV] ERROR: Receive failed with %d bytes, zmq_errno: %d\n",
                 nbytes, zmq_errno());
    a[0] = FFI_FAILURE;
  }
}

// Close socket
void ffizmq_close(uint8_t *c, const long clen, uint8_t *a, const long alen)
{
  DEBUG_PRINTF("[ZMQ_CLOSE] Starting socket close\n");
  assert(clen >= 4);
  assert(alen >= 1);

  int socket_id = qword_to_int(c);
  DEBUG_PRINTF("[ZMQ_CLOSE] Socket ID: %d\n", socket_id);

  void *socket = zmq_sockets[socket_id];

  if (socket)
  {
    DEBUG_PRINTF("[ZMQ_CLOSE] Closing socket with ID %d\n", socket_id);
    int result = zmq_close(socket);
    if (result != 0)
    {
      DEBUG_PRINTF("[ZMQ_CLOSE] WARNING: zmq_close returned %d, zmq_errno: %d\n", result, zmq_errno());
    }
    else
    {
      DEBUG_PRINTF("[ZMQ_CLOSE] Socket closed successfully\n");
    }
    zmq_sockets[socket_id] = NULL;
    a[0] = FFI_SUCCESS;
  }
  else
  {
    DEBUG_PRINTF("[ZMQ_CLOSE] ERROR: Socket ID %d not found or already closed\n", socket_id);
    a[0] = FFI_FAILURE;
  }
}

// Cleanup (call at program exit)
void ffizmq_cleanup(uint8_t *c, const long clen, uint8_t *a, const long alen)
{
  DEBUG_PRINTF("[ZMQ_CLEANUP] Starting ZeroMQ cleanup\n");

  if (zmq_context)
  {
    DEBUG_PRINTF("[ZMQ_CLEANUP] Closing remaining sockets\n");
    // Close any remaining sockets
    int closed_count = 0;
    for (int i = 0; i < 256; i++)
    {
      if (zmq_sockets[i])
      {
        DEBUG_PRINTF("[ZMQ_CLEANUP] Closing socket ID %d\n", i);
        zmq_close(zmq_sockets[i]);
        zmq_sockets[i] = NULL;
        closed_count++;
      }
    }
    DEBUG_PRINTF("[ZMQ_CLEANUP] Closed %d sockets\n", closed_count);

    DEBUG_PRINTF("[ZMQ_CLEANUP] Destroying ZeroMQ context\n");
    int result = zmq_ctx_destroy(zmq_context);
    if (result != 0)
    {
      DEBUG_PRINTF("[ZMQ_CLEANUP] WARNING: zmq_ctx_destroy returned %d, zmq_errno: %d\n", result, zmq_errno());
    }
    else
    {
      DEBUG_PRINTF("[ZMQ_CLEANUP] ZeroMQ context destroyed successfully\n");
    }
    zmq_context = NULL;
  }
  else
  {
    DEBUG_PRINTF("[ZMQ_CLEANUP] No ZeroMQ context to clean up\n");
  }

  if (alen >= 1)
  {
    a[0] = FFI_SUCCESS;
  }
  DEBUG_PRINTF("[ZMQ_CLEANUP] ZeroMQ cleanup completed\n");
}
