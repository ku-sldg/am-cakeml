#include <assert.h> // for assert
#include <stdlib.h> // for size_t and NULL
#include <stdint.h> // for uint8_t
#include <stdio.h> // for printf
#include <string.h> // for memcpy
#include <openssl/evp.h>
#include <openssl/err.h>
#include <openssl/rand.h>

#define FFI_SUCCESS 0
#define FFI_FAILURE 1
// #define PRIV_KEY_MIN_LEN 1216 // to 1219
#define PUB_KEY_LEN 270
#define HASH_LEN 64
#define SIG_LEN 256

int sha512(const unsigned char *data, size_t dataLen, unsigned char *hash) {
    /* https://wiki.openssl.org/index.php/EVP_Message_Digests
     * Computes the SHA-512 digest of `data` which has `dataLen` length and
     * stores the results in `hash` which must be sufficiently large (64
     * characters/bytes). This function is not called directly by CakeML, but
     * is needed by `./system/posix/meas/meas_ffi.c`. So do not delete/move
     * this. Returns `0` upon success and `-1` on failure.
     */
    int result = -1;
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
    unsigned int *hashLen = NULL;
    if (EVP_DigestFinal_ex(mdCtx, hash, hashLen) != 1) {
        printf("EVP_DigestFinal_ex failed, error 0x%lx\n", ERR_get_error());
        goto err;
    }
    result = 0;

err:
    // Cleanup
    if (mdCtx != NULL) {
        EVP_MD_CTX_free(mdCtx);
        mdCtx = NULL;
    }
    return result;
}

void ffisha512(uint8_t *in, const long in_len, uint8_t *out, const long out_len) {
    /* Called directly by CakeML. Incoming data is contained in `in` and has
     * length `in_len`. Outgoing data is stored in `out` which has length
     * `out_len`.
     */
    const unsigned long digestLen = EVP_MD_size(EVP_sha512());
    assert(out_len >= digestLen);
    unsigned char *msg = (unsigned char *)OPENSSL_malloc(in_len);
    memcpy(msg, in, in_len);
    unsigned char *md = (unsigned char *)OPENSSL_malloc(digestLen);
    assert(sha512(msg, in_len, md) == 0);
    memcpy(out, md, digestLen);
    OPENSSL_free(md);
    OPENSSL_free(msg);
}

int digestSign(const unsigned char *msg, const size_t msg_len, unsigned char **sig, size_t *sig_len, EVP_PKEY *pkey) {
    /* https://wiki.openssl.org/index.php/EVP_Signing_and_Verifying
     * Message to be signed is contained in `msg` and has length `msg_len`.
     * Signature will be stored in `*sig` and its length will be written to
     * `sig_len`. The private key is held in `pkey`. This function is not called
     * directly by CakeML but is called by `ffisignMsg` which is called by
     * CakeML. Returns `0` upon success and `-1` on failure.
     */
    int result = -1;
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
    *sig = (unsigned char *)OPENSSL_malloc(*sig_len);
    if (*sig == NULL) {
        printf("OPENSSL_malloc failed, error 0x%lx\n", ERR_get_error());
        goto err;
    }
    // Obtain the signature
    if (EVP_DigestSignFinal(mdCtx, *sig, sig_len) != 1) {
        printf("EVP_DigestSignFinal failed (2), error 0x%lx\n", ERR_get_error());
        goto err;
    }
    result = 0;

err:
    // Cleanup
    if (result != 0 && sig != NULL) {
        OPENSSL_free(*sig);
    }
    if (mdCtx != NULL) {
        EVP_MD_CTX_free(mdCtx);
        mdCtx = NULL;
    }
    return result;
}

