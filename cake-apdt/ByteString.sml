(* No external dependencies *)

(*
This is an implementation for ByteStrings which somewhat resembles the Haskell
ByteString library.

It is currently based on the byte_array type, which underlies the Word8Array
structure. FFI calls use the byte_array type as their second argument (typically
acting as the return slot), making ByteStrings convenient for use with FFI.
*)

structure ByteString = struct
    local
        (* structure W8A = Word8Array *) (* Apparently this isn't supported in CakeML *)
        val zeroByte = Word8.fromInt 0
    in
        (* The type of ByteStrings - this is the same type used by Word8Array *)
        type bs = byte_array

        (* Function mapping byte (word8) to hex representation (string) *)
        fun byteToHex b =
            let
                val top = (Word8.toInt b) div 16;
                val bot = (Word8.toInt b) mod 16;
                fun getHexit w =
                    case w of
                      0  => "0"
                    | 1  => "1"
                    | 2  => "2"
                    | 3  => "3"
                    | 4  => "4"
                    | 5  => "5"
                    | 6  => "6"
                    | 7  => "7"
                    | 8  => "8"
                    | 9  => "9"
                    | 10 => "A"
                    | 11 => "B"
                    | 12 => "C"
                    | 13 => "D"
                    | 14 => "E"
                    | 15 => "F"
            in
                ((getHexit top) ^ (getHexit bot))
            end

        (* foldl over bytes in a ByteString *)
        (* (a -> word8 -> a) -> a -> byte_array -> a *)
        fun foldl f init bs =
            let
                fun foldl_withIndex f init bs i =
                    if (i < (Word8Array.length bs)) then
                        foldl_withIndex f (f init (Word8Array.sub bs i)) bs (i+1)
                    else
                        init
            in
                foldl_withIndex f init bs 0
            end

        (* foldr over bytes in a ByteString *)
        (* (word8 -> a -> a) -> a -> byte_array -> a *)
        fun foldr f init bs =
            let
                fun foldr_withIndex f init bs i =
                    if (i < (Word8Array.length bs)) then
                        f (Word8Array.sub bs i) (foldr_withIndex f init bs (i+1))
                    else
                        init
            in
                foldr_withIndex f init bs 0
            end


        (* An empty byteString *)
        val empty = Word8Array.array 0 zeroByte

        (* Checks if the byteString is empty *)
        fun isEmpty bs = Word8Array.length bs = 0

        (* Length of a byteString *)
        val len = Word8Array.length

        (* Returns a string of the hexadecimal representation *)
        fun toString bs =
            if isEmpty bs then "<Empty ByteString>"
            else foldl (fn s => fn w => s ^ (byteToHex w)) "0x" bs
        (* val toHexString = ((op ^) "0x") o (foldr ((op ^) o byteToHex) "") *)

        (* This returns a string by interpreting each byte as a char. *)
        (* toHexString is meant to create a readable string for printing.
           toRawString is meant to be used for sending through FFI *)
        fun toRawString bs = Word8Array.substring bs 0 (Word8Array.length bs)

        (* Inverse of toRawString *)
        fun fromRawString s =
            let
                val size = String.size s
                val arr = Word8Array.array size (Word8.fromInt 0)
            in
                Word8Array.copyVec s 0 size arr 0;
                arr
            end

        (* Appends 2 byteStrings *)
        (* Since arrays are fixed size, we create a new array large enough to
           accommodate both byteStrings, and then copy them in sequentially*)
        fun append bs1 bs2 =
            let
                val bs1Len = len bs1
                val bs2Len = len bs2
                val newArray = Word8Array.array (bs1Len + bs2Len) zeroByte
            in
                Word8Array.copy bs1 0 bs1Len newArray 0;
                Word8Array.copy bs2 0 bs2Len newArray bs1Len;
                newArray
            end

    end
end
(*
(* Test stuff *)
fun main () = print (ByteString.toString (
    ByteString.append (Word8Array.array 8 (Word8.fromInt 42))
                      (ByteString.append ByteString.empty (Word8Array.array 2 (Word8.fromInt 94))))
    ^ "\n")
val _ = main ()
*)
