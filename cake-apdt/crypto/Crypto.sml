(* Safe wrappers to FFI crypto functions *)

fun hash bs =
    let
        val result = Word8Array.array 64 (Word8.fromInt 0)
    in
        #(sha512) (ByteString.toCharString bs) result;
        result
    end
