(* No external dependencies *)

(*
This is an implementation for ByteStrings which somewhat resembles the Haskell
ByteString library.

It is based on the byte_array type, which underlies the Word8Array structure.
FFI calls use the byte_array type as their second argument (typically acting
as the return slot), making ByteStrings convenient for use with FFI.
*)

structure ByteString = struct
    (* The type of ByteStrings - this is the same type used by Word8Array *)
    type bs = byte_array

    (* Raised by hexToByte/toHexString/unshow
      if there exists a non-hexit char, i.e. != 0..9, a..f, or A..F *)
    exception InvalidHexString

    val zeroByte = Word8.fromInt 0
    val empty = Word8Array.array 0 zeroByte

    val length = Word8Array.length
    fun isEmpty bs = length bs = 0

    local
        val maskUpper = Word8.fromInt 15 (* = 0x0F = 0b00001111 *)
        val hexits = Array.fromList ["0","1","2","3","4","5","6","7","8","9",
                                     "A","B","C","D","E","F"]
        val getHexit = Array.sub hexits
    in
        (* word8 -> 2-char string *)
        fun byteToHex b =
            let val top = Word8.toInt (Word8.>> b 4)
                val bot = Word8.toInt (Word8.andb b maskUpper)
             in getHexit top ^ getHexit bot
            end
    end

    (* 2-char string -> word8, Inverse of byteToHex.
       This will silently crash if the string you give it isn't at least 2 chars
       long. You've been warned! *)
    local
        val bytes = Array.tabulate 16 Word8.fromInt
        fun hexMap h = case h
          of #"0" => 0  | #"1" => 1  | #"2" => 2  | #"3" => 3  | #"4" => 4
           | #"5" => 5  | #"6" => 6  | #"7" => 7  | #"8" => 8  | #"9" => 9
           | #"a" => 10 | #"A" => 10 | #"b" => 11 | #"B" => 11
           | #"c" => 12 | #"C" => 12 | #"d" => 13 | #"D" => 13
           | #"e" => 14 | #"E" => 14 | #"f" => 15 | #"F" => 15
           |   _  => raise InvalidHexString
        val getHalfByte = Array.sub bytes o hexMap
    in
        fun hexToByte s =
            let val top = String.sub s 0
                val bot = String.sub s 1
             in Word8.orb (Word8.<< (getHalfByte top) 4) (getHalfByte bot)
            end
    end

    (* (a -> word8 -> a) -> a -> byte_array -> a *)
    fun foldl f z bs =
        let val len = length bs
            fun foldl_aux z' i = if i < len
                then foldl_aux (f z' (Word8Array.sub bs i)) (i+1)
                else z'
         in foldl_aux z 0
        end

    (* (int -> a -> word8 -> a) -> a -> byte_array -> a *)
    fun foldli f z bs =
        let val len = length bs
            fun foldli_aux z' i = if i < len
                then foldli_aux (f i z' (Word8Array.sub bs i)) (i+1)
                else z'
         in foldli_aux z 0
        end

    (* (word8 -> a -> a) -> a -> byte_array -> a *)
    fun foldr f z bs =
        let val len = length bs
            fun foldr_aux z' i = if i < len
                then f (Word8Array.sub bs i) (foldr_aux z' (i+1))
                else z'
         in foldr_aux z 0
        end

    (* (int -> word8 -> a -> a) -> a -> byte_array -> a *)
    fun foldri f z bs =
        let val len = length bs
            fun foldri_aux z' i = if i < len
                then f i (Word8Array.sub bs i) (foldri_aux z' (i+1))
                else z
         in foldri_aux z 0
        end

    (* Previously called `toString`, changed to emphasize the distinction
       between this and `toRawString`. The "0x" prefix was also dropped,
       since it didn't seem to add much and made parsing more difficult. *)
    val toHexString = foldr ((op ^) o byteToHex) ""

    (* This function is ideal for pretty printing byte strings. It gives
       you a hex string along with the "0x" prefix *)
    fun show bs = "0x" ^ toHexString bs

    fun fromHexString s =
        let val len = String.size s div 2
            val arr = Word8Array.array len zeroByte
            fun fromHexString_aux i =
                if i < len then (
                    Word8Array.update arr i (hexToByte (String.substring s (2*i) 2));
                    fromHexString_aux (i+1)
                ) else arr
         in fromHexString_aux 0
        end

    fun unshow s =
        if (String.isPrefix "0x" s) orelse (String.isPrefix "0X" s)
        then fromHexString (String.substring s 2 ((String.size s) - 2))
        else raise InvalidHexString

    (* Essentially a naive casting operation. This function is meant for use
       with FFI functions. Don't use this to print ByteStrings, you'll
       probably have some unprintable characters in the string. Use toHexString
       or show instead. *)
    fun toRawString bs = Word8Array.substring bs 0 (length bs)

    (* Inverse of toRawString *)
    fun fromRawString s =
        let val size = String.size s
            val arr = Word8Array.array size (Word8.fromInt 0)
         in Word8Array.copyVec s 0 size arr 0;
            arr
        end

    fun copy bs =
        let val bsLen = length bs
            val arr = Word8Array.array bsLen zeroByte
         in Word8Array.copy bs 0 bsLen arr 0;
            arr
        end

    fun append bs1 bs2 =
        let val bs1Len = length bs1
            val bs2Len = length bs2
            val arr = Word8Array.array (bs1Len + bs2Len) zeroByte
         in Word8Array.copy bs1 0 bs1Len arr 0;
            Word8Array.copy bs2 0 bs2Len arr bs1Len;
            arr
        end

    (* bs1 and bs2 should be the same size. If they aren't, the returned
       ByteString will be the size of the smaller input, and the xor will
       be performed from the left side (e.g. 0x00F xor 0xFF = 0xFF). *)
    fun xor bs1 bs2 =
        let val len = min (length bs1) (length bs2)
            val arr = Word8Array.array len zeroByte
            fun xor_aux i =
                if i < len then (
                    Word8Array.update arr i (Word8.xorb (Word8Array.sub bs1 i) (Word8Array.sub bs2 i));
                    xor_aux (i+1)
                ) else arr
         in xor_aux 0
        end

    (* Treats the ByteString as an abitrary length integer and adds n,
       Returns the same byte_array, whose value has been _mutated_.
       Overflow results in wrap around, e.g. `addInt 0xFF 1` ~> `0x00` *)
    fun addInt bs n =
        let val base = 256
            fun addInt_aux bs n i =
                if n <= 0 orelse i < 0
                then bs
                else let val sum = (Word8.toInt (Word8Array.sub bs i)) + (n mod base)
                      in Word8Array.update bs i (Word8.fromInt (sum mod base));
                         addInt_aux bs ((n div base) + (sum div base)) (i - 1)
                     end
         in addInt_aux bs n (length bs - 1)
        end
end
