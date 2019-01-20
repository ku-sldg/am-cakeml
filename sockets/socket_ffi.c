// FFI interface to UNIX-style network sockets.

// This socket interface is largely based on the example provided in the
// getaddrinfo man page http://man7.org/linux/man-pages/man3/getaddrinfo.3.html

#include <assert.h>     // asserts
#include <stdint.h>     // uint8_t, uint16_6, etc.
#include <sys/types.h>  // socket, bind, listen, getaddrinfo
#include <sys/socket.h> // socket, bind, listen, getaddrinfo
#include <netdb.h>      // getaddrinfo
#include <string.h>     // memset, strerror
#include <unistd.h>     // close
#include <stdio.h>      // fprintf
#include <stdlib.h>     // exit
#include <errno.h>      // errno
// #include <fcntl.h>      // fcntl

// These helper functions are defined in basis_ffi.c
// I figured it would be good to use the same marshalling paradigm as the
// provided FFI functions when possible.
// However, I'm not sure why ints (usually 4 bytes) are converted back and forth
// to 8-byte arrays.
int byte2_to_int(uint8_t *b);
void int_to_byte2(int i, uint8_t *b);
int byte8_to_int(uint8_t *b);
void int_to_byte8(int i, uint8_t *b);

// Error helper functions. Similar to asserts, but unconditional and with a msg
#ifndef NDEBUG
#define fatalErr(msg) __fatalErr(msg, __FILE__, __LINE__)
#define nonfatalErr(msg) __nonfatalErr(msg, __FILE__, __LINE__)
void __fatalErr(const char * msg, const char * file, int line) {
    fprintf(stderr, "%s:%d: Fatal error: %s\n", file, line, msg);
    abort();
}
void __nonfatalErr(const char * msg, const char * file, int line) {
    fprintf(stderr, "%s:%d: Nonfatal error: %s\n", file, line, msg);
}
#else
#define fatalErr(msg)
#define nonfatalErr(msg)
#endif

////////////////////////////////////////////////////////////////////////////////
// Server functions:                                                          //
////////////////////////////////////////////////////////////////////////////////

// Arguments: qlen (first 2 bytes of c), and port, a string representation of a
//     number, following qlen
// Returns: sockfd as 64-bit int in a
void ffilisten(uint8_t * c, long clen, uint8_t * a, long alen) {
    assert(clen >= 2);
    assert(alen >= 8);

    // Parse arguments
    int qlen = byte2_to_int(c);
    char * port = c+2;

    struct addrinfo hints;
    memset(&hints, 0, sizeof(struct addrinfo));
    // AF_INET specifies the IPv4 Internet protocols
    hints.ai_family = AF_INET;
    // SOCK_STREAM specifies "sequenced, reliable, two-way, connection-based
    // byte streams."
    hints.ai_socktype = SOCK_STREAM;
    // Passive flag + null node in getaddrinfo invocation indicates suitability
    // for accepting connections
    hints.ai_flags = AI_PASSIVE;
    struct addrinfo * result;
    int gai_ret = getaddrinfo(0, port, &hints, &result);
    if (gai_ret) fatalErr(gai_strerror(gai_ret));

    int sockfd;
    struct addrinfo * r;
    for (r = result; r; r = r->ai_next) {
        sockfd = socket(r->ai_family, r->ai_socktype, r->ai_protocol);
        if (sockfd == -1)
            continue;

        int enable = 1;
        if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &enable, sizeof(enable)))
            nonfatalErr(strerror(errno));

        if (bind(sockfd, r->ai_addr, r->ai_addrlen)) {
            nonfatalErr(strerror(errno));
            close(sockfd);
        }
        else
            break;
    }
    assert(r);
    assert(sockfd != -1);
    freeaddrinfo(result);

    // Listen for incoming connections, with a maximum queue length of qlen
    listen(sockfd, qlen);

    // return sockfd
    int_to_byte8(sockfd, a);
}

// Argument: sockfd as 64-bit int in a
// Returns: conn_sockfd as 64-bit int in a
// Blocks until there is an incoming connection
void ffiaccept(uint8_t * c, long clen, uint8_t * a, long alen) {
    assert(clen >= 8);
    assert(alen >= 8);

    // Parse argument
    int sockfd = byte8_to_int(c);

    struct sockaddr_in conn_addr;
    int conn_addr_len = sizeof(struct sockaddr_in);
    // accept returns the sockfd corresponding to the first connection in the
    // incoming queue. If there is none, blocks until there is.
    int conn_sockfd = accept(sockfd, (struct sockaddr *)(&conn_addr), &conn_addr_len);
    assert(conn_sockfd != -1);

    // Set nonblocking
    // int flags = fcntl(conn_sockfd, F_GETFL, 0);
    // fcntl(conn_sockfd, F_SETFL, flags | O_NONBLOCK);

    // return conn_sockfd
    int_to_byte8(conn_sockfd, a);
}

////////////////////////////////////////////////////////////////////////////////
// Client functions:                                                          //
////////////////////////////////////////////////////////////////////////////////

// Arguments: host and port, both stored in that order in c, delimited by a null
//     byte. host is a domain name or ip address, as a string. port is a number,
//     again as a string. port should be followed by a final null byte.
// Returns: sockfd as 64-bit int in a
void fficonnect(uint8_t * c, long clen, uint8_t * a, long alen) {
    assert(clen >= 2); // Assumes there are at least the null byte delimiter and terminator
    assert(alen >= 8);

    // Parse arguments
    char * host = c;
    char * port = c + strlen(c) + 1;

    struct addrinfo hints;
    memset(&hints, 0, sizeof(struct addrinfo));
    // AF_INET specifies the IPv4 Internet protocols
    hints.ai_family = AF_INET;
    // SOCK_STREAM specifies "sequenced, reliable, two-way, connection-based
    // byte streams."
    hints.ai_socktype = SOCK_STREAM;
    struct addrinfo * result;
    int gai_ret = getaddrinfo(host, port, &hints, &result);
    if (gai_ret) fatalErr(gai_strerror(gai_ret));

    int sockfd;
    struct addrinfo * r;
    for (r = result; r; r = r->ai_next) {
        sockfd = socket(r->ai_family, r->ai_socktype, r->ai_protocol);
        if (sockfd == -1)
            continue;

        if (connect(sockfd, r->ai_addr, r->ai_addrlen)) {
            nonfatalErr(strerror(errno));
            close(sockfd);
        }
        else
            break;
    }
    assert(r);
    assert(sockfd != -1);
    freeaddrinfo(result);

    // Set nonblocking
    // int flags = fcntl(sockfd, F_GETFL, 0);
    // fcntl(sockfd, F_SETFL, flags | O_NONBLOCK);

    // return sockfd
    int_to_byte8(sockfd, a);
}
