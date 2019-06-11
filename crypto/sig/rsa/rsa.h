
#ifndef RSA_H
#define RSA_H

#define MAX_DIGITS 50

#include <math.h>
#include <time.h>
#include <stdint.h>
#include "utils.h"

unsigned long long gcd( unsigned long long a, unsigned long long b);

unsigned long long lcm( unsigned long long a, unsigned long long b );

unsigned long long ExtEuclid( unsigned long long a, unsigned long long b);

unsigned long long padder( unsigned long long msg );

unsigned long long rsa_modExp( unsigned long long b, unsigned long long e, unsigned long long m);

void rsa_gen_keys( struct public_key_class* pub, struct private_key_class* priv, char* PRIMES_FILE );

// In the following 4 functions, "message_length" is the number of long longs
// or the number of chars... ie the number of things to *crypt

unsigned long long* rsa_long_encrypt( unsigned long long* message, const unsigned long message_length, const struct public_key_class* pub );

unsigned long long* rsa_char_encrypt( const char* message, const unsigned long message_length, const struct public_key_class* pub );

unsigned long long* rsa_long_decrypt( const unsigned long long* message, const unsigned long message_length, const struct private_key_class* priv );

char* rsa_char_decrypt( const unsigned long long* message, const unsigned long message_length, const struct private_key_class* priv );

#endif

