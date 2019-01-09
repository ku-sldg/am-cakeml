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

Finally, we test nonce generation.
*)

fun main () =
    let
        val evidence  = H O (ByteString.fromRawString "abc")
        val hashTest  = evToString (eval O evidence HSH)
        val hashFile  = ByteString.toString (genFileHash "hashTest.txt")
        val nonceTest = ByteString.toString (genNonce ())
    in
        print ("Hash test: "      ^ hashTest  ^ "\n\n" ^
               "Hash file test: " ^ hashFile  ^ "\n\n" ^
               "Nonce test: "     ^ nonceTest ^ "\n\n" )
    end
val _ = main ()
