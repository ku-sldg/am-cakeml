// FFI interface to POSIX-style network sockets.

#include <assert.h>     // asserts
#include <stdint.h>     // uint8_t, uint16_6, etc.
#include <sys/types.h>  // socket, bind, listen, getaddrinfo
#include <sys/socket.h> // socket, bind, listen, getaddrinfo
#include <netdb.h>      // getaddrinfo
#include <netinet/in.h> // struct sockaddr_in
#include <string.h>     // memset
#include <unistd.h>     // close

// These helper functions are defined in basis_ffi.c
// I figured it would be good to use the same marshalling paradigm as the
// provided FFI functions when possible.
// However, I'm not sure why ints (usually 4 bytes) are converted back and forth
// to 8 byte arrays.
int byte2_to_int(uint8_t *b);
void int_to_byte2(int i, uint8_t *b);
int byte8_to_int(uint8_t *b);
void int_to_byte8(int i, uint8_t *b);


// Server functions:

// Arguments: portnum (first 2 bytes of c), qlen (second 2 bytes of c)
// Returns: sockfd as 64-bit int in a
void ffilisten(uint8_t * c, long clen, uint8_t * a, long alen) {
    assert(clen >= 4);
    assert(alen >= 8);

    // Parse arguments
    uint16_t portnum = byte2_to_int(c);
    int qlen = byte2_to_int(c+2);

    // AF_INET specifies the IPv4 Internet protocols
    // SOCK_STREAM specifies "sequenced, reliable, two-way, connection-based
    // byte streams."
    int sockfd = socket(AF_INET, SOCK_STREAM, 0);
    assert(sockfd != -1);

    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(struct sockaddr_in));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(portnum); // htons converts a short to network byte order
    addr.sin_addr.s_addr = INADDR_ANY;
    // Bind the socket fd to an address
    int errorFlag = bind(sockfd, (struct sockaddr *)(&addr), sizeof(struct sockaddr_in));
    assert(errorFlag != -1);

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

    // return conn_sockfd
    int_to_byte8(conn_sockfd, a);
}


// Client functions:

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
    // SOCK_STREAM specifies "sequenced, reliable, two-way, connection-based
    // byte streams."
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    struct addrinfo * result;
    getaddrinfo(host, port, &hints, &result);

    int sockfd;
    struct addrinfo * r;
    for (r = result; r; r = r->ai_next) {
        int sockfd = socket(r->ai_family, r->ai_socktype, r->ai_protocol);
        if (sockfd == -1)
            continue;

        if (connect(sockfd, r->ai_addr, r->ai_addrlen) != -1)
            break;

        close(sockfd);
    }
    assert(r && (sockfd != -1));
    freeaddrinfo(result);

    // return sockfd
    int_to_byte8(sockfd, a);
}
