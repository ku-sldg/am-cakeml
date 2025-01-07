// FFI interface to UNIX-style network sockets.

// This socket interface is largely based on the example provided in the
// getaddrinfo man page http://man7.org/linux/man-pages/man3/getaddrinfo.3.html

// This macro is needed for getaddrinfo, as documented in the manpage.
// gcc defines this macro by default, but CompCert does not.
// We must therefore define it explicitly.
#define _POSIX_C_SOURCE 201112L
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <errno.h>
#include <assert.h>     // assert
#include <stdint.h>     // uint8_t, uint16_6, etc.
#include <sys/types.h>  // socket, bind, listen, getaddrinfo
#include <sys/socket.h> // socket, bind, listen, getaddrinfo
#include <netdb.h>      // getaddrinfo
#include <string.h>     // memset, strerror
#include <unistd.h>     // close
#include "../../shared_ffi_fns.h"

/**
 * Reads the message size prefix (4 bytes) from a socket.
 *
 * @param sock The socket file descriptor to read from.
 * @param size Pointer to store the message size (in host byte order).
 * @return 0 on success, -1 on failure.
 */
int get_message_size(int sock, size_t *size)
{
  DEBUG_PRINTF("In function get_message_size\n");
  DEBUG_PRINTF("Given arguments: sock=%d\n", sock);
  uint32_t net_size;
  ssize_t bytes_read = read(sock, &net_size, sizeof(net_size));
  if (bytes_read == 0)
  {
    DEBUG_PRINTF("Connection closed by peer.\n");
    return -1; // Connection closed
  }
  else if (bytes_read != sizeof(net_size))
  {
    DEBUG_PRINTF("Failed to read message size: %s\n", strerror(errno));
    return -1; // Read error
  }

  *size = ntohl(net_size); // Convert from network byte order
  return 0;                // Success
}

