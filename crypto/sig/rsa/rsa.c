/*
** Michael Neises
** 30 May 2019
** original author: Andrew Kiluk
** https://github.com/andrewkiluk/RSA-Library
**
** the rsa algorithm
*/

#include "rsa.h"

// greatest common divisor
unsigned long long gcd( unsigned long long a, unsigned long long b )
{
    unsigned long long c;
    while ( a != 0 ) {
        c = a;
        a = b%a;
        b = c;
    }
    return b;
}

// least common multiple
unsigned long long lcm( unsigned long long a, unsigned long long b )
{
    return( (a*b)/gcd(a,b) );
}

// extended euclid's algorithm
// want to solve for d:
// d*e = 1 (mod totient)
/*
** For input: ax + by = gcd(a,b)
** the EED computes: x, y, gcd(a,b)
** our goal is to find d such that
** d*e = 1 (mod totient)
** so let a=e and b=totient
** recall: gcd(e,totient) = 1
** rearrange: e*x + totient*y = 1
** finally: e*x = 1 (mod totient)
** So we solve for x=d
** x might be negative, so we return the postive answer (mod b)
*/
unsigned long long ExtEuclid( unsigned long long a, unsigned long long b)
{
    unsigned long long s = 0;
    long long old_s = 1;
    unsigned long long r = b;
    unsigned long long old_r = a;
    unsigned long long quotient = 0;
    unsigned long long temp = 0;

    while( r!= 0 )
    {
        quotient = old_r / r;

        temp = r;
        r = old_r - quotient*temp;
        old_r = temp;

        temp = s;
        s = old_s - quotient*temp;
        old_s = temp;
    }

    while( old_s < 0 )
    {
        old_s += b;
    }

    return( (unsigned long long)old_s );
}

/*
** RSA without padding is called Textbook RSA
** Textbook RSA is insecure
** We would like a padding scheme
*/ 
unsigned long long padder( unsigned long long msg )
{
    return( msg );
}


// exponentiation by squaring
// calculate msg^e (mod n)
/*
** In other terms, we have
** msg = base
** e = exponent
** n = modulus
*/

unsigned long long rsa_modExp(unsigned long long msg, unsigned long long e, unsigned long long n)
{
    unsigned long long temp_base = padder( msg );
    unsigned long long temp_exp = e;
    unsigned long long result = 1;
    
    if( n==1 )
    {
        return(0);
    }

    if( (n-1)*(n-1) / (n-1) != (n-1) )
    {
        printf( "Whoa! The product of those primes is too big!\n" );
        exit(1);
    }

    temp_base = temp_base % n;
    while( temp_exp > 0 )
    {
        if( temp_exp % 2 == 1 )
        {
            result = ( result*temp_base ) % n;
        }
        temp_exp = temp_exp >> 1;
        temp_base = (temp_base * temp_base) % n;
    }
    return( result );
}

