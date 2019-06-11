/*
** Michael Neises
** 29 May 2019
** Interface with the rsa library for sanity
*/

#include "rsaInterface.h"
#include <unistd.h>

int genKeys( char* primesFile )
{
    struct public_key_class pub[1];
    struct private_key_class priv[1];
    rsa_gen_keys( pub, priv, primesFile );

    unsigned long long n = pub->modulus;

    while( (n-1)*(n-1) / (n-1) != (n-1) )
    {
        sleep(1);
        rsa_gen_keys( pub, priv, primesFile );
        n = pub->modulus;
    }

    struct stat st = {0};
    if ( stat("./working", &st) == -1 ) 
    {
        mkdir("./working", 0700);
    }

    FILE* fp;

    fp = fopen( "./working/myPublicKey.txt", "w+" );
    fprintf( fp, "Public Key:\n Modulus: %lld\n Exponent: %lld\n", (long long)pub->modulus, (long long) pub->exponent );
    fclose( fp );    

    fp = fopen( "./working/myPrivateKey.txt", "w+" );
    fprintf( fp, "Private Key:\n Modulus: %lld\n Exponent: %lld\n", (long long)priv->modulus, (long long) priv->exponent );
    fclose( fp );

    return( 0 );
}

int decryptFile( char* inputFile, char* outputFile )
{
    struct private_key_class* priv = readPriv( "./working/myPrivateKey.txt" );
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

        free( priv );
        free( decrypted );

    }
    return( 0 );
}

int encryptFile( char* inputFile, char* outputFile )
{
    struct public_key_class* pub = readPub( "./working/myPublicKey.txt" );
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

        free( pub );
        free( encrypted );

    }
    return( 0 );
}

