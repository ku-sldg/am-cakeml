# NOTE: the order of this list must reflect code dependencies
APPEND_LIST = ../ByteString.sml ../CoqDefaults.sml ../CoplandLang.sml ../CommTypes.sml \
		      Json.sml JsonToApdt.sml  CoplandToJson.sml testJ2A.sml

# Change this directory if necessary
CAKE_DIR = ~/cake-x64-64
CAKEC = $(CAKE_DIR)/cake
BASIS = $(CAKE_DIR)/basis_ffi.c

ifeq (,$(wildcard $(CAKEC)))
$(error Cake compiler not found at:  $(CAKEC), perhaps CAKE_DIR is not set correctly.)
endif

OS ?= $(shell uname)

ifeq ($(OS),Darwin)
	# These options avoid linker warnings on macOS
	LDFLAGS += -Wl,-no_pie
endif

CC = gcc
# BUILD_DIR = build

 .DELETE_ON_ERROR :

j2apdt : j2apdt.cake.S basis_ffi.o
	$(CC) $(LDFLAGS) $< basis_ffi.o $(LOADLIBES) $(LDLIBS) -o $@
	rm j2apdt.sml j2apdt.cake.S

basis_ffi.o: $(BASIS)
	$(CC) $(CFLAGS) -c $< -o $@


j2apdt.sml : $(APPEND_LIST)
	cat $^ > $@

%.cake.S : %.sml
	$(CAKEC) $(CAKEFLAGS) <$< >$@

%.cake : %.cake.S
	$(CC) $(LDFLAGS) $< $(BASIS) $(LOADLIBES) $(LDLIBS) -o $@

.PHONY: clean
clean:
	rm -f *.S *.cake j2apdt j2apdt.sml *.o
