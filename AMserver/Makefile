SERVER_LIST = ../ByteString.sml ../crypto/CryptoFFI.sml ../crypto/Aes256.sml \
    ../crypto/Random.sml ../sockets/SocketFFI.sml ../CoqDefaults.sml \
    ../CoplandLang.sml ../Measurements.sml CommTypes.sml ../JSON/Json.sml \
    ../JSON/JsonToCopland.sml ../JSON/CoplandToJson.sml CommUtil.sml \
    ../Eval.sml AMserver.sml

CLIENT_LIST = ../ByteString.sml ../sockets/SocketFFI.sml ../JSON/Json.sml \
    ../CoqDefaults.sml ../CoplandLang.sml CommTypes.sml \
    ../JSON/JsonToCopland.sml ../JSON/CoplandToJson.sml CommUtil.sml \
	ClientTest.sml

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

DEBUG = true
ifeq ($(DEBUG), true)
	CFLAGS += -ggdb3
else
	CFLAGS = -DNDEBUG
endif

CC = gcc
# CFLAGS =


.PHONY: all
all: server client

server: Server.S sha512.o aes256.o crypto_ffi.o socket_ffi.o basis_ffi.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

Server.S: Server.sml
	$(CAKEC) < $^ > $@

Server.sml: $(SERVER_LIST)
	cat $^ > $@

client: Client.S socket_ffi.o basis_ffi.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

Client.S: Client.sml
	$(CAKEC) < $^ > $@

Client.sml: $(CLIENT_LIST)
	cat $^ > $@

sha512.o: ../crypto/sha512.c ../crypto/sha512.h
	$(CC) $(CFLAGS) -c ../crypto/sha512.c

aes256.o: ../crypto/aes256.c ../crypto/aes256.h
	$(CC) $(CFLAGS) -c ../crypto/aes256.c

crypto_ffi.o: ../crypto/crypto_ffi.c ../crypto/sha512.h ../crypto/aes256.h
	$(CC) $(CFLAGS) -c ../crypto/crypto_ffi.c

socket_ffi.o: ../sockets/socket_ffi.c
	$(CC) $(CFLAGS) -c ../sockets/socket_ffi.c

basis_ffi.o: $(BASIS)
	$(CC) $(CFLAGS) -c $(BASIS)

.PHONY: clean
clean:
	rm -f server Server.S Server.sml client Client.S Client.sml \
	      sha512.o aes256.o crypto_ffi.o socket_ffi.o basis_ffi.o
