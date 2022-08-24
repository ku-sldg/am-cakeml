#include <assert.h> /* for assert */
#include <stdlib.h> /* for size_t and NULL */
#include <stdint.h> /* for uint8_t */
#include <stdio.h> /* for printf */
#include <string.h> /* for memcpy */
#include <stdbool.h> /* for bool */
#include <openssl/evp.h>
#include <openssl/err.h>
#include <openssl/rand.h>
#include <openssl/x509.h>

#define FFI_SUCCESS 0
#define FFI_FAILURE 1
#define RSA_PUB_KEY_LEN 270
/* private RSA keys do not have a fixed length */
#define DH_PUB_KEY_LEN 552
#define DH_PRIV_KEY_LEN 554
#define HASH_LEN 64
#define SIG_LEN 256
#define SYM_KEY_LEN 32
#define IV_LEN 16

bool sha512(const uint8_t *data, const size_t dataLen, uint8_t *hash) {
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
        goto cleanup;
    }
    if (EVP_DigestInit_ex(mdCtx, EVP_sha512(), NULL) != 1) {
        printf("EVP_DigestInit_ex failed, error 0x%lx\n", ERR_get_error());
        goto cleanup;
    }
    if (EVP_DigestUpdate(mdCtx, data, dataLen) != 1) {
        printf("EVP_DigestUpdate failed, error 0x%lx\n", ERR_get_error());
        goto cleanup;
    }
    uint32_t *hashLen = NULL;
    if (EVP_DigestFinal_ex(mdCtx, hash, hashLen) != 1) {
        printf("EVP_DigestFinal_ex failed, error 0x%lx\n", ERR_get_error());
        goto cleanup;
    }
    result = true;

cleanup:
    if (mdCtx != NULL) {
        EVP_MD_CTX_free(mdCtx);
        mdCtx = NULL;
    }
    return result;
}

void ffisha512(uint8_t *const in, const size_t in_len, uint8_t *const out, const size_t out_len) {
    /* Called directly by CakeML. Incoming data is contained in `in` and has
     * length `in_len`. Outgoing data is stored in `out` which has length
     * `out_len`.
     */
    const uint64_t digestLen = EVP_MD_size(EVP_sha512());
    assert(out_len >= digestLen);
    uint8_t *msg = (uint8_t *)OPENSSL_malloc(in_len);
    memcpy(msg, in, in_len);
    uint8_t *md = (uint8_t *)OPENSSL_malloc(digestLen);
    assert(sha512(msg, in_len, md));
    memcpy(out, md, digestLen);
    OPENSSL_free(md);
    OPENSSL_free(msg);
}

