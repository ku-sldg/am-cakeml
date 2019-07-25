/*
** Michael Neises
** 16 July 2019
** signature over RSA with SHA512 thumbprint
*/

#include "sig.h"

void signMsgWithKey( char* msg, unsigned long long* sig, struct key_class* priv )
{
    // hash the message
    uint8_t* hash = mySha512( msg );

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

    return;
}

void signMsg( char* msg, unsigned long long* sig )
{
    // grab the private key
    char priKey[255];
    strcpy( priKey, KEY_STORAGE );
    strcat( priKey, "myPrivateKey.txt" );
    struct key_class priv;
    readKey( priKey, &priv );
    // priv.modulus = PRIVATE_KEY_MODULUS;
    // priv.exponent = PRIVATE_KEY_EXPONENT;

    // get the signature
    signMsgWithKey( msg, sig, &priv );
    free( priv );

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

int sigCheck( uint8_t* payload )
{
    // parse the payload for parts
    char* aSig = (char*)payload;
    char* aHash = (char*)payload + strlen( aSig ) + 1;
    char* aPubMod = (char*)payload + strlen( aSig ) + 1 + strlen( aHash ) + 1;
    char* aPubExp = (char*)payload + strlen( aSig ) + 1 + strlen( aHash ) + 1 + strlen( aPubMod ) + 1;

    // make the proper casts
    uint8_t* sig = (uint8_t*)aSig;
    uint8_t* hash = (uint8_t*)aHash;
    uint8_t* pubMod = (uint8_t*)aPubMod;
    uint8_t* pubExp = (uint8_t*)aPubExp;

    // convert sig
    unsigned long long * mySig = malloc( sizeof(long long) * 64 );
    byteStringToSig( sig, mySig );
    
    // convert pubKey
    struct key_class myPub[1];
    composeKey( pubMod, pubExp, myPub );

    // check the signature
    int isGood = sigVerify( mySig, hash, myPub );

    // don't leak memory
    free( mySig );
    free( myPub );

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
