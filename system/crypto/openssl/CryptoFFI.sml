(* Depends on: Util *)

(* Safe wrappers to FFI crypto functions *)
structure Crypto = struct
    exception Err string
    local
        fun ffi_sha512           x y = #(sha512)           x y
        fun ffi_signMsg          x y = #(signMsg)          x y
        fun ffi_sigCheck         x y = #(sigCheck)         x y
        fun ffi_randomBytes x y = #(randomBytes) x y
        fun ffi_diffieHellman x y = #(diffieHellman) x y
        fun ffi_encrypt x y = #(encrypt) x y
        fun ffi_decrypt x y = #(decrypt) x y
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
                print ("num in paddingCalc: " ^ (Int.toString num) ^ "\n");
                if rem = 0 then num + modulus else num + modulus - rem
            end
    in
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
                let val args = (BString.concatList [pub, sign, msg])
                    val argslen = BString.length args in
                print ("\nsigCheck argslen size in cakeml: " ^
                       (Int.toString argslen) ^ "\n\n");
                    FFI.callBool ffi_sigCheck (BString.concatList [pub, sign, msg])
                end
        
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
                print ("padding val: " ^ (Int.toString padding) ^ "\n");
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
