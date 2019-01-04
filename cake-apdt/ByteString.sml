(*
This is an implementation for byteStrings which somewhat resembles the Haskell
byteString library.

It is currently based on Vectors, which differ fromm Arrays in that they are
immutable. This may be rewritten using arrays if immutablity is getting in the
way of performance, or if it proves difficult to move vectors in and out of
arrays for the purpose of ffi calls.

TODO: Make into a structure
*)

type bs = word8 Vector.vector

(* Function mapping byte (Word8) to hex representation (string) *)
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
end;

(* Returns a string of the hexadecimal representation *)
val bsToString = Vector.foldl (fn s => fn w => s ^ (byteToHex w)) "0x"

(* Creates an empty byteString *)
val bsEmpty = Vector.fromList (nil: word8 list)

fun bsIsEmpty vec = Vector.length vec = 0
val bsLen = Vector.length

(* Appends 2 byteStrings *)
fun bsAppend bs1 bs2 = Vector.concat [bs1, bs2]
