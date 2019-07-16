
/*
** Michael Neises
** 16 July 2019
** some helper functions for use with the rsa library
*/

#include "utils.h"

unsigned long long keyExtract( char* phrase )
{
    char * pch;
    pch = strtok ( phrase, " " );
    pch = strtok (NULL, " ");
    return( (unsigned long long)(strtoll( pch, (char**) NULL, 10 ) ) );
}

struct key_class* readKey( char* filename )
{
    struct key_class* priv = malloc( sizeof(struct key_class) );;

    FILE* fp;
    char buf[255];
    fp = fopen( filename, "r" );

    fgets( buf, 255, fp );
    fgets( buf, 255, fp );
    priv->modulus = keyExtract( buf );
    fgets( buf, 255, fp );
    priv->exponent = keyExtract( buf );

    return( priv );
}

unsigned long long* longChunk( char* sentence )
{
    unsigned long long* out = malloc( sizeof(unsigned long long) * strlen( sentence ) );

    char * pch;
    pch = strtok (sentence," \n");
    int i = 0;
    while ( pch != NULL && pch[0]!='\0' )
    {
        out[i] = (unsigned long long)(strtoll( pch, (char**) NULL, 10 ) );
        pch = strtok (NULL, " \n");
        i++;
    }

    return( out );
}

void longToBytes( unsigned long long input, uint8_t* output )
{
    output[0] = (uint8_t)( input >> 56 );
    output[1] = (uint8_t)( ( input >> 48 ) & 0xFF );
    output[2] = (uint8_t)( ( input >> 40 ) & 0xFF );
    output[3] = (uint8_t)( ( input >> 32 ) & 0xFF );
    output[4] = (uint8_t)( ( input >> 24 ) & 0xFF );
    output[5] = (uint8_t)( ( input >> 16 ) & 0xFF );
    output[6] = (uint8_t)( ( input >> 8 ) & 0xFF );
    output[7] = (uint8_t)( input & 0xFF );
    return;
}

void bytesToLong( uint8_t* input, unsigned long long* output )
{
    output[0]  = ((unsigned long long)input[0]) << 56;
    output[0] |= ((unsigned long long)input[1]) << 48;
    output[0] |= ((unsigned long long)input[2]) << 40;
    output[0] |= ((unsigned long long)input[3]) << 32;
    output[0] |= ((unsigned long long)input[4]) << 24;
    output[0] |= ((unsigned long long)input[5]) << 16;
    output[0] |= ((unsigned long long)input[6]) << 8;
    output[0] |= (unsigned long long)input[7];
    return;
}

void keyToString( struct key_class* inKey, uint8_t* outKey )
{
    uint8_t* modPart = malloc( sizeof( long long ) );
    longToBytes( inKey->modulus, modPart );

    uint8_t* expPart = malloc( sizeof( long long ) );
    longToBytes( inKey->exponent, expPart );

    for( int i=0; i<8; i++ )
    {
        outKey[i] = modPart[i];
    }
    outKey[9] = '\0';
    for( int i=0; i<8; i++ )
    {
        outKey[10+i] = expPart[i];
    }
    outKey[18] = '\0';

    return;
}

void stringToKey( uint8_t* inKey, struct key_class* outKey )
{
    uint8_t modS[8];
    uint8_t expS[8];
    for( int i=0; i<8; i++ )
    {
        modS[i] = inKey[i];
        expS[i] = inKey[10+i];
    }

    bytesToLong( modS, &outKey->modulus );
    bytesToLong( expS, &outKey->exponent );
    return;
}

