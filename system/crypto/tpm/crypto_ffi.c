
#include <assert.h> /* for assert */
#include <stdlib.h> /* for size_t and NULL */
#include <stdint.h> /* for uint8_t */
#include <stdio.h> /* for printf */
#include <string.h> /* for memcpy */
#include <stdbool.h> /* for bool */
#include <openssl/evp.h>
#include <openssl/err.h>
#include <openssl/rand.h>

#include "powerup.h"
#include "startup.h"
#include "createprimary.h"
#include "create.h"
#include "load.h"
#include "sign.h"
#include "flushcontext.h"
#include "verifysignature.h"

#include "ibmtss/tssfile.h"


#define FFI_SUCCESS 0
#define FFI_FAILURE 1
#define PUB_KEY_LEN 270
/* private RSA keys do not have a fixed length */
#define HASH_LEN 64
#define SIG_LEN 256


    /* 
    Intended to be run before the Copland phrase
    Uses TSS functions powerup, startup, createprimary

    In-
    Uses-
    Out- parentHandle.txt
    */
void ffitpmSetup(uint8_t *const in, uint64_t const in_len, uint8_t *const out, uint64_t const out_len) {
    int rc = 0;

    char *powerupArgv[] = {"powerup"};
    unsigned int powerupArgc = sizeof(powerupArgv) / sizeof(powerupArgv[0]);

    char *startupArgv[] = {"startup", "-c"};
    unsigned int startupArgc = sizeof(startupArgv) / sizeof(startupArgv[0]);

    char *createprimaryArgv[] = {"createprimary", "-hi", "p"};
    unsigned int createprimaryArgc = sizeof(createprimaryArgv) / sizeof(createprimaryArgv[0]);
    
    if (rc == 0) {
        rc = powerup(powerupArgc, powerupArgv);
    }
    if (rc == 0) {
        rc = startup(startupArgc, startupArgv);
    }
    if (rc == 0) {
        rc = createprimary(createprimaryArgc, createprimaryArgv);
    }

    if (rc == 0) {
        out[0] = FFI_SUCCESS;
    }
    else {
        out[0] = FFI_FAILURE;
    }
}
    /*
    create_and_load_ak
    Uses TSS functions create, load
    
    In- 
    Uses- parentHandle.txt
    Out- keyHandle.txt, pub.pem, #pub.bin#, #priv.bin#
    */

void ffitpmCreateSigKey(uint8_t *const in, uint64_t const in_len, uint8_t *const out, uint64_t const out_len) {
    int rc = 0;

    FILE *parentHandle_file;
    char parentHandle[9];
    parentHandle_file = fopen("parentHandle.txt","r");
    if (parentHandle_file == NULL) {
        rc = 1; // parentHandle.txt could not be opened
    }
    if (rc == 0) {
        fgets(parentHandle, 9, (FILE*)parentHandle_file);
        fclose(parentHandle_file);
    }
    
    char *createArgv[] = {"create", "-hp", parentHandle, "-rsa", "2048", "-halg", "sha512", "-si", "-kt", "f", "-kt", "p", "-opr", "priv.bin", "-opu", "pub.bin", "-opem", "pub.pem"};
    unsigned int createArgc = sizeof(createArgv) / sizeof(createArgv[0]);

    char *loadArgv[] = {"load", "-hp", parentHandle, "-ipr", "priv.bin", "-ipu", "pub.bin"};
    unsigned int loadArgc = sizeof(loadArgv) / sizeof(loadArgv[0]);

    if (rc == 0) {
        rc = create(createArgc, createArgv);
    }
    if (rc == 0) {
        rc = load(loadArgc, loadArgv);
    }

    if (rc == 0) {
        out[0] = FFI_SUCCESS;
    }
    else {
        out[0] = FFI_FAILURE;
    }
}


    /*
    get_data
    Uses TSS functions TSS_GetData
    
    In- 
    Uses- data.txt
    Out- data
    */
void ffigetData(uint8_t *const in, uint64_t const in_len, uint8_t *const out, uint64_t const out_len) {
    int rc = 0;

    unsigned char *data = NULL;
    size_t data_len;
    char *filename = "data.txt";

    rc = TSS_GetData(&data, &data_len, filename);
    memset(out, 0, out_len);
    if (rc == 0) {
        memcpy(out, data, data_len);
    }
}


    /*
    tpm_sig
    Uses TSS functions sign, flushcontext
    
    In- data
    Uses- keyHandle.txt, parentHandle.txt
    Out- signature
    */
