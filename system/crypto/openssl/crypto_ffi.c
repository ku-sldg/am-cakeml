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
    if (mdCtx != NULL) {
        EVP_MD_CTX_free(mdCtx);
        mdCtx = NULL;
    }
    return result;
}

void ffisha512(uint8_t *c, const long c_len, uint8_t *a, const long a_len) {
    const unsigned long digestLen = EVP_MD_size(EVP_sha512());
    assert(a_len >= digestLen);
    unsigned char *msg = (unsigned char *)OPENSSL_malloc(c_len);
    memcpy(msg, c, c_len);
    unsigned char *md = (unsigned char *)OPENSSL_malloc(digestLen);
    assert(sha512(msg, c_len, md) == 0);
    memcpy(a, md, digestLen);
    OPENSSL_free(md);
    OPENSSL_free(msg);
}

int digestSign(const unsigned char *msg, const size_t msg_len, unsigned char **sig, size_t *sig_len, EVP_PKEY *pkey) {
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

void ffisignMsg(uint8_t *c, const long c_len, uint8_t *a, const long a_len) {
    const uint8_t pkey_len_prefix_len = 2;
    assert(c_len > pkey_len_prefix_len);
    assert(a_len >= SIG_LEN);
    const size_t priv_len = ((*c) << 8) | (*(c + 1));
    unsigned char *priv = (unsigned char *)OPENSSL_malloc(priv_len);
    assert(c_len >= pkey_len_prefix_len + priv_len);
    memcpy(priv, c + pkey_len_prefix_len, priv_len);
    EVP_PKEY *pkey = NULL;
    assert(convert_private_key(priv, priv_len, &pkey) == 0);
    const size_t msg_len = c_len - priv_len - pkey_len_prefix_len;
    unsigned char *msg = (unsigned char *)OPENSSL_malloc(msg_len);
    memcpy(msg, c + pkey_len_prefix_len + priv_len, msg_len);
    unsigned char *sig = NULL;
    size_t sig_len = 0;
    assert(digestSign(msg, msg_len, &sig, &sig_len, pkey) == 0);
    assert(sig_len == SIG_LEN);
    memcpy(a, sig, SIG_LEN);
    OPENSSL_free(sig);
    OPENSSL_free(priv);
    OPENSSL_free(msg);
    OPENSSL_free(pkey);
}

int digestVerify(const unsigned char *msg, const size_t msgLen, const unsigned char *sig, const size_t sigLen, EVP_PKEY *key) {
    int result = -1;
    if (msg == NULL || msgLen == 0 || sig == NULL || sigLen == 0 || key == NULL) {
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
    if (EVP_DigestVerifyUpdate(mdCtx, msg, msgLen) != 1) {
        printf("EVP_DigestVerifyUpdate failed, error 0x%lx\n", ERR_get_error());
        goto err;
    }
    if (EVP_DigestVerifyFinal(mdCtx, sig, sigLen) == 1) {
        result = 1;
    } else {
        result = 0;
    }

err:
    if (mdCtx != NULL) {
        EVP_MD_CTX_free(mdCtx);
        mdCtx = NULL;
    }
    return result;
}

int convert_public_key(const unsigned char *pub, const size_t pub_len, EVP_PKEY **pkey) {
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

void ffisigCheck(uint8_t *c, const long c_len, uint8_t *a, const long a_len) {
    assert(c_len >= PUB_KEY_LEN + SIG_LEN);
    assert(a_len >= 1);
    unsigned char *pub = OPENSSL_malloc(PUB_KEY_LEN);
    memcpy(pub, c, PUB_KEY_LEN);
    EVP_PKEY *pub_key = NULL;
    assert(convert_public_key(pub, PUB_KEY_LEN, &pub_key) == 0);
    unsigned char *sig = OPENSSL_malloc(SIG_LEN);
    memcpy(sig, c + PUB_KEY_LEN, SIG_LEN);
    const size_t msg_len = c_len - PUB_KEY_LEN - SIG_LEN;
    unsigned char *msg = OPENSSL_malloc(msg_len);
    memcpy(msg, c + PUB_KEY_LEN + SIG_LEN, msg_len);
    a[0] = digestVerify(msg, msg_len, sig, SIG_LEN, pub_key) == 1
            ? FFI_SUCCESS
            : FFI_FAILURE;
}

void ffirandomBytes(uint8_t *c, const long c_len, uint8_t *a, const long a_len) {
    assert(a_len >= c_len);
    assert(RAND_bytes(a, (int)c_len) == 1);
}
