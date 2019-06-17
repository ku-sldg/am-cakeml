
#ifndef HASHER_H
#define HASHER_H

#include "../../sha512.h"
#include "toBinary.h"
#include <stdio.h>
#include <stdlib.h>

void printHash( uint8_t* myHash );

uint8_t* mySha512( char* inputString );

uint8_t* hashFile( char* filepath );

unsigned long long hashToNum( uint8_t* myHash );

#endif

