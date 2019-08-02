CC = gcc 
OBJS = hasher.o toBinary.o sha512.o

ifeq ($(CC),ccomp)
		CFLAGS = -static -Wall -Werror
else
		CFLAGS = -Wall -Werror -Wmissing-prototypes
endif

all: $(OBJS)

sha512.o: sha512.c sha512.h
		$(CC) $(CFLAGS) -g -c sha512.c

hasher.o: hasher.c toBinary.o
		$(CC) $(CFLAGS) -g -c hasher.c toBinary.c

toBinary.o: toBinary.c toBinary.h
		$(CC) $(CFLAGS) -g -c toBinary.c

clean:
		rm main tests *~ *.o
