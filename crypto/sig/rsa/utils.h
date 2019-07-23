
#ifndef UTILS_H
#define UTILS_H

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

struct key_class
{
    unsigned long long modulus;
    unsigned long long exponent;
};

unsigned long long keyExtract( char* phrase );

void composeKey( uint8_t* mod, uint8_t* exp, struct key_class* myKey );

void readKey( char* filename, struct key_class* myKey);

unsigned long long* longChunk( char* sentence );

void longToBytes( unsigned long long input, uint8_t* output );

void bytesToLong( uint8_t* input, unsigned long long* output );

void keyToString( struct key_class* inKey, uint8_t* outKey );

void stringToKey( uint8_t* outKey, struct key_class* inKey );

#endif

