(* Depends on: Util *)

(* Safe wrappers to FFI crypto functions *)
structure Crypto = struct
    exception Err string
    local
        fun ffi_sha512          x y = #(sha512)             x y 
        fun ffi_signMsg         x y = #(signMsg)            x y
        fun ffi_sigCheck        x y = #(sigCheck)           x y
        fun ffi_randomBytes     x y = #(randomBytes)        x y
        fun ffi_diffieHellman   x y = #(diffieHellman)      x y
        fun ffi_encrypt         x y = #(encrypt)            x y
        fun ffi_decrypt         x y = #(decrypt)            x y
        fun ffi_tpmSetup        x y = #(tpmSetup)           x y 
        fun ffi_tpmCreateSigKey x y = #(tpmCreateSigKey)    x y    
        fun ffi_getData         x y = #(getData)            x y 
        fun ffi_tpmSign         x y = #(tpmSign)            x y 

        val pubkeyLen = 270
        val signLen = 256
        val digestLen = 64
        val ivLen = 16
        (* int -> int -> int
         * Calculates how much padding the encryption/decryption methods will
         * need for the output.
         *)
        fun paddingCalc num modulus =
            let
                val rem = num mod modulus
            in
                if rem = 0 then num + ivLen else num + modulus - rem
            end
        val dataLen = 50   (* overestimated length in bytes of src-data.txt *)
        val tpmSigLen = 262 (* length in bytes of tpm signature *)
    in



        (* setup tpm for attestation *)
        fun tpmSetup () =
            FFI.callBool ffi_tpmSetup (BString.nulls 0)

        (* create_and_load_ak *) 
        fun tpmCreateSigKey () =
            FFI.callBool ffi_tpmCreateSigKey (BString.nulls 0)

        (* get_data *)
        fun getData () =
            FFI.call ffi_getData dataLen (BString.nulls 0)

        (* tpm_sig *)
        fun tpmSign data = 
            FFI.call ffi_tpmSign tpmSigLen data
        (*
        fun checkTpmSig sig data = 
            FFI.call ffi_checkTpmSig (BString.concatList [sig,data])
        *)

        (* bstring -> bstring
         * hash bs
         * Returns the SHA-512 hash of the given byte string.
         *)
        fun hash () = FFI.call ffi_sha512 digestLen

        (* bstring -> bstring -> bstring
         * signMsg privKey msg
         * Returns the signature of the byte string `msg` with the private key
         * `privKey`.
         *)
        fun signMsg priv msg =
            let
                val privKeyLen =
                    BString.fromIntLength
                        2
                        BString.BigEndian
                        (BString.length priv)
            in
                FFI.call ffi_signMsg signLen (BString.concatList [privKeyLen, priv, msg])
            end

        (* bstring -> bstring -> bstring -> bool
         * sigCheck pubKey sig msg
         * Verifies the signature `sig` against the message `msg` using the
         * public key `pubKey`.
         *)
        fun sigCheck pub sign msg = 
            if BString.length pub <> pubkeyLen then
                raise (Err "Wrong public key size, Error in sigCheck FFI")
            else
                FFI.callBool ffi_sigCheck (BString.concatList [pub, sign, msg])
        
        (* int -> bstring
         * randomBytes len
         * Generates a pseudo-random byte string of given length `len`.
         *)
        fun randomBytes len =
            FFI.call ffi_randomBytes len (BString.nulls len)
        
        (* bstring -> bstring -> bstring
         * keyExchange privKey pubKey
         * Takes a 2048-bit DH private key `privKey` and another public key
         * `pubKey` from two different key pairs, and returns a SHA-512 digest
         * of a shared secret with length `digestLen`.
         *)
        fun keyExchange privKey pubKey =
            FFI.call ffi_diffieHellman digestLen (BString.concat privKey pubKey)
        
        (* bstring -> string -> bstring
         * encrypt secret msg
         * Takes a 512-bit secret (or digest of a secret) and a message, and
         * encrypts the message with the secret using AES 256-bit with CBC.
         *)
        fun encrypt secret msg =
            let
                val plaintext = BString.concat (BString.fromString msg) BString.nullByte
                val padding = paddingCalc (BString.length plaintext) ivLen
            in
                FFI.call ffi_encrypt padding (BString.concat secret plaintext)
            end
        
        (* bstring -> bstring -> string
         * decrypt secret msg
         * Takes a 512-bit secret (or digest of a secret) and a message, and
         * decrypts the message with the secret using AES 256-bit with CBC.
         *)
        fun decrypt secret ciphertext =
            let
                val padding = paddingCalc (BString.length ciphertext) ivLen
                val plaintext = FFI.call ffi_decrypt padding (BString.concat secret ciphertext)
            in
                BString.toCString plaintext
            end
        
        (* bstring -> bstring -> string -> bstring
         * encryptOneShot privKey pubKey plaintext
         * Performs a Diffie-Hellman key exchange and then AES-256-CBC
         * encryption with the generated secret.
         *)
        fun encryptOneShot privKey pubKey msg =
            encrypt (keyExchange privKey pubKey) msg
        
        (* bstring -> bstring -> bstring -> string
         * decryptOneShot privKey pubKey ciphertext
         * Performs a Diffie-Hellman key exchange and then AES-256-CBC
         * decryption with the generated secret.
         *)
        fun decryptOneShot privKey pubKey ciphertext =
            decrypt (keyExchange privKey pubKey) ciphertext
    end
end