(* Depends on: Util *)

(* Safe wrappers to FFI crypto functions *)
structure Crypto = struct
    exception Err string

    local
        fun ffi_sha512           x y = #(sha512)           x y
        fun ffi_signMsg          x y = #(signMsg)          x y
        fun ffi_sigCheck         x y = #(sigCheck)         x y
        fun ffi_chacha20_encrypt x y = #(chacha20_encrypt) x y
        fun ffi_chacha20_decrypt x y = #(chacha20_decrypt) x y
        fun ffi_curve25519_ecdh x y = #(curve25519_ecdh) x y
        fun ffi_signSecretToPublic x y = #(signSecretToPublic) x y
        fun ffi_curve25519_secretToPublic x y = #(curve25519_secretToPublic) x y
        val pubkeyLen = 270
        val privkeyLen = 14
        val signLen = 64
        val digestLen = 64
    in
        (* bstring -> bstring *)
        val hash = FFI.call ffi_sha512 digestLen

        (* bstring -> bstring -> bstring *)
        fun signMsg priv msg =
            if BString.length priv <> privkeyLen then
                raise (Err ("Wrong private key size (" ^ (Int.toString (BString.length priv)) ^ "), Error in signMsg FFI"))
            else 
                FFI.call ffi_signMsg signLen (BString.concat priv msg)


        (* bstring -> bstring -> bstring -> bool *)
        fun sigCheck pub sign msg = 
            if BString.length pub <> pubkeyLen then
                raise (Err ("Wrong public key size (" ^ (Int.toString (BString.length pub)) ^ "), Error in sigCheck FFI"))
            else
                FFI.callBool ffi_sigCheck (BString.concatList [pub, sign, msg])

        (* generateSignaturePublicKey: bstring -> bstring
         * From a private signing key, generate the corresponding public key.
         *)
        fun generateSignaturePublicKey priv =
            if BString.length priv <> privkeyLen
            then raise (Err "Error in generate_signature_public_key FFI: Wrong private key size")
            else FFI.call ffi_signSecretToPublic signLen priv

        (* bstring -> bstring -> int -> bstring -> bstring *)
        fun encrypt key nonce ctr text = 
            let val ctr_bstring = BString.fromIntLength 4 BString.LittleEndian ctr
                val payload = BString.concatList [key, nonce, ctr_bstring, text]
             in FFI.call ffi_chacha20_encrypt (BString.length text) payload
            end
        
        (* decrypt: bstring -> bstring -> int -> bstring -> bstring *)
        fun decrypt key nonce ctr text =
            let
                val ctr_bstring = BString.fromIntLength 4 BString.LittleEndian ctr
                val payload = BString.concatList [key, nonce, ctr_bstring, text]
            in
                FFI.call ffi_chacha20_decrypt (BString.length text) payload
            end
        
        (* bstring -> bstring -> string -> bstring *)
        fun encryptOneShot privKey pubKey msg =
            encrypt privKey (BString.n2w2 0) 0 (BString.fromString msg)
            
        (* bstring -> bstring -> bstring -> string *)
        fun decryptOneShot privKey pubKey ciphertext = 
            BString.toString (decrypt pubKey (BString.n2w2 0) 0 ciphertext)

        (* generateDHSecret : bstring -> bstring -> bstring
         * `generate_dh_secret priv pub`
         * Runs the ECDH Curve25519 algorithm with a 32 byte private key `priv`
         * and a 64 byte public key `pub`. Returns a 32 byte common secret
         * shared by the two key pairs. 
         *)
        fun generateDHSecret privKey pubKey =
            if BString.length privKey <> privkeyLen orelse
                BString.length pubKey <> pubkeyLen
            then raise (Err "generate_dh_secret error: private key must be 32 bytes, and public key must be 64 bytes.")
            else FFI.call ffi_curve25519_ecdh 32 (BString.concatList [privKey, pubKey])

        (* generateEncryptionPublicKey: bstring -> bstring
         * From a private encyrption key, generates the corresponding public
         * key.
         *)
        fun generateEncryptionPublicKey privKey =
            if BString.length privKey <> privkeyLen
            then raise (Err "Error in generate_encryption_public_key FFI: private key is the wrong size.")
            else FFI.call ffi_curve25519_secretToPublic pubkeyLen privKey
    end
end