bool digest_sign(const uint8_t *msg, const size_t msg_len, uint8_t **sig, size_t *sig_len, EVP_PKEY *pkey) {
    /* https://wiki.openssl.org/index.php/EVP_Signing_and_Verifying
     * Message to be signed is contained in `msg` and has length `msg_len`.
     * Signature will be stored in `*sig` and its length will be written to
     * `sig_len`. The private key is held in `pkey`. This function is not called
     * directly by CakeML but is called by `ffisignMsg` which is called by
     * CakeML. Returns `true` upon success and `false` on failure.
     */
    bool result = false;
    if (msg == NULL || msg_len == 0 || sig == NULL || pkey == NULL) {
        goto cleanup;
    }
    if (*sig != NULL) {
        OPENSSL_free(*sig);
    }
    *sig = NULL;
    *sig_len = 0;
    
    EVP_MD_CTX *mdCtx = EVP_MD_CTX_new();
    if (mdCtx == NULL) {
        printf("EVP_MD_CTX_new failed, error 0x%lx\n", ERR_get_error());
        goto cleanup;
    }
    if (EVP_DigestSignInit(mdCtx, NULL, EVP_sha512(), NULL, pkey) != 1) {
        printf("EVP_DigestSignInit failed, error 0x%lx\n", ERR_get_error());
        goto cleanup;
    }
    if (EVP_DigestSignUpdate(mdCtx, msg, msg_len) != 1) {
        printf("EVP_DigestSignUpdate failed, error 0x%lx\n", ERR_get_error());
        goto cleanup;
    }
    // Call EVP_DigestSignFinal with null signature in order to get signature
    // length
    if (EVP_DigestSignFinal(mdCtx, NULL, sig_len) != 1 || *sig_len == 0) {
        printf("EVP_DigestSignFinal failed (1), error 0x%lx\n", ERR_get_error());
        goto cleanup;
    }
    *sig = (uint8_t *)OPENSSL_malloc(*sig_len);
    if (*sig == NULL) {
        printf("OPENSSL_malloc failed, error 0x%lx\n", ERR_get_error());
        goto cleanup;
    }
    // Obtain the signature
    if (EVP_DigestSignFinal(mdCtx, *sig, sig_len) != 1) {
        printf("EVP_DigestSignFinal failed (2), error 0x%lx\n", ERR_get_error());
        goto cleanup;
    }
    result = true;

cleanup:
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

bool convert_rsa_private_key(const uint8_t *priv, const size_t priv_len, EVP_PKEY **pkey) {
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

void ffisignMsg(uint8_t *const in, const size_t in_len, uint8_t *const out, const size_t out_len) {
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
    assert(in_len >= pkey_len_prefix_len + priv_len);
    EVP_PKEY *pkey = NULL;
    assert(convert_rsa_private_key(in + pkey_len_prefix_len, priv_len, &pkey));
    const size_t msg_len = in_len - priv_len - pkey_len_prefix_len;
    uint8_t *sig = NULL;
    size_t sig_len = 0;
    assert(digest_sign(in + pkey_len_prefix_len + priv_len, msg_len, &sig, &sig_len, pkey));
    assert(sig_len == SIG_LEN);
    memcpy(out, sig, SIG_LEN);
    OPENSSL_free(sig);
    EVP_PKEY_free(pkey);
}

bool digest_verify(const uint8_t *msg, const size_t msg_len, const uint8_t *sig, const size_t sig_len, EVP_PKEY *key, bool *verified) {
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
        goto cleanup;
    }
    EVP_MD_CTX *mdCtx = EVP_MD_CTX_new();
    if (mdCtx == NULL) {
        printf("EVP_MD_CTX_new failed, error 0x%lx\n", ERR_get_error());
        goto cleanup;
    }
    if (EVP_DigestVerifyInit(mdCtx, NULL, EVP_sha512(), NULL, key) != 1) {
        printf("EVP_DigestVerifyInit failed, error 0x%lx\n", ERR_get_error());
        goto cleanup;
    }
    if (EVP_DigestVerifyUpdate(mdCtx, msg, msg_len) != 1) {
        printf("EVP_DigestVerifyUpdate failed, error 0x%lx\n", ERR_get_error());
        goto cleanup;
    }
    uint32_t const rc = EVP_DigestVerifyFinal(mdCtx, sig, sig_len);
    if (rc == 1) {
        result = true;
        *verified = true;
    } else if (rc == 0) {
        result = true;
        *verified = false;
    }

cleanup:
    // Cleanup
    if (mdCtx != NULL) {
        EVP_MD_CTX_free(mdCtx);
        mdCtx = NULL;
    }
    return result;
}

bool convert_rsa_public_key(const uint8_t *pub, const size_t pub_len, EVP_PKEY **pkey) {
    /* Converts a raw public key, `pub` with length `pub_len`, into a more
     * useable `EVP_PKEY` stored in `*pkey`. Returns `true` upon success and
     * `false` on failure.
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

void ffisigCheck(uint8_t *const in, const size_t in_len, uint8_t *const out, const size_t out_len) {
    /* Takes an RSA public key, a signature, and a message, all three of which
     * are stored in `in`, and verifies the triple. `out` must be at least 1
     * byte wide, making `out_len >= 1`, and will contain either the value
     * `FFI_SUCCESS` or `FFI_FAILURE`. Called directly by CakeML
     * 
     * Format for `in`:
     * | Bytes | Meaning |
     * |-------|---------|
     * | 0..RSA_PUB_KEY_LEN - 1 | RSA public key |
     * | RSA_PUB_KEY_LEN..RSA_PUB_KEY_LEN + SIG_LEN - 1 | Signature |
     * | RSA_PUB_KEY_LEN + SIG_LEN..in_len | Message |
     */

    printf("in_len %zu\n", in_len);
    printf("RSA_PUB_KEY_LEN %zu\n", RSA_PUB_KEY_LEN);
    printf("SIG_LEN %zu\n", SIG_LEN);
    assert(in_len >= RSA_PUB_KEY_LEN + SIG_LEN);
    assert(out_len >= 1);
    EVP_PKEY *pub_key = NULL;
    assert(convert_rsa_public_key(in, RSA_PUB_KEY_LEN, &pub_key));
    const size_t msg_len = in_len - RSA_PUB_KEY_LEN - SIG_LEN;
    bool verified = false;
    assert(digest_verify(in + RSA_PUB_KEY_LEN + SIG_LEN, msg_len, in + RSA_PUB_KEY_LEN, SIG_LEN, pub_key, &verified));
    out[0] = verified ? FFI_SUCCESS : FFI_FAILURE;
    EVP_PKEY_free(pub_key);
}

void ffirandomBytes(uint8_t *const in, const uint64_t in_len, uint8_t *const out, const uint64_t out_len) {
    /* Takes a byte-string `c` and produces an equally long pseudo-random
     * byte-string stored inside `a`. Called directly by CakeML.
     */
    assert(out_len >= in_len);
    assert(RAND_bytes(out, (int)in_len) == 1);
}

bool dh_key_agreement(EVP_PKEY *priv_key, EVP_PKEY *pub_key, uint8_t **sym_key, size_t *sym_key_len) {
    /* https://wiki.openssl.org/index.php/EVP_Key_Agreement
     * Takes in an RSA private key `priv_key` and a public key `pub_key` from
     * two different asymmetric key pairs and outputs a symmetric secret stored
     * in `*sym_key` whose length is `*sym_key_len`.
     */
    bool result = false;
    EVP_PKEY_CTX *ctx = NULL;
    if (priv_key == NULL || pub_key == NULL || sym_key == NULL) {
        printf("Uninitialized parameters for `dh_key_agreement`.\n");
        goto cleanup;
    }
    ctx = EVP_PKEY_CTX_new(priv_key, NULL);
    if (ctx == NULL) {
        printf("EVP_PKEY_CTX_new failed, error code 0x%lx\n", ERR_get_error());
        goto cleanup;
    }
    if (EVP_PKEY_derive_init(ctx) <= 0) {
        printf("EVP_PKEY_derive_init failed, error code 0x%lx\n", ERR_get_error());
        goto cleanup;
    }
    if (EVP_PKEY_derive_set_peer(ctx, pub_key) <= 0) {
        printf("EVP_PKEY_derive_set_peer failed, error code 0x%lx\n", ERR_get_error());
        goto cleanup;
    }
    if (EVP_PKEY_derive(ctx, NULL, sym_key_len) <= 0) {
        printf("EVP_PKEY_derive (1) failed, error code 0x%lx\n", ERR_get_error());
        goto cleanup;
    }
    *sym_key = (uint8_t *)OPENSSL_malloc(*sym_key_len);
    if (*sym_key == NULL) {
        printf("OPENSSL_malloc failed, error code 0x%lx\n", ERR_get_error());
        goto cleanup;
    }
    if (EVP_PKEY_derive(ctx, *sym_key, sym_key_len) <= 0) {
        printf("EVP_PKEY_derive (2) failed, error code 0x%lx\n", ERR_get_error());
        goto cleanup;
    }
    result = true;

cleanup:
    if (ctx != NULL) {
        EVP_PKEY_CTX_free(ctx);
        ctx = NULL;
    }
    return result;
}

bool convert_dh_private_key(const uint8_t *priv, const size_t priv_len, EVP_PKEY **pkey) {
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
    if (d2i_PrivateKey(EVP_PKEY_DH, pkey, &priv, priv_len) == NULL) {
        printf("Error recovering private key, error code 0x%lx.\n", ERR_get_error());
        return false;
    }
    return true;
}

bool convert_dh_public_key(const uint8_t *pub, const size_t pub_len, EVP_PKEY **pkey) {
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
    if (d2i_PUBKEY(pkey, &pub, pub_len) == NULL) {
        printf("Error recovering public key, error code 0x%lx.\n", ERR_get_error());
        return false;
    }
    return true;
}

void ffidiffieHellman(uint8_t *const in, const size_t in_len, uint8_t *const out, const size_t out_len) {
    /* Takes in an RSA private key and a public key from different asymmetric
     * key pairs and then outputs a symmetric "key". Technically, this key is
     * the output of `dh_key_agreement` run through SHA-512. This produces a
     * 256-bit key and a 128-bit initialization vector needed to key an
     * encyrption/decryption process. Note there are 128-bits of the digest
     * that are ignored.
     * 
     * Format for `in`:
     * | Bytes | Meaning |
     * |-------|---------|
     * | 0..DH_PRIV_KEY_LEN - 1 | A DH private key in raw DER format |
     * | DH_PRIV_KEY_LEN..in_len - 1 | A DH public key in raw DER format |
     * 
     * Format of `out`:
     * | Bytes | Meaning |
     * |-------|---------|
     * | 0..255 | Key |
     * | 256..383 | IV |
     * | 384..511 | ignored |
     */
    assert(in_len >= DH_PUB_KEY_LEN + DH_PRIV_KEY_LEN);
    assert(out_len >= HASH_LEN);
    EVP_PKEY *priv_key = NULL;
    assert(convert_dh_private_key(in, DH_PRIV_KEY_LEN, &priv_key));
    EVP_PKEY *pub_key = NULL;
    assert(convert_dh_public_key(in + DH_PRIV_KEY_LEN, DH_PUB_KEY_LEN, &pub_key));
    uint8_t *secret = NULL;
    size_t secret_len = 0;
    assert(dh_key_agreement(priv_key, pub_key, &secret, &secret_len));
    assert(sha512(secret, secret_len, out));
    OPENSSL_free(secret);
    EVP_PKEY_free(priv_key);
    EVP_PKEY_free(pub_key);
}

bool encrypt(const uint8_t *plaintext, const size_t plaintext_len, const uint8_t *key, const uint8_t *iv, uint8_t **ciphertext, size_t *ciphertext_len) {
    /* https://wiki.openssl.org/index.php/EVP_Symmetric_Encryption_and_Decryption
     * Takes `plaintext`, a `key`, and an initialization vector `iv`, and runs
     * them through AES 256-bit using CBC to produce `ciphertext`.
     */
    bool result = false;
    EVP_CIPHER_CTX *ctx = NULL;
    int len = 0;
    
    *ciphertext_len = 0;
    ctx = EVP_CIPHER_CTX_new();
    if (ctx == NULL) {
        printf("EVP_CIPHER_CTX_new failed, error code %lx\n", ERR_get_error());
        goto cleanup;
    }
    if (EVP_EncryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key, iv) != 1) {
        printf("EVP_EncyrptInit_ex failed, error code %lx\n", ERR_get_error());
        goto cleanup;
    }
    if (EVP_EncryptUpdate(ctx, *ciphertext, &len, plaintext, plaintext_len) != 1) {
        printf("EVP_EncryptUpdate failed, error code %lx\n", ERR_get_error());
        goto cleanup;
    }
    *ciphertext_len += len;
    if (EVP_EncryptFinal_ex(ctx, *ciphertext + len, &len) != 1) {
        printf("EVP_EncryptFinal_ex failed, error code %lx\n", ERR_get_error());
        goto cleanup;
    }
    *ciphertext_len += len;
    result = true;

cleanup:
    if (ctx != NULL) {
        EVP_CIPHER_CTX_free(ctx);
        ctx = NULL;
    }
    return result;
}

