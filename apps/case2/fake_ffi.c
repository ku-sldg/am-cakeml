// This file will be regenerated, do not edit

#define _GNU_SOURCE

#include <stdbool.h>
#include <stdint.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <sys/types.h>  // socket, bind, listen, getaddrinfo
#include <sys/socket.h> // socket, bind, listen, getaddrinfo
#include <netdb.h>      // getaddrinfo
#include <unistd.h>     // close
#include <fcntl.h>

// Globals
int listener_fd;
bool listener_open = false;
int conn_fd;
bool conn_open = false;

void ffiapi_receiveInput(unsigned char *parameter, long parameterSizeBytes, unsigned char *output, long outputSizeBytes) {
  return;
}

void ffiapi_sendOutput(unsigned char *parameter, long parameterSizeBytes, unsigned char *output, long outputSizeBytes) {
  return;
}

void ffiapi_logInfo(unsigned char *parameter, long parameterSizeBytes, unsigned char *output, long outputSizeBytes){
  printf("INFO: %s\n", parameter);
} 

void ffiapi_logDebug(unsigned char *parameter, long parameterSizeBytes, unsigned char *output, long outputSizeBytes){
  printf("DEBUG: %s\n", parameter);
} 

void ffiapi_logError(unsigned char *parameter, long parameterSizeBytes, unsigned char *output, long outputSizeBytes){
  printf("ERROR: %s\n", parameter);
} 

void ffiapi_send_AttestationRequest(unsigned char *parameter, long parameterSizeBytes, unsigned char *output, long outputSizeBytes) {
  assert(parameterSizeBytes == 16);

  write(conn_fd, (const void *)parameter, 16);
}


void ffiapi_get_AttestationResponse(unsigned char *parameter, long parameterSizeBytes, unsigned char *output, long outputSizeBytes) {
  assert(outputSizeBytes = 2049);

  ssize_t n_read = read(conn_fd, ((void *)output)+1, 2048);
  output[0] = n_read > 0;
}

void ffiapi_send_TrustedIds(unsigned char *parameter, long parameterSizeBytes, unsigned char *output, long outputSizeBytes) {
  printf("Sending trusted ids: [%i,%i,%i,%i]\n", *((int32_t*)parameter), *((int32_t*)parameter + 1), *((int32_t*)parameter + 2), *((int32_t*)parameter + 3));
}

int get_listener(int qlen, char * port) {
    struct addrinfo hints;
    memset(&hints, 0, sizeof(struct addrinfo));

    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_flags = AI_PASSIVE;
    hints.ai_protocol = IPPROTO_TCP;

    struct addrinfo * result;
    if (getaddrinfo(0, port, &hints, &result)) {
        freeaddrinfo(result);
        return -1;
    }

    int sockfd;
    struct addrinfo * r;
    // Loop through addrinfo list from getadrrinfo until one works (or failure)
    for (r = result; r; r = r->ai_next) {
        sockfd = socket(r->ai_family, r->ai_socktype, r->ai_protocol);
        if (sockfd == -1)
            continue;

        int enable = 1;
        setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &enable, sizeof(enable));

        if (!bind(sockfd, r->ai_addr, r->ai_addrlen))
            break;

        close(sockfd);
    }
    freeaddrinfo(result);
    if (!r || sockfd == -1)
        return -1;

    // Listen for incoming connections, with a maximum queue length of qlen
    if (listen(sockfd, qlen))
        return -1;

    int flags = fcntl(sockfd, F_GETFL);
    fcntl(sockfd, F_SETFL, flags | O_NONBLOCK);

    return sockfd;
}

int get_accept(int sockfd) {
    struct sockaddr_in conn_addr;
    unsigned int conn_addr_len = (unsigned int)(sizeof(struct sockaddr_in));
    int conn_sockfd = accept4(sockfd, (struct sockaddr *)(&conn_addr), &conn_addr_len, SOCK_NONBLOCK);
    return conn_sockfd;
}

void ffiapi_get_InitiateAttestation(unsigned char *parameter, long parameterSizeBytes, unsigned char *output, long outputSizeBytes) {
  assert(!conn_open);

  if (!listener_open) {
    listener_fd = get_listener(1, "5000");
    assert(listener_fd != -1);
    listener_open = true;
  }
  
  conn_fd = get_accept(listener_fd);
  if (conn_fd == -1)
    output[0] = false;
  else {
    conn_open = true;
    output[0] = true;
  }
}

void ffiapi_send_TerminateAttestation(unsigned char *parameter, long parameterSizeBytes, unsigned char *output, long outputSizeBytes) {
  if(conn_open) {
    close(conn_fd);
    conn_open = false;
  }
  if(listener_open) {
    close(listener_fd);
    listener_open = false;
  }

  return;
}

// Waits until 0.5 seconds after last pacer tick
void ffisb_pacer_notification_wait(unsigned char *parameter, long parameterSizeBytes, unsigned char *output, long outputSizeBytes) {
  static bool firstRun = true;
  static time_t prev;

  if (firstRun) {
    firstRun = false;
    time(&prev);
  } else {
    time_t now;
    time(&now);
    for(; difftime(now, prev) < 0.5; time(&now)) {}
    prev = now;
  }
  output[0] = true;
}

void ffisb_pacer_notification_emit(unsigned char *parameter, long parameterSizeBytes, unsigned char *output, long outputSizeBytes) {
  output[0] = true;
}