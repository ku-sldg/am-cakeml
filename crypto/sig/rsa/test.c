
#include "rsaInterface.h"

int main( )
{
    genKeys( "primes.txt" );
    struct key_class* pub = readKey( "./working/myPublicKey.txt" );

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


    return(0);
}