void ffiencrypt(uint8_t *const in, size_t const in_len, uint8_t *out, size_t const out_len) {
    /* Takes in a key, an initialization vector (IV), and a message, and then
     * encrypts them using AES 256-bit with CBC. The `out` should have length
     * `out_len` which is at least as large as `in` (`in_len`) and a multiple of
     * the block length (128 bits = 16 bytes, IV_LEN).
     * 
     * Format for `in`:
     * | Bytes | Meaning |
     * |-------|---------|
     * | 0..255 | key |
     * | 256..383 | iv |
     * | 384..511 | ignored |
     * | 512..in_len - 1 | plaintext |
     */
    assert(in_len >= HASH_LEN);
    assert((out_len + HASH_LEN >= in_len) && (out_len % IV_LEN == 0));
    size_t ciphertext_len = 0;
    assert(encrypt(in + HASH_LEN, in_len - HASH_LEN, in, in + SYM_KEY_LEN, &out, &ciphertext_len));
    printf("out_len %zu\n", out_len);
    printf("ciphertext_len %zu\n", ciphertext_len);
    assert(out_len >= ciphertext_len);
}

bool decrypt(const uint8_t *ciphertext, const size_t ciphertext_len, const uint8_t *key, const uint8_t *iv, uint8_t **plaintext, size_t *plaintext_len) {
    /* https://wiki.openssl.org/index.php/EVP_Symmetric_Encryption_and_Decryption
     * Performs AES 256-bit with CBC decryption on `ciphertext` using `key` and
     * `iv` to get `plaintext`.
     */
    bool result = false;
    EVP_CIPHER_CTX *ctx = NULL;
    int len = 0;

    *plaintext_len = 0;
    ctx = EVP_CIPHER_CTX_new();
    if (ctx == NULL) {
        printf("EVP_CIPHER_CTX_new failed, error code %lx\n", ERR_get_error());
        goto cleanup;
    }
    if (EVP_DecryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key, iv) != 1) {
        printf("EVP_DecryptInit_ex failed, error code %lx\n", ERR_get_error());
        goto cleanup;
    }
    if (EVP_DecryptUpdate(ctx, *plaintext, &len, ciphertext, ciphertext_len) != 1) {
        printf("EVP_DecryptUpdate failed, error code %lx\n", ERR_get_error());
        goto cleanup;
    }
    *plaintext_len += len;
    if (EVP_DecryptFinal_ex(ctx, *plaintext + len, &len) != 1) {
        printf("EVP_DecryptFinal_ex failed, error code %lx\n", ERR_get_error());
        goto cleanup;
    }
    *plaintext_len += len;
    result = true;

cleanup:
    if (ctx != NULL) {
        EVP_CIPHER_CTX_free(ctx);
        ctx = NULL;
    }
    return result;
}

void ffidecrypt(uint8_t *const in, const size_t in_len, uint8_t *out, const size_t out_len) {
    /* Performs AES 256-bit with CBC decryption using a key, an iv, and some
     * ciphertext to produce plaintext. The output `out` should have length
     * `out_len` at least as large as `in` and which is a multiple of the block
     * size (128 bits = 16 bytes, IV_LEN)
     * 
     * Format of `in`:
     * | 0..255 | key |
     * | 256..383 | iv |
     * | 384..511 | ignored |
     * | 512..in_len - 1 | ciphertext |
     */
    assert(in_len >= HASH_LEN);
    assert(out_len + HASH_LEN >= in_len && out_len % IV_LEN == 0);
    size_t plaintext_len = 0;
    assert(decrypt(in + HASH_LEN, in_len - HASH_LEN, in, in + SYM_KEY_LEN, &out, &plaintext_len));
    assert(out_len >= plaintext_len);
}
