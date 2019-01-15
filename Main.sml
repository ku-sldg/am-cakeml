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

Expected result: 0xDDAF35A193617ABACC417349AE20413112E6FA4E89A97EA20A9EEEE64B55D39A2192992A274FC1A836BA3C23A3FEEBBD454D4423643CE80E2A9AC94FA54CA49F
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

(* Just prints a nonce. It's difficult to determine the quality of a single
   random number though. At the very least, we can verify a new number is
   printed at each invocation. *)
fun nonceTest () =
    print ("Nonce test: " ^ (ByteString.toString (genNonce ())) ^ "\n\n" )

(*
The purpose of this function is to create a large file of random bytes, to
be analyzed by NIST's statistical test suite for CSPRNGs:
    https://www.nist.gov/publications/statistical-test-suite-random-and-pseudorandom-number-generators-cryptographic
*)
fun genRandFile filename len =
    let
        val fd = TextIO.openOut filename
        val _ = funpow (fn _ => (
                    TextIO.output fd (ByteString.toRawString (rand ())); ()
                )) len ()
    in
        TextIO.close fd
    end
(* val _ = genRandFile "rand" 5000000 *)


(* Testing addition over arbitrary length ByteStrings. Needed for CTR mode.
   Expected result: increment by 1 each time *)
fun bsAddTest () =
    let
        val _ = print "Bytesring addition test: \n"
        val _ = funpow (fn bs =>
                    let val _ = print (ByteString.toString bs ^ "\n")
                    in ByteString.addInt bs 1 end
                ) 5 (ByteString.fromHexString "A0FFFE")
        val _ = print "\n"
    in () end

(*
Based on test case from Appendix C.3 from the following NIST publication:
   https://csrc.nist.gov/csrc/media/publications/fips/197/final/documents/fips-197.pdf
Expected result: 0x8ea2b7ca516745bfeafc49904b496089
*)
fun aes256Test () =
    let
        val hexToRaw = ByteString.toRawString o ByteString.fromHexString
        val key   = hexToRaw "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f"
        val xkey  = ByteString.toRawString (aes256_xkey key)
        val pt    = hexToRaw "00112233445566778899aabbccddeeff"
        val ct    = ByteString.toString (aes256 pt xkey)
    in
        print ("AES-256 test: " ^ ct ^ "\n\n")
    end

(*
Using example vector with known answer. See section F.5.5,
"CTR-AES256.Encrypt" from the following NIST publication:
    https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-38a.pdf
Expected results:
    0x601ec313775789a5b7a7f504bbf3d228
    0xf443e3ca4d62b59aca84e990cacaf5c5
    0x2b0930daa23de94ce87017ba2d84988d
*)
fun aes256CtrTest () =
    let
        val key   = ByteString.fromHexString "603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4"
        val nonce = ByteString.fromHexString "f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff"
        val ctr = Aes256Ctr.init key nonce

        val pt1 = ByteString.fromHexString "6bc1bee22e409f96e93d7e117393172a"
        val pt2 = ByteString.fromHexString "ae2d8a571e03ac9c9eb76fac45af8e51"
        val pt3 = ByteString.fromHexString "30c81c46a35ce411e5fbc1191a0a52ef"

        val ct1 = ByteString.toString (Aes256Ctr.encrBlock ctr pt1)
        val ct2 = ByteString.toString (Aes256Ctr.encrBlock ctr pt2)
        val ct3 = ByteString.toString (Aes256Ctr.encrBlock ctr pt3)
    in
        print ("AES-256 CTR test: "       ^ "\n"  ^
               "Encrypted text 1: " ^ ct1 ^ "\n"  ^
               "Encrypted text 2: " ^ ct2 ^ "\n"  ^
               "Encrypted text 3: " ^ ct3 ^ "\n\n")
    end


(* Run all tests *)
(* This function could have been written with sequencing/semicolons. However,
   due to right-to-left evaluation, we would see the print statements in the
   opposite order than is intuitive. *)
fun main () =
    let
        val _ = hashTests ()
        val _ = nonceTest ()
        val _ = bsAddTest ()
        val _ = aes256Test ()
        val _ = aes256CtrTest ()
    in () end
val _ = main ()