
#ifndef RSAINTERFACE_H
#define RSAINTERFACE_H

#include <sys/stat.h>
#include "rsa.h"

#define KEY_STORAGE "./working/"

int genKeys( char* primesFile );

int decryptFile( char* inputFile, char* outputFile );

int encryptFile( char* inputFile, char* outputFile );

#endif

