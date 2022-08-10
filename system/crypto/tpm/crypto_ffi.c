
#include <assert.h> /* for assert */
#include <stdlib.h> /* for size_t and NULL */
#include <stdint.h> /* for uint8_t */
#include <stdio.h> /* for printf */
#include <string.h> /* for memcpy */
#include <stdbool.h> /* for bool */
#include <openssl/evp.h>
#include <openssl/err.h>
#include <openssl/rand.h>

#include "sign.h"


#define FFI_SUCCESS 0
#define FFI_FAILURE 1
#define PUB_KEY_LEN 270
/* private RSA keys do not have a fixed length */
#define HASH_LEN 64
#define SIG_LEN 256

bool sha512(uint8_t const *data, size_t dataLen, uint8_t *hash) {
    /* https://wiki.openssl.org/index.php/EVP_Message_Digests
     * Computes the SHA-512 digest of `data` which has `dataLen` length and
     * stores the results in `hash` which must be sufficiently large (64
     * characters/bytes). This function is not called directly by CakeML, but
     * is needed by `./system/posix/meas/meas_ffi.c`. So do not delete/move
     * this. Returns `true` upon success and `false` on failure.
     */
    bool result = false;
    if (data == NULL || dataLen == 0 || hash == NULL) {
        return result;
    }

    EVP_MD_CTX *mdCtx = EVP_MD_CTX_new();
    if (mdCtx == NULL) {
        printf("EVP_MD_CTX_new failed, error 0x%lx\n", ERR_get_error());
        goto err;
    }
    if (EVP_DigestInit_ex(mdCtx, EVP_sha512(), NULL) != 1) {
        printf("EVP_DigestInit_ex failed, error 0x%lx\n", ERR_get_error());
        goto err;
    }
    if (EVP_DigestUpdate(mdCtx, data, dataLen) != 1) {
        printf("EVP_DigestUpdate failed, error 0x%lx\n", ERR_get_error());
        goto err;
    }
    uint32_t *hashLen = NULL;
    if (EVP_DigestFinal_ex(mdCtx, hash, hashLen) != 1) {
        printf("EVP_DigestFinal_ex failed, error 0x%lx\n", ERR_get_error());
        goto err;
    }
    result = true;

err:
    // Cleanup
    if (mdCtx != NULL) {
        EVP_MD_CTX_free(mdCtx);
        mdCtx = NULL;
    }
    return result;
}

void ffisha512(uint8_t *const in, uint64_t const in_len, uint8_t *const out, uint64_t const out_len) {
    /* Called directly by CakeML. Incoming data is contained in `in` and has
     * length `in_len`. Outgoing data is stored in `out` which has length
     * `out_len`.
     */
    uint64_t const digestLen = EVP_MD_size(EVP_sha512());
    assert(out_len >= digestLen);
    uint8_t *msg = (uint8_t *)OPENSSL_malloc(in_len);
    memcpy(msg, in, in_len);
    uint8_t *md = (uint8_t *)OPENSSL_malloc(digestLen);
    assert(sha512(msg, in_len, md));
    memcpy(out, md, digestLen);
    OPENSSL_free(md);
    OPENSSL_free(msg);
}

