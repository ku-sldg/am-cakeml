CC = ccomp
CFLAGS = -Wall -Werror -Wmissing-prototypes
OBJS = sha512/hasher.o ../../sha512.o sha512/toBinary.o rsa/utils.o rsa/rsa.o rsa/rsaInterface.o sig.o

SUBDIRS = ./sha512 ./rsa

ifeq ($(CC),ccomp)
		CFLAGS = -static -Wall -Werror
endif

all: $(SUBDIRS) sig.o

$(SUBDIRS):
		$(MAKE) -C $@

sig.o: sig.h sig.c rsa/rsa.h
		$(CC) $(CFLAGS) -g -c sig.c

test: all test.c
		$(CC) $(CFLAGS) $(OBJS) test.c -o test -lm

.PHONY: all $(SUBDIRS)

clean: 
	rm -f *.o test sigFile testMsg
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir -f Makefile $@; \
	done
