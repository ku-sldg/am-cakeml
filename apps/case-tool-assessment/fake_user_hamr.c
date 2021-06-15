#include <stdio.h>
#include <stdbool.h>
#include <assert.h>
#include <string.h>

#include <unistd.h> 
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <fcntl.h>

// Globals
bool listener_open = false;
int listener_fd;
bool heliam_connected = false;
int heliam_fd;

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
    if (!r || sockfd == -1) {
        printf("%i\n", sockfd);

        return -1;
    }

    // Listen for incoming connections, with a maximum queue length of qlen
    if (listen(sockfd, qlen)) {
        return -1;
    }

    int flags = fcntl(sockfd, F_GETFL);
    fcntl(sockfd, F_SETFL, flags | O_NONBLOCK);

    return sockfd;
}

int get_accept(int sockfd) {
    struct sockaddr_in conn_addr;
    unsigned int conn_addr_len = (unsigned int)(sizeof(struct sockaddr_in));
    int conn_sockfd = accept(sockfd, (struct sockaddr *)(&conn_addr), &conn_addr_len);
    return conn_sockfd;
}

void try_connect_heliam() {
    if (!listener_open) {
        listener_fd = get_listener(1, "5000");
        assert(listener_fd != -1);
    }

    heliam_fd = get_accept(listener_fd);
    heliam_connected = heliam_fd >= 0;
}

void ffiapi_send_AttestationResponse(unsigned char *parameter, long parameterSizeBytes, unsigned char *output, long outputSizeBytes) {
    assert(parameterSizeBytes == 2048);
    assert(heliam_connected);

    // printf("about to write\n");
    write(heliam_fd, (const void*)parameter, 2048);
}

void ffiapi_get_AttestationRequest(unsigned char *parameter, long parameterSizeBytes, unsigned char *output, long outputSizeBytes) {
    assert(outputSizeBytes == 17);

    while(!heliam_connected)
        try_connect_heliam();

    // printf("about to read\n");
    ssize_t n_read = read(heliam_fd, ((void *)output)+1, 16);
    if(n_read <= 0)
        printf("No request\n");
    else
        printf("yes request\n");
    output[0] = n_read > 0;
}