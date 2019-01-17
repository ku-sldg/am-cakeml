CLIENT_LIST = ByteString.sml sockets/SocketFFI.sml sockets/ClientTest.sml
SERVER_LIST = ByteString.sml sockets/SocketFFI.sml sockets/ServerTest.sml

# Change this directory if necessary  -- or
# provide the directory for your machine on the make command-line, e.g.
# make -n   CAKE_DIR="/someOtherLocation/cake-x64-64"
CAKE_DIR = ~/cake-x64-64
CAKEC = $(CAKE_DIR)/cake
BASIS = $(CAKE_DIR)/basis_ffi.c

OS ?= $(shell uname)

ifeq ($(OS),Darwin)
    # These options avoid linker warnings on macOS
    LDFLAGS += -Wl,-no_pie
endif

CC = gcc
CFLAGS = #-Wno-incompatible-pointer-types

.PHONY: all
all: serverTest clientTest

serverTest: ServerTestFull.S socket_ffi.o basis_ffi.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

ServerTestFull.S: ServerTestFull.sml
	$(CAKEC) < ServerTestFull.sml > ServerTestFull.S

ServerTestFull.sml: $(SERVER_LIST)
	cat $^ > $@

clientTest: ClientTestFull.S socket_ffi.o basis_ffi.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

ClientTestFull.S: ClientTestFull.sml
	$(CAKEC) < ClientTestFull.sml > ClientTestFull.S

ClientTestFull.sml: $(CLIENT_LIST)
	cat $^ > $@

socket_ffi.o: sockets/socket_ffi.c
	$(CC) $(CFLAGS) -c sockets/socket_ffi.c

basis_ffi.o: $(BASIS)
	$(CC) $(CFLAGS) -c $(BASIS)

.PHONY: clean
clean:
	rm -f serverTest ServerTestFull.S ServerTestFull.sml clientTest \
	      ClientTestFull.S ClientTestFull.sml socket_ffi.o basis_ffi.o
