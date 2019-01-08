# NOTE: the order of this list must reflect code dependencies
APPEND_LIST = ByteString.sml CoqDefaults.sml CoplandLang.sml crypto/Crypto.sml \
              Measurements.sml Eval.sml Main.sml

# Change this directory if necessary
CAKE_DIR = ~/cake-x64-64
CAKEC = $(CAKE_DIR)/cake
BASIS = $(CAKE_DIR)/basis_ffi.c

CC = gcc
# BUILD_DIR = build

apdt: apdt.S basis_ffi.o sha512.o crypto_ffi.o
	$(CC) -o apdt apdt.S basis_ffi.o sha512.o crypto_ffi.o

apdt.S: apdt.sml
	$(CAKEC) < apdt.sml > apdt.S

apdt.sml: $(APPEND_LIST)
	buildscripts/cakeappender.py -o apdt.sml $(APPEND_LIST)

sha512.o: crypto/sha512.c crypto/sha512.h
	$(CC) -c crypto/sha512.c

crypto_ffi.o: crypto/crypto_ffi.c crypto/sha512.h
	$(CC) -c crypto/crypto_ffi.c

basis_ffi.o: $(BASIS)
	$(CC) -c $(BASIS)

.PHONY: clean
clean:
	rm -f apdt apdt.S apdt.sml sha512.o crypto_ffi.o basis_ffi.o
