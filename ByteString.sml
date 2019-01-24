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

        (* Raised by hexToByte if there exists a char != 0..9, a..f, or A..F *)
        exception InvalidHexString

        (* Inverse of byteToHex *)
        fun hexToByte s =
            let
                val top = String.sub s 0
                val bot = String.sub s 1
                fun getHalfByte c =
                    case c of
                      #"0" => Word8.fromInt 0
                    | #"1" => Word8.fromInt 1
                    | #"2" => Word8.fromInt 2
                    | #"3" => Word8.fromInt 3
                    | #"4" => Word8.fromInt 4
                    | #"5" => Word8.fromInt 5
                    | #"6" => Word8.fromInt 6
                    | #"7" => Word8.fromInt 7
                    | #"8" => Word8.fromInt 8
                    | #"9" => Word8.fromInt 9
                    | #"a" => Word8.fromInt 10 | #"A" => Word8.fromInt 10
                    | #"b" => Word8.fromInt 11 | #"B" => Word8.fromInt 11
                    | #"c" => Word8.fromInt 12 | #"C" => Word8.fromInt 12
                    | #"d" => Word8.fromInt 13 | #"D" => Word8.fromInt 13
                    | #"e" => Word8.fromInt 14 | #"E" => Word8.fromInt 14
                    | #"f" => Word8.fromInt 15 | #"F" => Word8.fromInt 15
                    |   _  => raise InvalidHexString
            in
                Word8.orb (Word8.<< (getHalfByte top) 4) (getHalfByte bot)
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

        (* foldli over bytes in a ByteString *)
        (* (int -> a -> word8 -> a) -> a -> byte_array -> a *)
        fun foldli f init bs =
            let
                fun foldli_withIndex f init bs i =
                    if (i < (Word8Array.length bs)) then
                        foldli_withIndex f (f i init (Word8Array.sub bs i)) bs (i+1)
                    else
                        init
            in
                foldli_withIndex f init bs 0
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

        (* foldri over bytes in a ByteString *)
        (* (int -> word8 -> a -> a) -> a -> byte_array -> a *)
        fun foldri f init bs =
            let
                fun foldri_withIndex f init bs i =
                    if (i < (Word8Array.length bs)) then
                        f i (Word8Array.sub bs i) (foldri_withIndex f init bs (i+1))
                    else
                        init
            in
                foldri_withIndex f init bs 0
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
        (* val toHexString = foldr ((op ^) o byteToHex) "" *)

        (* Almost inverse of toString (this function disallows the "0x" prefix)
           Only really useful for testing purposes, I imagine. *)
        fun fromHexString s =
            let
                val result = Word8Array.array (String.size s div 2) zeroByte
                fun f i _ _ = (
                    Word8Array.update result i (hexToByte (String.substring s (2*i) 2));
                    ()
                )
            in (* I'm basically just using foldli as a means of iteration *)
                foldli f () result;
                result
            end

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

        (* Returns a copy of a ByteString *)
        fun copy bs =
            let
                val bsLen = len bs
                val result = Word8Array.array bsLen zeroByte
            in
                Word8Array.copy bs 0 bsLen result 0;
                result
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

        fun xor bs1 bs2 =
            let
                val len = min (len bs1) (len bs2)
                val out = Word8Array.array len zeroByte
                fun xor_withIndex bs1 bs2 out i =
                    if (i < len) then (
                        Word8Array.update out i (Word8.xorb (Word8Array.sub bs1 i) (Word8Array.sub bs2 i));
                        xor_withIndex bs1 bs2 out (i+1)
                    ) else out
            in
                xor_withIndex bs1 bs2 out 0
            end

        (* Treats the ByteString as an abitrary length integer and adds n,
           Returns the same byte_array, whose value has been _mutated_.
           Overflow results in wrap around, e.g. `addInt 0xFF 1` ~> `0x00` *)
        fun addInt bs n =
            let
                val base = 256
                fun addInt_withIndex bs n i =
                    if n <= 0 orelse i < 0
                        then bs
                    else
                        let
                            val sum = (Word8.toInt (Word8Array.sub bs i)) + (n mod base)
                        in
                            Word8Array.update bs i (Word8.fromInt (sum mod base));
                            addInt_withIndex bs ((n div base) + (sum div base)) (i - 1)
                        end
            in
                addInt_withIndex bs n (Word8Array.length bs - 1)
            end

    end
end
