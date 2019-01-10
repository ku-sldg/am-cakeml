(* Depends on: Eval.sml, ByteString.sml, CoplandLang.sml, Measurements.sml,
   and crypto/Aes256.sml*)

(* Examples *)

(*
The first hash test hashes the string "abc". This is the first example provided
by NIST in their document "Descriptions of SHA-256, SHA-384, and SHA-512",
which can be accessed here:
    http://csrc.nist.gov/groups/STM/cavp/documents/shs/sha256-384-512.pdf
Or if the government shutdown is still going on when you read this and the NIST
website is still unavailable due to the lapse in funding, you can access it
via the wayback machine:
    https://web.archive.org/web/20130526224224/http://csrc.nist.gov/groups/STM/cavp/documents/shs/sha256-384-512.pdf

The second hashes a file called "hashTest.txt". This contains the exact same
string (without a final newline char, despite editors really wanting to insert
one) so we can again compare against the desired result.
*)
fun hashTests () =
    let
        val evidence  = H O (ByteString.fromRawString "abc")
        val hashTest  = evToString (eval O evidence HSH)
        val hashFile  = ByteString.toString (genFileHash "hashTest.txt")
    in
        print ("Hash test: "      ^ hashTest  ^ "\n\n" ^
               "Hash file test: " ^ hashFile  ^ "\n\n" )
    end

(* Just prints a nonce. It's difficult to really measure randomness *)
fun nonceTest () =
    print ("Nonce test: " ^ (ByteString.toString (genNonce ())) ^ "\n\n" )

(*
Using example vector with known answer. See section F.5.5,
"CTR-AES256.Encrypt" from the following NIST publication:
    https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-38a.pdf
*)

(* Not currently giving expected values.
   Potential causes: unnacounted endianness, byte_array addition *)
fun aes256CtrTest () =
    let
        val key   = ByteString.fromHexString "603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4"
        val nonce = ByteString.fromHexString "f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff"
        val ctr = Aes256Ctr.init key nonce

        val pt1 = ByteString.fromHexString "6bc1bee22e409f96e93d7e117393172a"
        val pt2 = ByteString.fromHexString "ae2d8a571e03ac9c9eb76fac45af8e51"

        val _ = print ("AES-256 CTR test: " ^ "\n")
        val _ = print ((let val (_, _, v) = ctr in (ByteString.toString v) end) ^ "\n")
        val _ = print ("Encrypted text 1: " ^ (ByteString.toString (Aes256Ctr.encrCtr ctr)) ^ "\n")
        val _ = print ((let val (_, _, v) = ctr in (ByteString.toString v) end) ^ "\n\n")
    in () end

(* fun aes256CtrTest () =
    let
        val key   = ByteString.fromHexString "603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4"
        val nonce = ByteString.fromHexString "f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff"
        val ctr = Aes256Ctr.init key nonce

        val pt1 = ByteString.fromHexString "6bc1bee22e409f96e93d7e117393172a"
        val pt2 = ByteString.fromHexString "ae2d8a571e03ac9c9eb76fac45af8e51"
    in
        print ("AES-256 CTR test: " ^ "\n" ^
               "Encrypted text 1: " ^ (ByteString.toString (Aes256Ctr.encrBlock ctr pt1)) ^ "\n" ^
               (let val (_, _, v) = ctr in (ByteString.toString v) end) ^ "\n" ^
               "Encrypted text 2: " ^ (ByteString.toString (Aes256Ctr.encrBlock ctr pt2)) ^ "\n" ^
               (let val (_, _, v) = ctr in (ByteString.toString v) end) ^ "\n\n")
    end *)

(* Run all tests *)
(* This function could have been written with sequencing/semicolons. However,
   due to right-to-left evaluation, we would see the print statements in the
   opposite order than is intuitive. *)
fun main () =
    let
        val _ = hashTests ()
        val _ = nonceTest ()
        val _ = aes256CtrTest ()
    in () end
val _ = main ()