bool digest_sign(uint8_t const *msg, size_t const msg_len, uint8_t **sig, size_t *sig_len, EVP_PKEY *pkey) {
    /* https://wiki.openssl.org/index.php/EVP_Signing_and_Verifying
     * Message to be signed is contained in `msg` and has length `msg_len`.
     * Signature will be stored in `*sig` and its length will be written to
     * `sig_len`. The private key is held in `pkey`. This function is not called
     * directly by CakeML but is called by `ffisignMsg` which is called by
     * CakeML. Returns `true` upon success and `false` on failure.
     */
    bool result = false;
    if (msg == NULL || msg_len == 0 || sig == NULL || pkey == NULL) {
        goto err;
    }
    if (*sig != NULL) {
        OPENSSL_free(*sig);
    }
    *sig = NULL;
    *sig_len = 0;
    
    EVP_MD_CTX *mdCtx = EVP_MD_CTX_new();
    if (mdCtx == NULL) {
        printf("EVP_MD_CTX_new failed, error 0x%lx\n", ERR_get_error());
        goto err;
    }
    if (EVP_DigestSignInit(mdCtx, NULL, EVP_sha512(), NULL, pkey) != 1) {
        printf("EVP_DigestSignInit failed, error 0x%lx\n", ERR_get_error());
        goto err;
    }
    if (EVP_DigestSignUpdate(mdCtx, msg, msg_len) != 1) {
        printf("EVP_DigestSignUpdate failed, error 0x%lx\n", ERR_get_error());
        goto err;
    }
    // Call EVP_DigestSignFinal with null signature in order to get signature
    // length
    if (EVP_DigestSignFinal(mdCtx, NULL, sig_len) != 1 || *sig_len == 0) {
        printf("EVP_DigestSignFinal failed (1), error 0x%lx\n", ERR_get_error());
        goto err;
    }
    *sig = (uint8_t *)OPENSSL_malloc(*sig_len);
    if (*sig == NULL) {
        printf("OPENSSL_malloc failed, error 0x%lx\n", ERR_get_error());
        goto err;
    }
    // Obtain the signature
    if (EVP_DigestSignFinal(mdCtx, *sig, sig_len) != 1) {
        printf("EVP_DigestSignFinal failed (2), error 0x%lx\n", ERR_get_error());
        goto err;
    }
    result = true;

err:
    // Cleanup
    if (result != true && sig != NULL) {
        OPENSSL_free(*sig);
    }
    if (mdCtx != NULL) {
        EVP_MD_CTX_free(mdCtx);
        mdCtx = NULL;
    }
    return result;
}

bool convert_private_key(uint8_t const *priv, size_t const priv_len, EVP_PKEY **pkey) {
    /* Takes a private key in raw DER format `priv` which is `priv_len` in
     * length and parses the key into a useable `EVP_PKEY` format stored at
     * `*pkey`. Returns `true` upon success and `false` on failure.
     */
    if (priv == NULL || priv_len == 0 || pkey == NULL) {
        printf("Uninitialized paramters.\n");
        if (priv == NULL) {
            printf("\tpriv is null.\n");
        }
        if (priv_len == 0) {
            printf("\tpriv_len is zero.\n");
        }
        if (pkey == NULL) {
            printf("\tpkey is null.\n");
        }
        return false;
    }
    if (d2i_PrivateKey(EVP_PKEY_RSA, pkey, &priv, priv_len) == NULL) {
        printf("Error recovering private key, error code 0x%lx.\n", ERR_get_error());
        return false;
    }
    return true;
}

void ffisignMsg(uint8_t *const in, uint64_t const in_len, uint8_t *const out, uint64_t const out_len) {
    int rc;

    //char input[in_len];
    //strcpy(input, in);
    char input[] = "sign -h";

    char* tpmArgv[50];
    int tpmArgc = 0;

    char* token;
    char* saveptr;
    token = strtok_r(input, " ", &saveptr);
    tpmArgv[tpmArgc] = token;
    tpmArgc = tpmArgc + 1;
    while (token != NULL)
    {
        token = strtok_r(NULL, " ", &saveptr);
        if (token != NULL)
        {
            tpmArgv[tpmArgc] = token;
            tpmArgc = tpmArgc + 1;
        }
    }

    if(strcmp(tpmArgv[0],"sign") == 0)
        rc = sign(tpmArgc, tpmArgv);

    if (out_len >= 1)
        out[0] = rc;
}

