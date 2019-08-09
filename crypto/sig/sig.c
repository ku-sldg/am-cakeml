/*
** Michael Neises
** 16 July 2019
** signature over RSA with SHA512 thumbprint
*/

#include "sig.h"

void signMsgWithKey( char* msg, unsigned long long* sig, struct key_class* priv )
{
    // hash the message
    uint8_t* hash = malloc( 512*8 );
    mySha512( msg, hash );

    // put each char of hash into a long long, into a list
    // 512 bits = 64 bytes = 64 uint8_t's = 64 chars
    // that is, each long holds the content of 1 char from hash
    unsigned long long* longMsg = malloc( sizeof(long long) * 64 );
    for( int i=0; i<64; i++)
    {
        longMsg[i] = (unsigned long long)hash[i];
    }

    unsigned long long* temp = rsa_long_decrypt( longMsg, 64, priv );

    // write the values to the input pointer sig
    for( int i=0; i<64; i++)
    {
        sig[i] = temp[i];
    }

    free( longMsg );
    free( temp );
    free( hash );

    return;
}

void signMsg( char* msg, unsigned long long* sig )
{
    // grab the private key
    //char priKey[255];
    //strcpy( priKey, KEY_STORAGE );
    //strcat( priKey, "myPrivateKey.txt" );
    struct key_class priv;
    //readKey( priKey, &priv );
    priv.modulus = PRIVATE_KEY_MODULUS;
    priv.exponent = PRIVATE_KEY_EXPONENT;

    // get the signature
    signMsgWithKey( msg, sig, &priv );

    return;
}

void signFile( char* msgFile, char* sigFile, char* privKeyFile )
{
    // grab the private key
    struct key_class* priv = malloc( sizeof( struct key_class ) );
    readKey( privKeyFile, priv );

    // read in the message
    FILE* fp = fopen( msgFile, "r" );
    char* message = 0;
    long msgLen = 0;
    if( fp )
    {
        fseek( fp, 0, SEEK_END );
        msgLen = ftell( fp );
        fseek( fp, 0, SEEK_SET );
        message = malloc( msgLen );
        if( message )
        {
            fread( message, 1, msgLen, fp );
        }
        fclose( fp );
    }

    // sign the message
    unsigned long long* mySig = malloc( sizeof(long long) * 64 );
    signMsgWithKey( message, mySig, priv );

    // write out the signature to file
    fp = fopen( sigFile, "w+" );
    for( int i=0; i<64; i++ )
    {
        fprintf( fp, "%llu\n", mySig[i] );
    }

    fclose( fp );
    free( message );
    free( mySig );
    free( priv );

    return;
}

int sigVerify( unsigned long long* sig, uint8_t* hash, struct key_class* pub )
{
    // transform the signature into what should be the hash
    unsigned long long* longHash = rsa_long_encrypt( sig, 64, pub );

    // longHash hold values of the wrong type,
    // but they should be char-size values,
    // because that's how we signed them
    uint8_t* properHash = malloc( sizeof(uint8_t) * 64);
    for( int i=0; i<64; i++)
    {
        properHash[i] = (uint8_t)longHash[i];
    }

    // compare the computed hash and the expected hash
    for( int i=0; i<64; i++ )
    {
        if( properHash[i] != hash[i] )
        {
            free( longHash );
            free( properHash );
            return( 0 );
        }
    }

    free( longHash );
    free( properHash );

    return( 1 );
}