void ffitpmSign(uint8_t *const in, uint64_t const in_len, uint8_t *const out, uint64_t const out_len) {
    int rc = 0;

    FILE *parentHandle_file;
    char parentHandle[9];
    parentHandle_file = fopen("parentHandle.txt","r");
    if (parentHandle_file == NULL) {
        rc = 1; // parentHandle.txt could not be opened
    }
    if (rc != 1) {
        fgets(parentHandle, 9, (FILE*)parentHandle_file);
        fclose(parentHandle_file);
    }

    FILE *keyHandle_file;
    char keyHandle[9];
    keyHandle_file = fopen("keyHandle.txt","r");
    if (keyHandle_file == NULL) {
        rc = 2; // keyHandle.txt could not be opened
    }
    if (rc != 2) {
        fgets(keyHandle, 9, (FILE*)keyHandle_file);
        fclose(keyHandle_file);
    }
    
    char *data = malloc(in_len);
    memcpy(data, in, in_len);

    char *signArgv[] = {"sign", "-hk", keyHandle, "-halg", "sha512", "-salg", "rsa", "-id", data};
    unsigned int signArgc = sizeof(signArgv) / sizeof(signArgv[0]);

    char *flushHPArgv[] = {"flushcontext", "-ha", parentHandle};
    unsigned int flushHPArgc = sizeof(flushHPArgv) / sizeof(flushHPArgv[0]);

    char *flushHKArgv[] = {"flushcontext", "-ha", keyHandle};
    unsigned int flushHKArgc = sizeof(flushHKArgv) / sizeof(flushHKArgv[0]);

    uint8_t *signature  = sign(signArgc, signArgv);
    memcpy(out, signature, out_len);
    
    flushcontext(flushHPArgc, flushHPArgv);
    flushcontext(flushHKArgc, flushHKArgv);

}


/* Uses TSS functions verifysignature */
/* this function needs changed */
void ffitpmCheckSig(uint8_t *const in, uint64_t const in_len, uint8_t *const out, uint64_t const out_len) {
    int rc = 0;

    char *verifyArgv[] = {"verifysignature", "-ipem", "pub.pem", "-halg", "sha512", "-rsa", "-if", "signTest.txt", "-is", "sig.bin"};
    unsigned int verifyArgc = sizeof(verifyArgv) / sizeof(verifyArgv[0]);

    if (rc == 0) {
        rc = verifysignature(verifyArgc, verifyArgv);
    }

    if (rc == 0) {
        out[0] = FFI_SUCCESS;
    }
    else {
        out[0] = FFI_FAILURE;
    }
}
















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

bool digestSign(uint8_t const *msg, size_t const msg_len, uint8_t **sig, size_t *sig_len, EVP_PKEY *pkey) {
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
    uint8_t const pkey_len_prefix_len = 2;
    assert(in_len > pkey_len_prefix_len);
    assert(out_len >= SIG_LEN);
    size_t const priv_len = ((*in) << 8) | (*(in + 1));
    uint8_t *priv = (uint8_t *)OPENSSL_malloc(priv_len);
    assert(in_len >= pkey_len_prefix_len + priv_len);
    memcpy(priv, in + pkey_len_prefix_len, priv_len);
    EVP_PKEY *pkey = NULL;
    assert(convert_private_key(priv, priv_len, &pkey));
    const size_t msg_len = in_len - priv_len - pkey_len_prefix_len;
    uint8_t *msg = (uint8_t *)OPENSSL_malloc(msg_len);
    memcpy(msg, in + pkey_len_prefix_len + priv_len, msg_len);
    uint8_t *sig = NULL;
    size_t sig_len = 0;
    assert(digestSign(msg, msg_len, &sig, &sig_len, pkey));
    assert(sig_len == SIG_LEN);
    memcpy(out, sig, SIG_LEN);
    OPENSSL_free(sig);
    OPENSSL_free(priv);
    OPENSSL_free(msg);
    OPENSSL_free(pkey);
}

bool digestVerify(uint8_t const *msg, size_t const msg_len, uint8_t const *sig, const size_t sig_len, EVP_PKEY *key, bool *verified) {
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
    assert(digestVerify(msg, msg_len, sig, SIG_LEN, pub_key, &verified));
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

