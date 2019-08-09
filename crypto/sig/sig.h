#ifndef DSASIG_H
#define DSASIG_H

#include "rsa/rsaInterface.h"
#include "sha512/hasher.h"
#include <string.h>

// writes the signature to the input "sig"
void signMsgWithKey( char* msg, unsigned long long* sig, struct key_class* priv );

// writes the signature to the input "sig"
void signMsg( char* msg, unsigned long long* sig );

// writes the signature to the file given by sigFile
void signFile( char* msgFile, char* sigFile, char* privKeyFile );

// tests the signature against the hash
// returns 1 if they agree, 0 otherwise
int sigVerify( unsigned long long* sig, uint8_t* hash, struct key_class* pub );

// payload is a null byte delimited list in the order:
// signature, hash, pubkey mod, pubkey exp
int sigCheck( uint8_t* payload );

// duplicate a string, with memory allocation
// don't forget to free it
char* dupstr( char* src );

// parse a signature into a bytestring
void sigToByteString( unsigned long long* sig, uint8_t* byteSig );

// invert the above function
void byteStringToSig( uint8_t* byteSig, unsigned long long* sig );

#endif