// Function to establish a listening socket on a given IP and port
int listen_socket(const char *ip, int port, int queueLength)
{
  DEBUG_PRINTF("In function listen_socket\n");
  DEBUG_PRINTF("Given arguments: ip=%s, port=%d, queueLength=%d\n", ip, port, queueLength);
  int sock = socket(AF_INET, SOCK_STREAM, 0);
  if (sock < 0)
  {
    DEBUG_PRINTF("Socket creation failed: %s\n", strerror(errno));
    return -1;
  }

  struct sockaddr_in server_addr;
  server_addr.sin_family = AF_INET;
  server_addr.sin_port = htons(port);

  // Use INADDR_ANY if no IP is provided
  if (ip == NULL)
  {
    DEBUG_PRINTF("Binding to all interfaces\n");
    server_addr.sin_addr.s_addr = INADDR_ANY;
  }
  else if (inet_pton(AF_INET, ip, &server_addr.sin_addr) <= 0)
  {
    DEBUG_PRINTF("Invalid IP address: %s\n", ip);
    close(sock);
    return -1;
  }

  if (bind(sock, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0)
  {
    DEBUG_PRINTF("Bind failed: %s\n", strerror(errno));
    close(sock);
    return -1;
  }

  if (listen(sock, queueLength) < 0)
  {
    DEBUG_PRINTF("Listen failed: %s\n", strerror(errno));
    close(sock);
    return -1;
  }

  return sock;
}

// Function to accept a client connection
int accept_socket(int listen_sock)
{
  DEBUG_PRINTF("In function accept_socket\n");
  DEBUG_PRINTF("Given arguments: listen_sock=%d\n", listen_sock);
  struct sockaddr_in client_addr;
  socklen_t client_len = sizeof(client_addr);

  int client_sock = accept(listen_sock, (struct sockaddr *)&client_addr, &client_len);
  if (client_sock < 0)
  {
    DEBUG_PRINTF("Accept failed: %s\n", strerror(errno));
    return -1;
  }

  printf("Connection accepted from %s:%d\n",
         inet_ntoa(client_addr.sin_addr), ntohs(client_addr.sin_port));
  return client_sock;
}

// Function to connect to a server
int connect_socket(const char *ip, int port)
{
  DEBUG_PRINTF("In function connect_socket\n");
  DEBUG_PRINTF("Given arguments: ip=%s, port=%d\n", ip, port);

  int sock = socket(AF_INET, SOCK_STREAM, 0);
  if (sock < 0)
  {
    DEBUG_PRINTF("Socket creation failed: %s\n", strerror(errno));
    return -1;
  }

  struct addrinfo hints = {0}, *res;
  hints.ai_family = AF_INET;       // Use IPv4
  hints.ai_socktype = SOCK_STREAM; // Use TCP

  // Convert port to a string for getaddrinfo
  char port_str[6];
  snprintf(port_str, sizeof(port_str), "%d", port);

  // Resolve the hostname or IP address
  if (getaddrinfo(ip, port_str, &hints, &res) != 0)
  {
    DEBUG_PRINTF("Failed to resolve IP address or hostname: %s\n", ip);
    close(sock);
    return -1;
  }

  // Attempt to connect to the resolved address
  if (connect(sock, res->ai_addr, res->ai_addrlen) < 0)
  {
    DEBUG_PRINTF("Connection failed: %s\n", strerror(errno));
    freeaddrinfo(res);
    close(sock);
    return -1;
  }

  freeaddrinfo(res); // Free memory allocated by getaddrinfo
  return sock;       // Return the connected socket
}

int socket_read(int sock, void *out_data, size_t length)
{
  DEBUG_PRINTF("In function socket_read\n");
  DEBUG_PRINTF("Given arguments: sock=%d, length=%zu\n", sock, length);
  // Read the actual message
  ssize_t bytes_read = read(sock, out_data, length);
  if (bytes_read != (ssize_t)length)
  {
    DEBUG_PRINTF("Failed to read complete message: %s\n", strerror(errno));
    return -1;
  }

  return 0; // Success
}

int socket_write(int sock, const void *data, size_t length)
{
  DEBUG_PRINTF("In function socket_write\n");
  DEBUG_PRINTF("Given arguments: sock=%d, length=%zu\n", sock, length);
  // Send the length of the message (4 bytes)
  uint32_t net_length = htonl(length); // Convert to network byte order
  if (write(sock, &net_length, sizeof(net_length)) != sizeof(net_length))
  {
    DEBUG_PRINTF("Failed to send message length: %s\n", strerror(errno));
    return -1;
  }

  // Send the actual message
  if (write(sock, data, length) != (ssize_t)length)
  {
    DEBUG_PRINTF("Failed to send message data: %s\n", strerror(errno));
    return -1;
  }

  return 0; // Success
}

#define FFI_SUCCESS 0
#define FFI_FAILURE 1

// Arguments: queueLength [0:3], port [4:7]
// Returns: failure flag in a[0], sockfd as 32-bit int in a[1..4]
void ffilisten(uint8_t *c, const long clen, uint8_t *a, const long alen)
{
  DEBUG_PRINTF("In function ffilisten\n");
  assert(clen == 8);
  int queueLength = qword_to_int(c);
  int port = qword_to_int(c + 4);
  assert(alen == 5);

  // NOTE: We utilize NULL for IP here to bind to all available interfaces
  int server_sockfd = listen_socket(NULL, port, queueLength);
  if (server_sockfd < 0)
  {
    a[0] = FFI_FAILURE;
    return;
  }

  // return sockfd
  a[0] = FFI_SUCCESS;
  int_to_qword(server_sockfd, a + 1);
}

// Argument: sockfd as 64-bit int in c
// Returns: failure flag in a[0], conn_sockfd as 32-bit int in a[1..5]
// Blocks until there is an incoming connection
void ffiaccept(uint8_t *c, const long clen, uint8_t *a, const long alen)
{
  DEBUG_PRINTF("In function ffiaccept\n");
  assert(clen == 4);
  int sockfd = qword_to_int(c);
  assert(alen == 5);
  int connection_fd = accept_socket(sockfd);
  if (connection_fd < 0)
  {
    a[0] = FFI_FAILURE;
    return;
  }
  // return connection_fd
  a[0] = FFI_SUCCESS;
  int_to_qword(connection_fd, a + 1);
}

/**
c: port [0:4], host is remainder of message
clen > 5
a: flag [0], sockfd [1:5] */
void fficonnect(uint8_t *c, const long clen, uint8_t *a, const long alen)
{
  DEBUG_PRINTF("In function fficonnect\n");
  assert(clen >= 2); // Assumes there are at least the null byte delimiter and terminator
  assert(alen == 5);

  // Parse arguments
  int port = qword_to_int(c);
  // Take slice from c[4 : clen]
  char *host = (char *)c + 4;
  DEBUG_PRINTF("Connecting to %s:%d\n", host, port);

  // Do connection
  int sockfd = connect_socket(host, port);
  if (sockfd < 0)
  {
    a[0] = FFI_FAILURE;
    return;
  }
  // return sockfd
  a[0] = FFI_SUCCESS;
  int_to_qword(sockfd, a + 1);
}

/**
c: sockfd [0:4],
clen: 4
a: success flag [0], msg_length [1:5],
alen: 5
*/
void ffisocket_get_message_length(uint8_t *c, const long clen, uint8_t *a, const long alen)
{
  DEBUG_PRINTF("In function ffisocket_get_message_length\n");
  assert(clen == 4);
  int sockfd = qword_to_int(c);
  DEBUG_PRINTF("Getting message length from socket %d\n", sockfd);
  assert(alen == 5);
  size_t msg_length;
  if (get_message_size(sockfd, &msg_length) < 0)
  {
    a[0] = FFI_FAILURE;
    return;
  }
  DEBUG_PRINTF("Message length: %zu\n", msg_length);
  a[0] = FFI_SUCCESS;
  int_to_qword(msg_length, a + 1);
}

/**
c: c[0:4] is sockfd, c[4:] is the message to write
clen: length of message
a: success flag [0], # bytes written [1:5]
alen: 5
*/
void ffisocket_write(uint8_t *c, const long clen, uint8_t *a, const long alen)
{
  DEBUG_PRINTF("In function ffisocket_write\n");
  assert(clen >= 5);
  // Parse arguments
  int sockfd = qword_to_int(c);
  DEBUG_PRINTF("Writing to socket %d\n", sockfd);
  // Take slice from c[4 : clen]
  // but we must be careful since c might have extra NULL characters in it
  int n = clen - 4;
  char *buffer = (char *)c + 4;
  DEBUG_PRINTF("Message length: %d\n", n);
  assert(alen == 5);

  // Write to socket
  ssize_t bytes_written = socket_write(sockfd, buffer, n);
  if (bytes_written < 0)
  {
    a[0] = FFI_FAILURE;
    return;
  }

  // return bytes_written
  a[0] = FFI_SUCCESS;
  int_to_qword(bytes_written, a + 1);
}

/**
c : sockfd [0:3], msg_size [4:7]
clen: 8
a : success flag [0], [1: msg_size + 1] message
alen : msg_size + 1
*/
void ffisocket_read(uint8_t *c, const long clen, uint8_t *a, const long alen)
{
  DEBUG_PRINTF("In function ffisocket_read\n");
  assert(clen == 8); // Ensure control buffer is the correct size

  int sockfd = qword_to_int(c);
  int msg_size = qword_to_int(c + 4);

  // Ensure output buffer is large enough
  assert(alen == msg_size + 1);

  // Read the message into `a + 1`
  if (socket_read(sockfd, a + 1, msg_size) < 0)
  {
    a[0] = FFI_FAILURE; // Indicate failure
    return;
  }

  a[0] = FFI_SUCCESS; // Indicate success
}
