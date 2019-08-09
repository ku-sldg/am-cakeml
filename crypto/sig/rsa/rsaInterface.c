/*
** Michael Neises
** 29 May 2019
** Interface with the rsa library for sanity
*/

#include "rsaInterface.h"
#include <unistd.h>

int genKeys( char* primesFile )
{
    struct key_class pub[1];
    struct key_class priv[1];
    rsa_gen_keys( pub, priv, primesFile );

    unsigned long long n = pub->modulus;
    while( ( (n-1)*(n-1)/(n-1)!=(n-1) ) )
    {
        sleep(1);
        rsa_gen_keys( pub, priv, primesFile );
        n = pub->modulus;
    }

    struct stat st = {0};
    if ( stat( KEY_STORAGE, &st) == -1 ) 
    {
        mkdir( KEY_STORAGE, 0700);
    }

    FILE* fp;

    char pubKey[255];
    strcpy( pubKey, KEY_STORAGE );
    strcat( pubKey, "myPublicKey.txt" );
    fp = fopen( pubKey, "w+" );
    fprintf( fp, "Public Key:\nModulus: %llX\nExponent: %llX\n", pub->modulus, pub->exponent );
    fclose( fp );    

    char priKey[255];
    strcpy( priKey, KEY_STORAGE );
    strcat( priKey, "myPrivateKey.txt" );
    fp = fopen( priKey, "w+" );
    fprintf( fp, "Private Key:\nModulus: %llX\nExponent: %llX\n", priv->modulus, priv->exponent );
    fclose( fp );

    return( 0 );
}

int decryptFile( char* inputFile, char* outputFile )
{
    char priKey[255];
    strcpy( priKey, KEY_STORAGE );
    strcat( priKey, "myPrivateKey.txt" );
    struct key_class* priv = malloc( sizeof( struct key_class ) );
    readKey( priKey, priv );
    char* msgFile = inputFile;
    int i;
    FILE* fp = fopen( msgFile, "r" );

    char* message = 0;
    long cipherLen = 0;
    if (fp)
    {
        fseek (fp, 0, SEEK_END);
        cipherLen = ftell (fp);
        fseek (fp, 0, SEEK_SET);
        message = malloc (cipherLen);
        if (message)
        {
            fread (message, 1, cipherLen, fp);
        }
        fclose (fp);
    }

    if (message)
    {
        // chunk message into a list of long longs
        unsigned long long* longMsg = longChunk( message );

        // get the number of long longs in the list
        const unsigned long msgLen = cipherLen/8;

        char* decrypted = rsa_char_decrypt(longMsg, msgLen, priv);
        if (!decrypted){
            fprintf(stderr, "Error in decryption!\n");
            return 1;
        }

        fp = fopen( outputFile, "w+" );

        for(i=0; i < msgLen; i++){
            fprintf( fp, "%c", decrypted[i] );
            if( (unsigned long long)decrypted[i] == 0 )
            {
                break;
            }
        }  
        free( decrypted );

    }
    free( priv );
    free( message );

    return( 0 );
}

int encryptFile( char* inputFile, char* outputFile )
{
    char pubKey[255];
    strcpy( pubKey, KEY_STORAGE );
    strcat( pubKey, "myPublicKey.txt" );
    struct key_class* pub = malloc( sizeof( struct key_class ) );
    readKey( pubKey, pub );
    char* msgFile = inputFile;
    int i;
    FILE* fp = fopen( msgFile, "r" );

    char* message = 0;
    if (fp)
    {
        fseek (fp, 0, SEEK_END);
        long length = ftell (fp);
        fseek (fp, 0, SEEK_SET);
        message = malloc (length);
        if (message)
        {
            fread (message, 1, length, fp);
        }
        fclose (fp);
    }

    if (message)
    {

        unsigned long long *encrypted = rsa_char_encrypt(message, strlen(message), pub);
        if (!encrypted){
            fprintf(stderr, "Error in encryption!\n");
            return 1;
        }

        fp = fopen( outputFile, "w+" );

        for(i=0; i < strlen(message); i++){
            fprintf( fp, "%llu\n", (unsigned long long)encrypted[i] );
        }  
        free( encrypted );

    }
    free( pub );
    free( message );

    return( 0 );
}














