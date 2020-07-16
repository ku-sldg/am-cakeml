(* Depends on: ByteString.sml *)

(* Safe wrappers to FFI crypto functions *)
structure Crypto = struct
    exception Err

    local
        val ffiSuccess = Word8.fromInt 0
        val ffiFailure = Word8.fromInt 1
    in
        fun hashStr s =
            let val result = Word8Array.array 64 (Word8.fromInt 0)
             in #(sha512) s result;
                result
            end

        val hash = hashStr o ByteString.toRawString

        fun hashFile filename =
            let val buffer = Word8Array.array 65 (Word8.fromInt 0)
                val result = Word8Array.array 64 (Word8.fromInt 0)
             in #(fileHash) filename buffer;
                if Word8Array.sub buffer 0 = ffiFailure
                    then raise Err
                    else (Word8Array.copy buffer 1 64 result 0; result)
            end

        fun hashDir path exclPath =
            let val buffer = Word8Array.array 65 (Word8.fromInt 0)
                val result = Word8Array.array 64 (Word8.fromInt 0)
                val null_byte_s = String.str (Char.chr 0)
                val input = path ^ null_byte_s ^ exclPath ^ null_byte_s
             in #(dirHash) input buffer;
                if Word8Array.sub buffer 0 = ffiFailure
                    then raise Err
                    else (Word8Array.copy buffer 1 64 result 0; result)
            end

        fun signMsg priv msg =
            if String.size priv <> 32 then raise Err else
            let val result  = Word8Array.array 64 (Word8.fromInt 0)
                val payload = priv ^ (ByteString.toRawString msg)
             in #(signMsg) payload result;
                result
            end

        (* sigCheck : string -> ByteString.bs -> ByteString.bs -> ByteString.bs *)
        fun sigCheck pub sign msg =
            if String.size pub <> 64 then raise Err else
            let val result  = Word8Array.array 1 (Word8.fromInt 0)
                val payload = pub ^ (ByteString.toRawString sign)
                                  ^ (ByteString.toRawString msg)
             in #(sigCheck) payload result;
                Word8Array.sub result 0 = ffiSuccess
            end

        (* len is length of nonce in bytes *)
        fun urand len =
            let val buffer = Word8Array.array (len+1) (Word8.fromInt 0)
                val result = Word8Array.array len (Word8.fromInt 0)
             in #(urand) "" buffer;
                (if Word8Array.sub buffer 0 = ffiFailure
                    then raise Err
                    else Word8Array.copy buffer 1 len result 0);
                result
            end

        fun aes256_xkey key =
            let val result = Word8Array.array 240 (Word8.fromInt 0)
             in #(aes256_expand_key) key result;
                result
            end

        fun aes256 pt xkey =
            let val result = Word8Array.array 16 (Word8.fromInt 0)
             in #(aes256) (pt ^ xkey) result;
                result
            end
    end
end
