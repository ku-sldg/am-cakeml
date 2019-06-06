/*
** Michael Neises
** 3 june 2019
** signature over RSA with SHA512 thumbprint
*/

#include "sig.h"

void signMsg( char* msg, unsigned long long* sig, struct private_key_class* priv )
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

void signFile( char* msgFile, char* sigFile, char* privKeyFile )
{
    // grab the private key
    struct private_key_class* priv = readPriv( privKeyFile );

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
    signMsg( message, mySig, priv );

    // write out the signature to file
    fp = fopen( sigFile, "w+" );
    for( int i=0; i<64; i++ )
    {
        fprintf( fp, "%llu\n", mySig[i] );
    }

    fclose( fp );
    free( message );
    free( mySig );

    return;
}

void readSigFile( unsigned long long* sig, char* sigFile )
{
    // read in the message
    FILE* fp = fopen( sigFile, "r" );

    // read the sig line by line
    unsigned long long buff[1];
    for( int i=0; i<64; i++ )
    {
        fscanf( fp, "%llu", buff );
        sig[i] = buff[0];
    }

    return;
}

int sigVerify( unsigned long long* sig, uint8_t* hash, struct public_key_class* pub )
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

void readFileList( uint8_t* fileString, struct file_list_class* files )
{
    char* fileList = (char*)fileString;
    char fileArray[255];
    strcpy( fileArray, fileList );

    const char s[2] = ";";

    files->msgFile = (char*)dupstr( strtok( fileArray, s ) );
    files->sigFile = (char*)dupstr( strtok( NULL, s ) );
    files->privKeyFile = (char*)dupstr( strtok( NULL, s ) );

    strtok( NULL, s );

    return;
}

