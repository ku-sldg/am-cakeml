(* Depends on: ByteString.sml, crypto/CryptoFFI.sml *)

(*
Currently supports little other than what is needed to implement an
AES256-CTR-DRBG. Crucially, it does not keep track of the original nonce,
preventing both decryption and random access encryption.
*)
structure Aes256Ctr = struct
    local
        val xkeyFromKeyBs = aes256_xkey o ByteString.toRawString
    in
        (* (xkey, nonce, Aes256Ctr) *)
        type ctr = ByteString.bs * ByteString.bs * ByteString.bs

        fun init key nonce = (xkeyFromKeyBs key, nonce, ByteString.copy nonce)

        fun halfEncr (xkey, _, ctr) =
            aes256 (ByteString.toRawString (ByteString.addInt ctr 1)) xkey

        fun encrBlock aes block = ByteString.xor (halfEncr aes) block
    end
end
