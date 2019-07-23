
#include "rsaInterface.h"

int main( )
{
    genKeys( "primes.txt" );
    struct key_class* pub = malloc( sizeof( struct key_class ) );
    readKey( "./working/myPublicKey.txt", pub );

    uint8_t* pubBytes = malloc( 3*sizeof( long long ) );
    keyToString( pub, pubBytes );

    struct key_class pub2[1];
    stringToKey( pubBytes, pub2 );

    
    printf( (char*)pubBytes );
    printf( "\n" );

    // compare the keys

    if( pub->modulus != pub2->modulus )
    {
        printf( "wrong mod\n" );
    }
    else if( pub->exponent != pub2->exponent )
    {
        printf( "wrong exp\n" );
    }
    else
    {
        printf( "keys match!\n" );
    }

    free( pub );
    free( pubBytes );
    free( pub2 );

    return(0);
}
