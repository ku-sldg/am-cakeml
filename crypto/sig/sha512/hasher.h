
#ifndef HASHER_H
#define HASHER_H

#include "../../sha512.h"
#include "toBinary.h"
#include <stdio.h>
#include <stdlib.h>

void printHash( uint8_t* myHash );

void mySha512( char* inputString, uint8_t* output );

void hashFile( char* filepath, uint8_t* output );

unsigned long long hashToNum( uint8_t* myHash );

#endif