bool digest_verify(uint8_t const *msg, size_t const msg_len, uint8_t const *sig, const size_t sig_len, EVP_PKEY *key, bool *verified) {
    /* https://wiki.openssl.org/index.php/EVP_Signing_and_Verifying
     * Takes a message `msg`, of length `msg_len`, and a signature `sig`, of
     * length `sig_len`, verifies the pair with the public key `key`, and stores
     * the status of verification in `verified`.
     * Returns `true` if `verified` contains the accurate result of
     * verification, `false` on an error. Not directly called by CakeML but is
     * the primary function call in `ffisigCheck` which is called by CakeML.
     */
    bool result = false;
    if (msg == NULL || msg_len == 0 || sig == NULL || sig_len == 0 || key == NULL) {
        goto err;
    }
    EVP_MD_CTX *mdCtx = EVP_MD_CTX_new();
    if (mdCtx == NULL) {
        printf("EVP_MD_CTX_new failed, error 0x%lx\n", ERR_get_error());
        goto err;
    }
    if (EVP_DigestVerifyInit(mdCtx, NULL, EVP_sha512(), NULL, key) != 1) {
        printf("EVP_DigestVerifyInit failed, error 0x%lx\n", ERR_get_error());
        goto err;
    }
    if (EVP_DigestVerifyUpdate(mdCtx, msg, msg_len) != 1) {
        printf("EVP_DigestVerifyUpdate failed, error 0x%lx\n", ERR_get_error());
        goto err;
    }
    uint32_t const rc = EVP_DigestVerifyFinal(mdCtx, sig, sig_len);
    if (rc == 1) {
        result = true;
        *verified = true;
    } else if (rc == 0) {
        result = true;
        *verified = false;
    }

err:
    // Cleanup
    if (mdCtx != NULL) {
        EVP_MD_CTX_free(mdCtx);
        mdCtx = NULL;
    }
    return result;
}

bool convert_public_key(uint8_t const *pub, size_t const pub_len, EVP_PKEY **pkey) {
    /* Converts a raw public key, `pub` with length `pub_len`, into a more
     * useable `EVP_PKEY` stored in `*pkey`. Returns `0` upon success and `-1`
     * on failure.
     * 
     * Note: For some reason, only RSA public keys can be recovered. I (Andrew
     * Cousino, 2022, OpenSSL v3.0.2) have tried to get EC keys to work but
     * have so far failed to do so.
     */
    if (pub == NULL || pub_len == 0 || pkey == NULL) {
        printf("Uninitialized paramters.\n");
        return false;
    }
    if (d2i_PublicKey(EVP_PKEY_RSA, pkey, &pub, pub_len) == NULL) {
        printf("Error recovering public key, error code 0x%lx.\n", ERR_get_error());
        return false;
    }
    return true;
}

void ffisigCheck(uint8_t *const in, uint64_t const in_len, uint8_t *const out, uint64_t const out_len) {
    /* Takes an RSA public key, a signature, and a message, all three of which
     * are stored in `in`, and verifies the triple. `out` must be at least 1
     * byte wide, making `out_len >= 1`, and will contain either the value
     * `FFI_SUCCESS` or `FFI_FAILURE`. Called directly by CakeML
     * 
     * Format for `in`:
     * | Bytes | Meaning |
     * |-------|---------|
     * | 0..PUB_KEY_LEN - 1 | RSA public key |
     * | PUB_KEY_LEN..PUB_KEY_LEN + SIG_LEN - 1 | Signature |
     * | PUB_KEY_LEN + SIG_LEN..in_len | Message |
     */
    assert(in_len >= PUB_KEY_LEN + SIG_LEN);
    assert(out_len >= 1);
    uint8_t *pub = (uint8_t *)OPENSSL_malloc(PUB_KEY_LEN);
    memcpy(pub, in, PUB_KEY_LEN);
    EVP_PKEY *pub_key = NULL;
    assert(convert_public_key(pub, PUB_KEY_LEN, &pub_key));
    uint8_t *sig = (uint8_t *)OPENSSL_malloc(SIG_LEN);
    memcpy(sig, in + PUB_KEY_LEN, SIG_LEN);
    const size_t msg_len = in_len - PUB_KEY_LEN - SIG_LEN;
    uint8_t *msg = (uint8_t *)OPENSSL_malloc(msg_len);
    memcpy(msg, in + PUB_KEY_LEN + SIG_LEN, msg_len);
    bool verified = false;
    assert(digest_verify(msg, msg_len, sig, SIG_LEN, pub_key, &verified));
    out[0] = verified ? FFI_SUCCESS : FFI_FAILURE;
    OPENSSL_free(pub);
    OPENSSL_free(sig);
    OPENSSL_free(msg);
}

void ffirandomBytes(uint8_t *const c, uint64_t const c_len, uint8_t *const a, uint64_t const a_len) {
    /* Takes a byte-string `c` and produces an equally long pseudo-random
     * byte-string stored inside `a`. Called directly by CakeML.
     */
    assert(a_len >= c_len);
    assert(RAND_bytes(a, (int)c_len) == 1);
}

