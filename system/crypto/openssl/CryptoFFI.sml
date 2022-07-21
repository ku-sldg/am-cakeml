(* Depends on: Util *)

(* Safe wrappers to FFI crypto functions *)
structure Crypto = struct
    exception Err string
    local
        fun ffi_sha512           x y = #(sha512)           x y
        fun ffi_signMsg          x y = #(signMsg)          x y
        fun ffi_sigCheck         x y = #(sigCheck)         x y
        fun ffi_randomBytes x y = #(randomBytes) x y
        val pubkeyLen = 270
        val signLen = 256
    in
        (* bstring -> bstring
         * hash bs
         * Returns the SHA-512 hash of the given byte string.
         *)
        val hash = FFI.call ffi_sha512 64

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
    end
end
