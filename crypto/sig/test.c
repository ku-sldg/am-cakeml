
#include "sig.h"

int main()
{
    char* msg = "greetings this is a test";
    unsigned long long* sig = malloc( 64*sizeof(long long) );
    struct key_class* priv = malloc( sizeof( struct key_class ) );
    readKey( "/usr/share/myKeys/myPrivateKey.txt", priv );
    printf( "here\n" );
    signMsgWithKey( msg, sig, priv );
    for( int i=0; i<64; i++ )
    {
        printf( "%llu\n", sig[i] );
    }

    free( sig );
    free( priv );

    return(0);
}