// Calling this function will generate a public and private key and store them in the pointers
// it is given. 
void rsa_gen_keys(struct public_key_class *pub, struct private_key_class *priv, char *PRIME_SOURCE_FILE)
{
    // variables over which to iterate
    int i = 0;
    int j = 0;

    // p and q are the primes we choose to build the keys
    // n = p*q
    unsigned long long p = 0;
    unsigned long long q = 0;
    unsigned long long n = 0;

    // totient is totient(p*q)
    unsigned long long totient = 0;

    // e is coprime to totient and is the "public exponent"
    unsigned long long e = pow(2, 8) + 1;

    // d is the modular multiplicative inverse of e (mod totient)
    // d is the "private exponent"
    unsigned long long d = 0;

    // TODO what exactly is this?
    char prime_buffer[MAX_DIGITS];

    // read in the file of primes
    FILE *primes_list;
    if(!(primes_list = fopen(PRIME_SOURCE_FILE, "r"))){
        fprintf(stderr, "Problem reading %s\n", PRIME_SOURCE_FILE);
        exit(1);
    }

    // count number of primes in the list
    char buffer[1024];
    unsigned long long prime_count = 0;
    do{
        int bytes_read = fread(buffer,1,sizeof(buffer)-1, primes_list);
        buffer[bytes_read] = '\0';
        for (i=0 ; buffer[i]; i++){
            if (buffer[i] == '\n'){
                prime_count++;
            }
        }
    }
    while(feof(primes_list) == 0);

    // seed the random number generator
    // this seed is okay as long as we don't generate keys several times in one second.
    srand(time(NULL));

    // choose random primes from the list, store them as p,q
    do{
        // a and b are the positions of p and q in the list
        int a =  (double)rand() * (prime_count+1) / (RAND_MAX+1.0);
        int b =  (double)rand() * (prime_count+1) / (RAND_MAX+1.0);

        // here we find the prime at position a, store it as p
        rewind(primes_list);
        for(i=0; i < a + 1; i++){
            //  for(j=0; j < MAX_DIGITS; j++){
            //	prime_buffer[j] = 0;
            //  }
            fgets(prime_buffer,sizeof(prime_buffer)-1, primes_list);
        }
        p = atol(prime_buffer); 

        // here we find the prime at position b, store it as q
        rewind(primes_list);
        for(i=0; i < b + 1; i++){
            for(j=0; j < MAX_DIGITS; j++){
                prime_buffer[j] = 0;
            }
            fgets(prime_buffer,sizeof(prime_buffer)-1, primes_list);
        }
        q = atol(prime_buffer); 

        n = p*q;
        totient = lcm( p-1, q-1 );
    }
    while(!(p && q) || (p == q) || (gcd(totient, e) != 1) || e >= totient);

    // Next, we need to calculate d:
    // d \equiv e^{-1} (mod totient)
    d = ExtEuclid(e, totient);

    printf("primes are %llu and %llu\n", p, q);
    // We now store the public / private keys in the appropriate structs
    pub->modulus = n;
    pub->exponent = e;

    priv->modulus = n;
    priv->exponent = d;
}

unsigned long long* rsa_long_encrypt(unsigned long long* message,
        const unsigned long message_length,
        const struct public_key_class *pub )
{
    unsigned long long *encrypted = malloc(sizeof(unsigned long long)*message_length);
    if(encrypted == NULL){
        fprintf(stderr, "Error: Heap allocation failed.\n");
        return( NULL );
    }
    unsigned long long i = 0;
    for(i=0; i < message_length; i++){
        encrypted[i] = rsa_modExp(message[i], pub->exponent, pub->modulus);
    }
    return( encrypted );
}

unsigned long long* rsa_char_encrypt(
        const char *message,
        const unsigned long message_length,
        const struct public_key_class *pub )
{

    unsigned long long* longMsg = malloc( sizeof(long long) * message_length );
    if(longMsg == NULL){
        fprintf(stderr, "Error: Heap allocation failed.\n");
        return( NULL );
    }
    for( int i=0; i<message_length; i++ )
    {
        longMsg[i] = message[i];
    }

    unsigned long long* outputMsg = malloc( sizeof(long long) * message_length );
    if(outputMsg == NULL){
        fprintf(stderr, "Error: Heap allocation failed.\n");
        return( NULL );
    }
    outputMsg = rsa_long_encrypt( longMsg, message_length, pub );

    free( longMsg );
    return( outputMsg );
    
}

unsigned long long* rsa_long_decrypt(
        const unsigned long long *message, 
        const unsigned long message_length, 
        const struct private_key_class *priv )
{
    // We allocate space to do the decryption (temp) and space for the output as a char array (decrypted)
    unsigned long long* decrypted = malloc(message_length * sizeof(unsigned long long));
    if( decrypted == NULL ){
        fprintf(stderr, "Error: Heap allocation failed.\n");
        return( NULL );
    }
    // Now we go through each 8-byte chunk and decrypt it.
    unsigned long long i = 0;
    for(i=0; i < message_length; i++){
        decrypted[i] = rsa_modExp(message[i], priv->exponent, priv->modulus);
    }
    return( decrypted );
}

char* rsa_char_decrypt(
        const unsigned long long *message, 
        const unsigned long message_length, 
        const struct private_key_class *priv )
{

    char* decrypted = malloc(message_length * sizeof(unsigned long long));
    unsigned long long* temp = malloc(message_length * sizeof(unsigned long long));

    temp = rsa_long_decrypt( message, message_length, priv );

    // The result should be a number in the char range, which gives back the original byte.
    // We put that into decrypted, then return.
    for(long long i=0; i < message_length; i++){
        decrypted[i] = temp[i];
    }
    free(temp);
    return decrypted;
}

