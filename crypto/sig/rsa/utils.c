
/*
** Michael Neises
** 30 May 19
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

struct public_key_class* readPub( char* filename )
{
    struct public_key_class* pub = malloc( sizeof(struct public_key_class) );;

    FILE* fp;
    char buf[255];
    fp = fopen( filename, "r" );

    fgets( buf, 255, fp );
    fgets( buf, 255, fp );
    pub->modulus = keyExtract( buf );
    fgets( buf, 255, fp );
    pub->exponent = keyExtract( buf );
    return( pub );
}

struct private_key_class* readPriv( char* filename )
{
    struct private_key_class* priv = malloc( sizeof(struct public_key_class) );;

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

