(* Depends on: ByteString.sml *)

(* Safe wrappers to FFI crypto functions *)

fun hash bs =
    let
        val result = Word8Array.array 64 (Word8.fromInt 0)
    in
        #(sha512) (ByteString.toRawString bs) result;
        result
    end

fun hashStr s =
    let
        val result = Word8Array.array 64 (Word8.fromInt 0)
    in
        #(sha512) s result;
        result
    end

fun signMsg msg =
    let
        val result = Word8Array.array 512 (Word8.fromInt 0)
    in
        #(signMsg) (ByteString.toRawString msg) result;
        result
    end

fun sigCheck sign msg pubMod pubExp =
    let
        val result  = Word8Array.array 1 (Word8.fromInt 0)
        val payload = (ByteString.toRawString sign) ^
                      (ByteString.toRawString (hash msg)) ^
                      pubMod ^ ":" ^ pubExp ^ ":"
    in
        #(sigCheck) payload result;
        Word8Array.sub result 0 <> ByteString.zeroByte
    end

(* len is length of nonce in bytes *)
fun urand len =
    let
        val result = Word8Array.array len (Word8.fromInt 0)
    in
        #(urand) "" result;
        result
    end

fun aes256_xkey key =
    let
        val result = Word8Array.array 240 (Word8.fromInt 0)
    in
        #(aes256_expand_key) key result;
        result
    end

fun aes256 pt xkey =
    let
        val result = Word8Array.array 16 (Word8.fromInt 0)
    in
        #(aes256) (pt ^ xkey) result;
        result
    end
