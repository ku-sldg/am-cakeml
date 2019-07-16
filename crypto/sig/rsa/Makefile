CC = ccomp
OBJS = utils.o rsa.o rsaInterface.o

ifeq ($(CC),ccomp)
		CFLAGS = -static -Wall -Werror
else
		CFLAGS = -Wall -Werror -Wmissing-prototypes
endif

all: genKeys rsaInterface.o

genKeys: genKeys.c rsaInterface.o
		$(CC) $(CFLAGS) $(OBJS) genKeys.c -o genKeys -lm
		
rsaInterface.o: rsaInterface.h rsaInterface.c rsa.o
		$(CC) $(CFLAGS) -g -c rsaInterface.c

rsa.o: rsa.h rsa.c utils.o
	$(CC) $(CFLAGS) -g -c rsa.c

utils.o: utils.c utils.h
	$(CC) $(CFLAGS) -g -c utils.c

test: rsaInterface.o test.c
	$(CC) $(CFLAGS) $(OBJS) test.c -o test -lm

.PHONY: all

clean:
	rm -f *.o genKeys working/* test
	rmdir working

