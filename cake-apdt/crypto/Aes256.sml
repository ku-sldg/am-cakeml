(* Depends on: ByteString.sml, crypto/CryptoFFI.sml *)

(* Currently doesn't expose any functions for explicitly decrypting data,
   although you could achieve decryption by creating another Aes256Ctr with the
   same key/nonce and "encrypt" the encrypted block sequence in order. *)
structure Aes256Ctr = struct
    local
        val xkeyFromKeyBs = ByteString.toRawString o aes256_xkey o ByteString.toRawString
    in
        (* (xkey, nonce, ctr) *)
        type ctr = ByteString.bs * ByteString.bs * ByteString.bs

        (* key should be 32 bytes, nonce should be 16*)
        fun init key nonce = (xkeyFromKeyBs key, nonce, ByteString.copy nonce)

        (* The first half of CTR mode block encryption. Generates the block
           that the plaintext is XORed against. It is exposed as its own
           function for the benefit of the CTR DRBG, which does not make use of
           the XORing. *)
        fun encrCtr (xkey, _, ctr) =
            aes256 (ByteString.toRawString (ByteString.addInt ctr 1)) xkey

        (* Full block encryption *)
        fun encrBlock aes block = ByteString.xor (encrCtr aes) block
    end
end
