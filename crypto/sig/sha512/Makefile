CC = gcc
OBJS = hasher.o sha512.o toBinary.o

ifeq ($(CC),ccomp)
		CFLAGS = -static -Wall -Werror
else
		CFLAGS = -Wall -Werror -Wmissing-prototypes
endif

all: $(OBJS)

hasher.o: hasher.c sha512.c sha512.o toBinary.o
		$(CC) $(CFLAGS) -g -c hasher.c toBinary.c

sha512.o: sha512.c sha512.h
		$(CC) $(CFLAGS) -g -c sha512.c

toBinary.o: toBinary.c toBinary.h
		$(CC) $(CFLAGS) -g -c toBinary.c

clean:
		rm main tests *~ *.o
