
#include "rsaInterface.h"

int main( )
{
    printf( "Generating Keys and Writing to File...\n" );
    genKeys( "primes.txt" );
    struct key_class pub[1];
    printf( "Reading Keys from File...\n" );
    readKey( "/usr/share/myKeys/myPublicKey.txt", pub );

    uint8_t* pubBytes = malloc( 3*sizeof( long long ) );
    keyToString( pub, pubBytes );

    struct key_class pub2[1];
    stringToKey( pubBytes, pub2 );

    
    printf( (char*)pubBytes );

    // compare the keys
    printf( "Comparing Keys...\n" );

    if( pub->modulus != pub2->modulus )
    {
        printf( "Modulus Doesn't Match!\n" );
    }
    else if( pub->exponent != pub2->exponent )
    {
        printf( "Exponent Doesn't Match!\n" );
    }
    else
    {
        printf( "Keys Match!\n" );
    }

    free( pubBytes );

    return(0);
}