// parses a signature payload and passes the results to sigVerify
int sigCheck( uint8_t* payload )
{
    // parse the payload for parts
    uint8_t* sig = malloc( 512*sizeof(long long) );
    uint8_t* hash = malloc( 512*sizeof(uint8_t) );
    uint8_t* pubKeyParts = malloc( 3*sizeof(long long) );
    uint8_t* pubMod = malloc( sizeof(long long) );
    uint8_t* pubExp = malloc( sizeof(long long) );
    
    
    //printf( "c sig:\n" );
    for( int i=0; i<512; i++ )
    {
        sig[i] = payload[i];
        //printf( "%X", sig[i] );
    }
    //printf( "\n\n" );

    //printf( "c hash:\n" );
    for( int i=512; i < 576; i++ )
    {
        hash[i-512] = payload[i];
        //printf( "%X", hash[i-512] );
    }
    //printf( "\n\n" );

    for( int i=576; i < 594; i++ )
    {
        pubKeyParts[i-576] = payload[i];
    }

    // parse keyparts for parts lul
    // grab positions of the semi-colons
    int expNow = 0;
    int count = 0;
    for( int i=0; i<18; i++ )
    {
        if( (char)pubKeyParts[i] == ':' )
        {
            if( expNow )
            {
                count = 0;
                break;
            }
            count = 0;
            expNow = 1;
        }
        else if( expNow )
        {
            pubExp[count] = pubKeyParts[i];
            count++;
        }
        else
        {
            pubMod[count] = pubKeyParts[i];
            count++;
        }
    }
      
    // parse the hex-strings for hex-nums
    unsigned long long longPubMod = strtoll( &pubMod[0], (char**)NULL, 16 );
    //printf( "c pub mod: %llX\n", longPubMod );
    unsigned long long longPubExp = strtoll( &pubExp[0], (char**)NULL, 16 );
    //printf( "c pub exp: %llX\n", longPubExp );
    //printf("\n");

    // convert sig
    unsigned long long * mySig = malloc( sizeof(long long) * 64 );
    byteStringToSig( sig, mySig );
    
    // convert pubKey
    struct key_class myPub[1];
    myPub->modulus = longPubMod;
    myPub->exponent = longPubExp;

    // check the signature
    int isGood = sigVerify( mySig, hash, myPub );

    // don't leak memory
    free( sig );
    free( mySig );
    free( hash );
    free( pubKeyParts );
    free( pubMod ); 
    free( pubExp );

    // see how we did
    return( isGood );
}

// if use this, must free the return pointer
char* dupstr( char* src )
{
    char* dst = malloc( strlen(src)+1 );
    if( dst==NULL )
    {
        return( NULL );
    }
    strcpy( dst, src );
    return( dst );
}

// sig is 64 long longs
// byteSig is 512 chars
void sigToByteString( unsigned long long* sig, uint8_t* byteSig )
{
    for( int i=0; i<64; i++ )
    {
        byteSig[8*i] = (uint8_t)( sig[i] >> 56 );
        byteSig[8*i+1] = (uint8_t)(( sig[i] >> 48 ) & 0xFF );
        byteSig[8*i+2] = (uint8_t)(( sig[i] >> 40 ) & 0xFF );
        byteSig[8*i+3] = (uint8_t)(( sig[i] >> 32 ) & 0xFF );
        byteSig[8*i+4] = (uint8_t)(( sig[i] >> 24 ) & 0xFF );
        byteSig[8*i+5] = (uint8_t)(( sig[i] >> 16 ) & 0xFF );
        byteSig[8*i+6] = (uint8_t)(( sig[i] >> 8 ) & 0xFF );
        byteSig[8*i+7] = (uint8_t)( sig[i] & 0xFF );
    }
    return;
}

void byteStringToSig( uint8_t* byteSig, unsigned long long* sig )
{
    for( int i=0; i<64; i++ )
    {
        sig[i]  = ((unsigned long long)byteSig[8*i+0]) << 56;
        sig[i] |= ((unsigned long long)byteSig[8*i+1]) << 48;
        sig[i] |= ((unsigned long long)byteSig[8*i+2]) << 40;
        sig[i] |= ((unsigned long long)byteSig[8*i+3]) << 32;
        sig[i] |= ((unsigned long long)byteSig[8*i+4]) << 24;
        sig[i] |= ((unsigned long long)byteSig[8*i+5]) << 16;
        sig[i] |= ((unsigned long long)byteSig[8*i+6]) << 8;
        sig[i] |= (unsigned long long)byteSig[8*i+7];
    }
    return;
}

