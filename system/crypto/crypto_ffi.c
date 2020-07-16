// FFI interface to our verified crypto algorithms.

#include <assert.h> // asserts
#include <stddef.h>
#include <stdint.h> // uint8_t and uint32_t types

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <string.h>

#include "Hacl_Hash.h"
#include "Hacl_Ed25519.h"
#include "meas.h"
#include "debug.h"

#define FFI_SUCCESS 0
#define FFI_FAILURE 1
#define ffi_assert(cond) {if (!(cond)) { a[0] = FFI_FAILURE; return; }}

#define PRIV_LEN 32
#define PUB_LEN  64
#define SIG_LEN  64

void ffifileHash(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    printf("calling ffifileHash\n\n");
    assert(alen >= 65);

    const char * filename = (const char *)c;
    // DEBUG_PRINT("Filename: %s\n", filename);

    size_t file_size = 0;
    void *file = NULL;

    int res = readFileContents(filename,&file,&file_size);
    ffi_assert(res == 0);
    printf("file_size after rfc(%s): %i\n",filename,file_size);
    printf("file contents after rfc: %s\n",file);

    Hacl_Hash_SHA2_hash_512((uint8_t *)file, (uint32_t)file_size, a+1);

    int err = munmap(file, file_size);
    ffi_assert(err != -1);

    a[0] = FFI_SUCCESS;
}

void ffidirHash(const uint8_t * c, const long clen, uint8_t * a, const long alen) {

  printf("Calling ffidirHash\n\n");

  char *path = (char *) c;
  char newPath[clen];
  char excludePath[clen];

  /*
  printf("path: \n");
  for(int i = 0; i < clen; i++){
    printf("%c",path[i]);
  }
  printf("\n");
  */

  int j = 0;
  for(int i = 0; i < clen; i++){
    newPath[i] = path[i];
    if(path[i] == '\0'){
      j = i;
      break;
    }
  }

  //printf("j: %i\n",j);
  //printf("clen: %i\n",clen);

  for(int i = j+1, k = 0; i < clen; i++,k++){
    excludePath[k] = path[i];
    //printf("path[i] = %c\n",path[i]);
    if(path[i] == '\0'){
      //printf("i inside for: %i\n",i);
      break;  // TODO: do we need this if block?
    }
  }

  DEBUG_PRINT("newPath: \n%s\n",newPath);
  DEBUG_PRINT("excludePath: \n%s\n",excludePath);
  //return;


  //unsigned char *digest = malloc(alen);

  int digest_len = 64;
  uint8_t *message = malloc(digest_len * 2 * sizeof(char));

  // initialize message to all 0s for consistent hash
  for(int i = 0; i < digest_len * 2; i++){
    message[i] = 0;
  }

  /*
  printf("Initial message: \n");
  for(int i = 0; i < digest_len * 2; i++){
    printf("%u",message[i]);
  }
  printf("\n");
  */

  /*
  #ifdef DOSSL
  char sslDescrip[10] = "SSL";
  #else
  char sslDescrip[10] = "NOT SSL";
  #endifx
  */

  DEBUG_PRINT("\n\n");

  //printf("calling doCompositeHash(Using %s)\n",sslDescrip);
  DEBUG_PRINT("calling doCompositeHashh\n");
  doCompositeHash(newPath,excludePath,a+1,message); //&digest
  //printf("After doCompositeHash(Using %s)\n",sslDescrip);
  DEBUG_PRINT("After doCompositeHash\n");

  //memcpy(a,digest,alen);

  //if(!(digest == NULL))
  // free(digest);

  if(!(message == NULL))
    free(message);

  a[0] = FFI_SUCCESS;  // TODO: this should depend on a result from doCompositeHash
}




/*
void ffifileHash(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    assert(alen >= 65);

    const char * filename = (const char *)c;
    // DEBUG_PRINT("Filename: %s\n", filename);

    int fd = open(filename, O_RDONLY);
    ffi_assert(fd != -1);

    struct stat st;
    int err = stat(filename, &st);
    ffi_assert(err != -1);
    size_t file_size = (size_t)st.st_size;
    ffi_assert(file_size > 0);

    void * file = mmap((void *)NULL, file_size, PROT_READ, MAP_SHARED, fd, 0);

    printf("file_size after mmap: %i\n",file_size);
    printf("file contents after mmap: %s\n",file);
    Hacl_Hash_SHA2_hash_512((uint8_t *)file, (uint32_t)file_size, a+1);

    err = munmap(file, file_size);
    ffi_assert(err != -1);

    a[0] = FFI_SUCCESS;
}
*/



// Arguments: message to be hashed in c
// Returns: hash in a
void ffisha512(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    assert(alen >= 64);
    Hacl_Hash_SHA2_hash_512(c, clen, a);
}

// Argument `c` should be the private key followed by the message (no delimiter)
// Returns signature
void ffisignMsg(const uint8_t * c, const long clen, uint8_t * sig, const long sigLen) {
    assert(clen >= PRIV_LEN);
    assert(sigLen >= SIG_LEN);
    uint8_t * priv = c;
    uint8_t * msg  = c + PRIV_LEN;
    Hacl_Ed25519_sign(sig, priv, (uint32_t)(clen - PRIV_LEN), msg);
}

// Argument `c` should be the public key, then signature, then message (no delimiters)
// Returns success if the signature is valid
void ffisigCheck(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    assert(clen >= PUB_LEN + SIG_LEN);
    assert(alen >= 1);

    // TODO: public key will be included in the payload, requiring parsing
    uint8_t * pub = c;
    uint8_t * sig = pub + PUB_LEN;
    uint8_t * msg = sig + SIG_LEN;
    uint32_t msgLen = (uint32_t)(clen - (PUB_LEN + SIG_LEN));

    a[0] = Hacl_Ed25519_verify(pub, msgLen, msg, sig) ? FFI_SUCCESS : FFI_FAILURE;
}

// Arguments: key in c
// Returns: xkey in a
void ffiaes256_expand_key(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    // assert(clen >= 32);
    // assert(alen >= 240);
    //
    // uint32_t key[8];
    // cpyBytesToWords(c, key, 8);
    //
    // uint32_t xkey[60];
    // aes256_expand_key(key, xkey);
    // cpyWordsToBytes(xkey, a, 60);
}

// Arguments: message block in first 16 blocks of c, xkey in the next 240
// Returns: ciphertext in a
void ffiaes256(const uint8_t * c, const long clen, uint8_t * a, const long alen) {
    // assert(clen >= 255);
    // assert(alen >= 16);
    //
    // uint32_t pt[4];
    // cpyBytesToWords(c, pt, 4);
    //
    // uint32_t xkey[60];
    // cpyBytesToWords(c+16, xkey, 60);
    //
    // uint32_t ct[4];
    // aes256_block_enc(pt, xkey, ct);
    // cpyWordsToBytes(ct, a, 4);
}
