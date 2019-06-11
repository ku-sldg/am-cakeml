
#ifndef UTILS_H
#define UTILS_H

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

struct public_key_class
{
    unsigned long long modulus;
    unsigned long long exponent;
};

struct private_key_class
{
    unsigned long long modulus;
    unsigned long long exponent;
};

unsigned long long keyExtract( char* phrase );

struct public_key_class* readPub( char* filename );

struct private_key_class* readPriv( char* filename );

unsigned long long* longChunk( char* sentence );

#endif

