# NOTE: the order of this list must reflect code dependencies
APPEND_LIST = ByteString.sml crypto/CryptoFFI.sml crypto/Aes256.sml \
    crypto/Random.sml sockets/SocketFFI.sml CoqDefaults.sml CoplandLang.sml \
    Measurements.sml AMserver/CommTypes.sml JSON/Json.sml \
    JSON/CoplandToJson.sml JSON/JsonToCopland.sml AMserver/CommUtil.sml \
    Eval.sml Main.sml

SIG_OBJS = crypto/sig/rsa/rsa.o crypto/sig/rsa/rsaInterface.o \
    crypto/sig/rsa/utils.o crypto/sig/sha512/hasher.o \
    crypto/sig/sha512/toBinary.o

# Change this directory if necessary  -- or
# provide the directory for your machine on the make command-line, e.g.
# make -n   CAKE_DIR="/someOtherLocation/cake-x64-64"
CAKE_DIR = ~/cake-x64-32
CAKEC = $(CAKE_DIR)/cake
BASIS = $(CAKE_DIR)/basis_ffi.c

OS ?= $(shell uname)

ifeq ($(OS),Darwin)
    # These options avoid linker warnings on macOS
    LDFLAGS += -Wl,-no_pie
endif

CC = ccomp
CFLAGS = -static -Wall # -Werror -Wno-incompatible-pointer-types
# BUILD_DIR = build

apdt: apdt.S sha512.o aes256.o sig.o $(SIG_OBJS) crypto_ffi.o socket_ffi.o basis_ffi.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^ -lm

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

socket_ffi.o: sockets/socket_ffi.c
	$(CC) $(CFLAGS) -c sockets/socket_ffi.c

sig.o: crypto/sig/sig.h
	cd crypto/sig && make && cp sig.o ../../ && cd rsa && ./genKeys

basis_ffi.o: $(BASIS)
	$(CC) $(CFLAGS) -c $(BASIS)

.PHONY: clean
clean:
	rm -f apdt apdt.S apdt.sml sha512.o aes256.o sig.o crypto_ffi.o socket_ffi.o basis_ffi.o
	cd crypto/sig && make clean
