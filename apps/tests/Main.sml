(* Depends on: util, copland, system/crypto, am/Measurements, am/CommTypes,
   am/ServerAm*)

val am = serverAm "" emptyNsMap

(* Examples *)

(*
The first hash test hashes the string "abc". This is the first example provided
by NIST in their document "Descriptions of SHA-256, SHA-384, and SHA-512",
which can be accessed here:
    http://csrc.nist.gov/groups/STM/cavp/documents/shs/sha256-384-512.pdf

The second hashes a file called "hashTest.txt". This contains the exact same
string (without a final newline char, despite editors really wanting to insert
one) so we can again compare against the desired result.

Expected result: 0xDDAF35A193617ABACC417349AE20413112E6FA4E89A97EA20A9EEEE64B55D39A2192992A274FC1A836BA3C23A3FEEBBD454D4423643CE80E2A9AC94FA54CA49F
*)
fun hashTests () =
    let val evidence = H (ByteString.fromRawString "abc")
        val hashTest = evToString (evalTerm am evidence (Asp Hsh))
        val hashFile = (ByteString.show (Crypto.hashFile "hashTest.txt"))
            handle _ => "ERROR: could not find 'hashTest.txt' in the present working directory"
     in print ("Hash test: "      ^ hashTest  ^ "\n\n" ^
               "Hash file test: " ^ hashFile  ^ "\n\n" )
    end

(* Just prints a nonce. It's difficult to determine the quality of a single
   random number though. At the very least, we can verify a new number is
   printed at each invocation. *)
fun nonceTest () = print ("Nonce test: " ^ ByteString.show (genNonce ()) ^ "\n\n")

(* fun idstringTest () =
    let val s = "asdffdsa"
    in print ("idstring(" ^ s ^ "): " ^ (ByteString.show (dooidstring (s))) ^ "\n\n")
    end *)


(*
The purpose of this function is to create a large file of random bytes, to
be analyzed by NIST's statistical test suite for CSPRNGs:
    https://www.nist.gov/publications/statistical-test-suite-random-and-pseudorandom-number-generators-cryptographic
*)
(* fun genRandFile filename len =
    let val fd = TextIO.openOut filename
        val writeRand = TextIO.output fd o ByteString.toRawString o rand
     in funpow writeRand len ();
        TextIO.closeOut fd
    end *)
(* val _ = genRandFile "rand" 5000000 *)

(* The good signature should pass the check, and the bad signature should fail *)
fun sigTest () =
    let val hexToRaw  = ByteString.toRawString o ByteString.fromHexString
        val privGood  = hexToRaw "2E5773B2A19A2CB05FEE44650D8DC877B3D806F74C199043657C805288CD119B"
        val privBad   = hexToRaw "2E5773B2A19A2CB05FEE44650D8DC877B3D806F84C199043657C805288CD119B"
        val pub       = hexToRaw "490E2422528F14AC6A48DDB9D72CB30B8345AF2E939003BC7A33A6057F2FFB0101000000000000002DD0B7F53A560000A049D882A37F00000000000000000000"
        val msg       = ByteString.fromRawString "foo bar"
        val signGood  = Crypto.signMsg privGood msg
        val signBad   = Crypto.signMsg privBad  msg
        val checkGood = Crypto.sigCheck pub signGood msg
        val checkBad  = Crypto.sigCheck pub signBad msg
     in print ("Good Signature: \n" ^ (ByteString.show signGood) ^ "\n" ^
               "Signature Check: "  ^ (if checkGood then "Passed" else "Failed") ^ "\n\n" ^
               "Bad Signature: \n"  ^ (ByteString.show signBad) ^ "\n" ^
               "Signature Check: "  ^ (if checkBad  then "Passed" else "Failed") ^ "\n")
    end

(* Run all tests *)
fun main () = (
    hashTests ();
    nonceTest ();
    (* idstringTest(); *)
    sigTest ()
    ) handle _ => TextIO.print_err "Fatal: unknown error\n"
val _ = main ()