int convert_private_key(const unsigned char *priv, const size_t priv_len, EVP_PKEY **pkey) {
    /* Takes a private key in raw DER format `priv` which is `priv_len` in
     * length and parses the key into a useable `EVP_PKEY` format stored at
     * `*pkey`. Returns `0` upon success and `-1` on failure.
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
        return -1;
    }
    if (d2i_PrivateKey(EVP_PKEY_RSA, pkey, &priv, priv_len) == NULL) {
        printf("Error recovering private key, error code 0x%lx.\n", ERR_get_error());
        return -1;
    }
    return 0;
}

void ffisignMsg(uint8_t *in, const long in_len, uint8_t *out, const long out_len) {
    /* Creates a signature for a message stored in `in` from a key which is
     * also stored in `in` and stores the signature in `out` which must have a
     * length of `out_len`. Called directly by CakeML.
     * 
     * Format of `in`: (because RSA has private keys that vary slightly in length)
     * | Bytes | Meaning |
     * |-------|---------|
     * | 0, 1  | The length of the private key stored, call this `key_len` |
     * | 2..key_len + 1 | The raw private key in DER format, is length `key_len` |
     * | key_len + 2..in_len - 1 | The remainder is the message to be signed |
     */
    const uint8_t pkey_len_prefix_len = 2;
    assert(in_len > pkey_len_prefix_len);
    assert(out_len >= SIG_LEN);
    const size_t priv_len = ((*in) << 8) | (*(in + 1));
    unsigned char *priv = (unsigned char *)OPENSSL_malloc(priv_len);
    assert(in_len >= pkey_len_prefix_len + priv_len);
    memcpy(priv, in + pkey_len_prefix_len, priv_len);
    EVP_PKEY *pkey = NULL;
    assert(convert_private_key(priv, priv_len, &pkey) == 0);
    const size_t msg_len = in_len - priv_len - pkey_len_prefix_len;
    unsigned char *msg = (unsigned char *)OPENSSL_malloc(msg_len);
    memcpy(msg, in + pkey_len_prefix_len + priv_len, msg_len);
    unsigned char *sig = NULL;
    size_t sig_len = 0;
    assert(digestSign(msg, msg_len, &sig, &sig_len, pkey) == 0);
    assert(sig_len == SIG_LEN);
    memcpy(out, sig, SIG_LEN);
    OPENSSL_free(sig);
    OPENSSL_free(priv);
    OPENSSL_free(msg);
    OPENSSL_free(pkey);
}

int digestVerify(const unsigned char *msg, const size_t msg_len, const unsigned char *sig, const size_t sig_len, EVP_PKEY *key) {
    /* https://wiki.openssl.org/index.php/EVP_Signing_and_Verifying
     * Takes a message `msg`, of length `msg_len`, and a signature `sig`, of
     * length `sig_len`, and verifies the pair with the public key `key`.
     * Returns `1` upon a successful verification, `0` on a failed
     * verification, and `-1` on an error. Not directly called by CakeML but is
     * the primary function call in `ffisigCheck` which is called by CakeML.
     */
    int result = -1;
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
    const int rc = EVP_DigestVerifyFinal(mdCtx, sig, sig_len);
    if (rc == 1) {
        result = 1;
    } else if (rc == 0) {
        result = 0;
    }

err:
    // Cleanup
    if (mdCtx != NULL) {
        EVP_MD_CTX_free(mdCtx);
        mdCtx = NULL;
    }
    return result;
}

int convert_public_key(const unsigned char *pub, const size_t pub_len, EVP_PKEY **pkey) {
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
        return -1;
    }
    if (d2i_PublicKey(EVP_PKEY_RSA, pkey, &pub, pub_len) == NULL) {
        printf("Error recovering public key, error code 0x%lx.\n", ERR_get_error());
        return -1;
    }
    return 0;
}

void ffisigCheck(uint8_t *in, const long in_len, uint8_t *out, const long out_len) {
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
    unsigned char *pub = OPENSSL_malloc(PUB_KEY_LEN);
    memcpy(pub, in, PUB_KEY_LEN);
    EVP_PKEY *pub_key = NULL;
    assert(convert_public_key(pub, PUB_KEY_LEN, &pub_key) == 0);
    unsigned char *sig = OPENSSL_malloc(SIG_LEN);
    memcpy(sig, in + PUB_KEY_LEN, SIG_LEN);
    const size_t msg_len = in_len - PUB_KEY_LEN - SIG_LEN;
    unsigned char *msg = OPENSSL_malloc(msg_len);
    memcpy(msg, in + PUB_KEY_LEN + SIG_LEN, msg_len);
    out[0] = digestVerify(msg, msg_len, sig, SIG_LEN, pub_key) == 1
            ? FFI_SUCCESS
            : FFI_FAILURE;
}

void ffirandomBytes(uint8_t *c, const long c_len, uint8_t *a, const long a_len) {
    /* Takes a byte-string `c` and produces an equally long pseudo-random
     * byte-string stored inside `a`. Called directly by CakeML.
     */
    assert(a_len >= c_len);
    assert(RAND_bytes(a, (int)c_len) == 1);
}
