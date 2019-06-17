CC = ccomp
OBJS = hasher.o toBinary.o

ifeq ($(CC),ccomp)
		CFLAGS = -static -Wall -Werror
else
		CFLAGS = -Wall -Werror -Wmissing-prototypes
endif

all: $(OBJS)

hasher.o: hasher.c toBinary.o
		$(CC) $(CFLAGS) -g -c hasher.c toBinary.c

toBinary.o: toBinary.c toBinary.h
		$(CC) $(CFLAGS) -g -c toBinary.c

clean:
		rm main tests *~ *.o
