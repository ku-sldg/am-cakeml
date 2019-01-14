# NOTE: the order of this list must reflect code dependencies
APPEND_LIST = ByteString.sml CoqDefaults.sml CoplandLang.sml \
		      crypto/CryptoFFI.sml crypto/Aes256.sml crypto/Random.sml \
			  Measurements.sml Eval.sml Main.sml

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
# BUILD_DIR = build

apdt: apdt.S basis_ffi.o sha512.o aes256.o crypto_ffi.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o apdt apdt.S basis_ffi.o sha512.o aes256.o crypto_ffi.o

apdt.S: apdt.sml
	$(CAKEC) < apdt.sml > apdt.S

apdt.sml: $(APPEND_LIST)
	cat $^ > $@

sha512.o: crypto/sha512.c crypto/sha512.h
	$(CC) $(CFLAGS) -c crypto/sha512.c

aes256.o: crypto/aes256.c crypto/aes256.h
	$(CC) $(CFLAGS) -c crypto/aes256.c

crypto_ffi.o: crypto/crypto_ffi.c crypto/sha512.h crypto/aes256.h
	$(CC) $(CFLAGS) -c crypto/crypto_ffi.c

basis_ffi.o: $(BASIS)
	$(CC) $(CFLAGS) -c $(BASIS)

.PHONY: clean
clean:
	rm -f apdt apdt.S apdt.sml sha512.o aes256.o crypto_ffi.o basis_ffi.o
