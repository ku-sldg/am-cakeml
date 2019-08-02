
#include "sig.h"

int main()
{
    char* msg = "greetings this is a test";
    unsigned long long* sig = malloc( 64*sizeof(long long) );
    struct key_class priv[1];
    readKey( "/usr/share/myKeys/myPrivateKey.txt", priv );
    printf( "here\n" );
    
    signMsgWithKey( msg, sig, priv );
    for( int i=0; i<64; i++ )
    {
        printf( "%llu\n", sig[i] );
    }

    uint8_t* hash = malloc( 512*8 );
    mySha512( msg, hash );

    struct key_class pub[1];
    readKey( "/usr/share/myKeys/myPublicKey.txt", pub );
    int whether = sigVerify( sig, hash, pub );
    
    printf( "\n%s\n", whether?"yes":"no" );

    free( sig );
    free( hash );

    return(0);
}
