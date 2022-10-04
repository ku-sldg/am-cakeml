(* Depends on: util, copland, system/crypto, am/Measurements, am/CommTypes,
   am/ServerAm*)

(* val am = serverAm (BString.empty) emptyNsMap *)


(*



(* Examples *)
val goldenFileHash = BString.unshow "DDAF35A193617ABACC417349AE20413112E6FA4E89A97EA20A9EEEE64B55D39A2192992A274FC1A836BA3C23A3FEEBBD454D4423643CE80E2A9AC94FA54CA49F"
val goldenDirHash  = BString.unshow "7BE9FDA48F4179E611C698A73CFF09FAF72869431EFEE6EAAD14DE0CB44BBF66503F752B7A8EB17083355F3CE6EB7D2806F236B25AF96A24E22B887405C20081"

(*
The first hash test hashes the string "abc". This is the first example provided
by NIST in their document "Descriptions of SHA-256, SHA-384, and SHA-512",
which can be accessed here:
    http://csrc.nist.gov/groups/STM/cavp/documents/shs/sha256-384-512.pdf

The second hashes a file called "hashTest.txt". This contains the exact same
string (without a final newline char, despite editors really wanting to insert
one) so we can again compare against the desired result.

Expected result:
DDAF35A193617ABACC417349AE20413112E6FA4E89A97EA20A9EEEE64B55D39A2192992A274FC1A836BA3C23A3FEEBBD454D4423643CE80E2A9AC94FA54CA49F
*)

fun copTests () =
    let val t = demo_phrase
        val res = run_cvm_fresh t
    in print ("Phrase ran: \n" ^ (termToString demo_phrase) ^ "\n\n" ^
              "Cvm_St result: \n" ^ (cvm_st_ToString res) ^ "\n"
             )
    end
    handle (Meas.Err s) => TextIO.print_err ("ERROR: " ^ s ^ "\n")

fun hashTests () =
    let (* val evidence  = H (BString.fromString "abc") *)
        (* val hashTest  = evToString (evalTerm am evidence (Asp Hsh)) *)
        val hashFilev = Meas.hashFile "hashTest.txt"
        val hashFileS = BString.show hashFilev
     in print ((* "Hash test: "      ^ hashTest  ^ "\n\n" ^ *)
               "Hash file test: \n" ^ hashFileS ^ "\n" ^
               (if hashFilev = goldenFileHash then "Golden Value Check:  Passed" else "Golden Value Check:  Failed") ^ "\n\n")
    end
    handle (Meas.Err s) => TextIO.print_err ("ERROR: " ^ s ^ "\n")

(*
This test hashes a directory called testDir.

Expected result(composite hash):
7BE9FDA48F4179E611C698A73CFF09FAF72869431EFEE6EAAD14DE0CB44BBF66503F752B7A8EB17083355F3CE6EB7D2806F236B25AF96A24E22B887405C20081
*)
fun hashDirTest () =
    let val hashDirv = BString.empty (* hashDir "testDir" "" *)
        val hashDirS = BString.show hashDirv
     in print ("Hash directory test: \n" ^ hashDirS ^ "\n" ^
              (if hashDirv = goldenDirHash then "Golden Value Check:  Passed" else "Golden Value Check:  Failed") ^ "\n\n")
    end
    handle (Meas.Err s) => TextIO.print_err ("ERROR: " ^ s ^ "\n")

(* Just prints a nonce. It's difficult to determine the quality of a single
   random number though. At the very least, we can verify a new number is
   printed at each invocation. *)
fun nonceTest () = 
    let val rng = Random.seed (Meas.urand 32)
     in print ("Nonce test: \n"
              ^ BString.show (Random.random rng 16) ^ "\n" 
              ^ BString.show (Random.random rng 16) ^ "\n\n")
    end

*)

(*


(* The good signature should pass the check, and the bad signature should fail *)
fun sigTest () =
    let
        (* Evercrypt keys 
        val privGood  = BString.unshow "2E5773B2A19A2CB05FEE44650D8DC877B3D806F74C199043657C805288CD119B"
        val privBad   = BString.unshow "2E5773B2A19A2CB05FEE44650D8DC877B3D806F84C199043657C805288CD119B"
        val pub       = BString.unshow "490E2422528F14AC6A48DDB9D72CB30B8345AF2E939003BC7A33A6057F2FFB0101000000000000002DD0B7F53A560000A049D882A37F00000000000000000000"
         *)

*)
        
(* OpenSSL keys *)
val privGood = BString.unshow "308204bf020100300d06092a864886f70d0101010500048204a9308204a50201000282010100c822fb2b7842e61fa6a779a48f2164793e21d640687146b48ac4e977a4a69f90383c94f3ea5e5336052b728f0a83151603edef890b2a6099376ae87a384a6b236ed51c7f19d94c8b4acb9b00de6cb1c6fc40ff9fec7967ebdbc48cd9b15103411a3b8978d93e59988a7baa21dd3e6fa220359e228f847b81be77bf2467bea40496135a8d06a42c3416bffec3646c8fda7eee19a74275fa2b21bfaa5c8b0dc8e82511b2d8b9a7b760b1d0ae0be03cd98615f3e6c2bc51b1ab11f5b87aad9b44264a2470f26a3a55e4dbd1fa6ea52e66093b4a3eae73bcd7237f07b1ea394a9f893b32d6da15a46f5d7e77c5a6b12ebf41cc7743f4cc241266e58566645dfbbd2102030100010282010100bbe1bb116ff0bdc070df401ef00f55174cf0cf05e006976ddde845948009bc39d3d16bb4200d34e8bda9affe00cc55fb38ed21b5f1b972bde37c858a5755e5867a01aea2d34d5fc25411180e94c04d94943320c6ad64bbde7b8de4fc68adb8f461000b6a5be7608d075458bf39c7e75cb8081dd02c131f2f09f3b88920aba3a4d014cbd13a9ef985ef6be664366ae8b21c4198f582567a5b9fb751bdcd3b4e7a6e160e00a9f5aae2d80755f323fa95fff5aebc8d59b3f093efa4c28a9c42fa2628bd9d8dc19b70b396f7c26a17cb97c3bec9d482b9ae9df425c042c4d4b85d913d2b6ed72c15adccb9f0bc8f1dc6439738db75669f336e1600d4a81b05793e9102818100f61761715d8cc06b4ce8579301f083503a312be0bcc98697ba798fbcb6296cbb064e9d325f780d43ad3aebbcc64cf49b4c8a4bef9c00a72e254e7d3ed22a3e4a7afe46a1599af045a9cb0247b69763c1057b0823cec7fff3f2c9df19936a76c22e03a343b14baac0729751dbe4af83a82c9200b4e711110841cfbc6e6ad3d00b02818100d031ea9a4f7f186943de2fc4ba8050428bc23ff33f4da0d264595257ef26c980bca0a5dfe837335fa1a0bc5b57dca546e0fc584830ac12dc42842b9313865df33b55dfb461f4da95291797429a03e0e9edaf4f4166eb41543fb60a516406ff24fa750a11142720c705fed12a4675351e9304c6e0ac2900d4c40de7f1aa70070302818100eedfcd1f5cbe667d013f3adaa0f454928899f84c83145f4862a2e2ea3c2c43b5db2e6e1a5a5f4f08d55b2f3ea38249a1818f709c5a62abe4f82393216aa1c4ab496e0f2349b642ea6c2179ca20ac1d115cff8aec2f2926032735db10996eab6e5b79fe7d93d8ae1b765ff9fea7a1d2fb68a0247d7519b4ddbdfc269d4ba6e4f702818100b6f3064b6f8c29f166983ab5cf85ae01ac3a9863b2bf0e91936902790f48b04d96743d0f134a5eb4ac9d48a7a3ffdaa4fc540367fc8d594d808e10947fd5d57d4628e219eaf2759a19b00755996dcb1905aac6249cc222785c3c25b8fc0341f646b8ce8dcf7dcac9d9b4e02d1c192702a502cf98e2f06d308ad0058051db7bed0281807fc3b60f0319ff7b6339995b2286ef4fa7559c50383f2cf8af7f9c74af69b172dcb2770ec78e75e06edce4f71d1228c7a9ca5c6603f66d68577a7c9b5756e24eae64371f1ee2bbbd39ded225024f19015ace20b9715af05050a1ed1d16796c01a179656780eb58ded60dd830f872a8d3d94a91cd6c149beb1974339a833a54e3"


val privBad = BString.unshow "308204bd020100300d06092a864886f70d0101010500048204a7308204a30201000282010100c1cce94fa00c62888fa8611cb71a409685ec80d8515e85754e9e29c8febfd1cea93d532f1bbc610c83bf4f5279b12e8568a44921f651dc3daf1b4c385015aba07ea9732245c52b9c2fdb62e537f986ca7986edd72a07b56dea7d0c19a78e22225f3db39d910ff3ab2b61e298afe7d247eff18bdb06b531d160a9024f128e8660a904c8a3de22e2dc4cf0ced6be8cb5ce389461b76004f76f19e94cf77e8c65079e9f3a4b75ce9aa391959d307614850994ff0878e5040d184b5e7a4270874b000b170c54ae0cf4327afdb30832325477344bc5c912b7b11fdf9e837f11ddbe860e6640e726ef96fa3b383ce0d5ddb6e8ff02b33ceecfc057fc84a0171a2f429d020301000102820100077f0c9b46de93c5228169d83980eb74a71381dc5c3162ca29d3565c6ef62e8066ed77554026663e9cadfebc7af68e8d1c82164e19000b9bdb351c1aa586611021361ebcf9a3e9ceedcef7a1542bf3b9cb3f9bdd91c3a091f2db0967c8a267d19a8b81721bd559208ada0b70ca85160e304ad095154a56f5f95e3037acc9148b8147587f9ceea8ece9bdccd85e8a5670bb77b932517c24f4ae5e17c485f470b40b9f4120ffe020a95995d858fa7d2eca9c5688e100e33027384b104e4fdb47c28a5149c6b9eaa6dff7f97001a8e592225f8af5075a240acbabf8ddf9565e74d6703d9e73e6d6594b9edf703897e4689fe4fae70f7053dad6e901d8beb591822102818100f90f4b8166514f41f3156cccb3eeea7dd44cdbcb36f011733abf1b098ad153e4347546bf0d4dd13ce3b585969114b8d0ab0d859ee8580118c645635fb3072274f500bae01322624e34b08c9e655426f0ae517d3db831d7e0baa4a161060d3635bd274bc8575f9336d2be8dd56f5495b1260bdba20fdad11ccd94acdab064c28502818100c7336a74d44b615add44dab35b3ba337278a68ef6c983ca5cc81551c88e41a13ba9e9d95654238d774b28ddfb1472aaa4eea37dd8b8c5545dcb9b2ab622637e94c6f60e7a8d06f7e650fa6c1c4dddf2a74e0ad186a08ef643ad5f008668560bcde9eece34cf64ce1624f28bacd56e32e98c1ebde643a991d1add987e870e173902818100b1eef86d9110c40404cba8b832509d1c9a60f2a22334adf2d9e4904767f296f1b17c9bb780a4b8b8bca201b7891cf9d0b273eda392b0d4cfc34eed6900793767c165ed1c8aef04b684b421324488336dbdcc2022c9066b0975ae8a50cbc70294aff7740fc44456e352faaa4ff2c2c653123064904aad74ba143184b09456d8150281804f73f6963ac70641d3d7ced393242a69a95fcf930fe178ef38aead600049db0cdb76c0ac020373e09c2f4bdf593a658e2083d35c8e789eda8abb96c43d15b95f58996431826800d08d46bce0b4c13a6e18c834c27428b4336a3442d556ef0432d128da9b9eeaeea7472b03b7de87357e3477c4b8a389abe0ac028efc88a9da210281804c2882c654c7771b589a08550fc6da76e132befae16ccba34b3f76f83fccb734e0385ab184ea7490af034e21a2378df61e21e447381916954555caf41205fb1df6101573714b011ba76e9245e01d23c5a296df9b18cdbea3912ead3ca5cc653b0edb9ae7e8c4596ce9b73afe7c456af4b9039d7b5a3166b96333dc57d0f23735"


val pub = BString.unshow "3082010a0282010100c822fb2b7842e61fa6a779a48f2164793e21d640687146b48ac4e977a4a69f90383c94f3ea5e5336052b728f0a83151603edef890b2a6099376ae87a384a6b236ed51c7f19d94c8b4acb9b00de6cb1c6fc40ff9fec7967ebdbc48cd9b15103411a3b8978d93e59988a7baa21dd3e6fa220359e228f847b81be77bf2467bea40496135a8d06a42c3416bffec3646c8fda7eee19a74275fa2b21bfaa5c8b0dc8e82511b2d8b9a7b760b1d0ae0be03cd98615f3e6c2bc51b1ab11f5b87aad9b44264a2470f26a3a55e4dbd1fa6ea52e66093b4a3eae73bcd7237f07b1ea394a9f893b32d6da15a46f5d7e77c5a6b12ebf41cc7743f4cc241266e58566645dfbbd210203010001"


(*

                         

        (* TPM
        val filename  = BString.fromString "data.txt" 
        val mySetup = Crypto.tpmSetup
        val myCreate = Crypto.tpmCreateSigKey
        val myGetData = Crypto.getData
        val mySign = Crypto.tpmSign filename (* tpmSign should actually take result from get_data as input *)
         *)
        
        (* Evercrypt and OpenSSL *)
        val msg       = BString.fromString "foo bar"
        val signGood  = Crypto.signMsg privGood msg
        val signBad   = Crypto.signMsg privBad  msg
        val checkGood = Crypto.sigCheck pub signGood msg
        val checkBad  = Crypto.sigCheck pub signBad msg
    in
        (* TPM
        print("Setup TPM: " ^ (if mySetup then "Success" else "Fail") ^ "\n\n" ^
            "Create and Load TPM Signing Key: " ^ (if myCreate then "Success" else "Fail") ^ "\n\n" ^
            "Get data: " ^ (BString.show myGetData) ^ "\n\n" ^
            "Sign file with TPM: " ^ (BString.show mySign) ^ "\n\n") 
         *)
        (* Evercrypt and OpenSSL *)
        print ("Good Signature: \n" ^ (BString.show signGood) ^ "\n" ^
               "Signature Check: "  ^ (if checkGood then "Passed" else "Failed") ^ "\n\n" ^
               "Bad Signature: \n"  ^ (BString.show signBad) ^ "\n" ^
               "Signature Check: "  ^ (if checkBad  then "Passed" else "Failed") ^ "\n")
    end


*)



(*
                         
(* Encryption test *)
fun encryptTest () =
    let
*)

                         
val priv1 = BString.unshow "308202260201003082011706092a864886f70d010301308201080282010100c4bdfbb69055be49894bffad8f70c4dc6bb37672f925b84ef1d42f8488cefc207c9f082b6436431649917f77e833ccb34d2c886fcb3eb7cbd0b4139f5bc4d353c826400ca4b470ace06a28a7fa66240e819aea538ba0468eeb4d72bdd63b6929d377ab48a50477c4297a151a88631d8bf21851eb8b16d1ace2f3a33aee09fa54eb6f7cacca2e04169e3018eafbff583db0ded4222c438b463cb5fdaf41b842ebccc1a41b2603fc958c48f63628b5040fddcdb330c64a39f1f162501edaa080b5371798c1e334163076faf1e9ea8cdd82588d9635f84a302998ea9c38e236dd374e7bb25f793a937e4e0dc4b4c5777309a0a1ea837951cab0b120e649a496dabf02010204820104028201005b984694c9b5728c00b22440bbe8dd629cb915cc2cc8c46bef8e24aa007f3b516c4c7807e65de2bc041d1304b1f82707f69ff7b6e4f87ce146d7e25a52a9ac1e2168b0e64a22c6b7daccd4577ed323b0574897c8b292cabec38b3f2e2d4ddc5066b6fcbf46a9f1daf1d78304536793bd0333bccde98976705446b84599dc4c9219de4f350fae7a7c905b301bff54c25925f22cb713fa6ac568bcc1b59a56278b3a3ab616942903ef35e7d40c018731ab1cadd78f89e357549826582f586ec8d67fe5480912c65f97fd97226bf8b457e6083971fb1419661f9b0998ac1c52bc83645e3d7cdf5451e171bf0c64bf4fe072670e67f35e54f59a6a17f4baed47ce45"


val pub1 = BString.unshow "308202243082011706092a864886f70d010301308201080282010100c4bdfbb69055be49894bffad8f70c4dc6bb37672f925b84ef1d42f8488cefc207c9f082b6436431649917f77e833ccb34d2c886fcb3eb7cbd0b4139f5bc4d353c826400ca4b470ace06a28a7fa66240e819aea538ba0468eeb4d72bdd63b6929d377ab48a50477c4297a151a88631d8bf21851eb8b16d1ace2f3a33aee09fa54eb6f7cacca2e04169e3018eafbff583db0ded4222c438b463cb5fdaf41b842ebccc1a41b2603fc958c48f63628b5040fddcdb330c64a39f1f162501edaa080b5371798c1e334163076faf1e9ea8cdd82588d9635f84a302998ea9c38e236dd374e7bb25f793a937e4e0dc4b4c5777309a0a1ea837951cab0b120e649a496dabf02010203820105000282010045375d15a62aa268929379ac9ce0e3bd3fe318a97cb16b107f2899c7912751bdbd2bace416b36b68c4eb701d2fdd9ecf167411821d2d7956dc97bfb46a00e1be8280f2b97d5f9ca932ca5bea032c10214711460c3360bd10e891850bb93c91971822e527b1b64dc60b713cc9f100c5b983c4f616bdbf3e8b8cfc51d06e7f0dc87165b29caebc3732b4c6a7f201e4163b97c7520fe8ece7117edb3e82f2031869cc98b0a4726b9a06291d4b538325810c4d58daf9a13ab3bbc457ec5d43ebf00d33ef9b7fc7ebb7f828e9f28fe6c2708283855abda66dec49c5bb9e5bc30e39a134981186a68753f47ae7b6c751434901e9b970b1ce2fd72b0745fc3c2ecfdf9b"


val priv2 = BString.unshow "308202260201003082011706092a864886f70d010301308201080282010100c4bdfbb69055be49894bffad8f70c4dc6bb37672f925b84ef1d42f8488cefc207c9f082b6436431649917f77e833ccb34d2c886fcb3eb7cbd0b4139f5bc4d353c826400ca4b470ace06a28a7fa66240e819aea538ba0468eeb4d72bdd63b6929d377ab48a50477c4297a151a88631d8bf21851eb8b16d1ace2f3a33aee09fa54eb6f7cacca2e04169e3018eafbff583db0ded4222c438b463cb5fdaf41b842ebccc1a41b2603fc958c48f63628b5040fddcdb330c64a39f1f162501edaa080b5371798c1e334163076faf1e9ea8cdd82588d9635f84a302998ea9c38e236dd374e7bb25f793a937e4e0dc4b4c5777309a0a1ea837951cab0b120e649a496dabf02010204820104028201005b0638014e949bbbf8aed699e4ba9690d4d53c1de27596d215d07f086ea2475f8d67d1dee7ad5192eb79a58ff7cf1cbce571834654e13de2e315da720b81c13c4daf11740df61960e02103d7181a9de97b966ad9e5d5b85df890885af4432ba483face41e7a9d3278b407cddb07184e9a8af1bd49faece0d6586e1810911aea6543a134df2113cbe086bfa64ffe7e245becee4a1f1c144a5d7f8d492535b20bcb7d1da28003c1f49c188b67b50bd0bc8942709d4de5a898137f9a9b3eba8ff65091db219897097287768976f46e5ae55f43bedbfff12c438e09a7e2704f990a8647a0fb76283578c48a6c3f362f8f931821849ae7274c5c2629de8fec957e296"


val pub2 = BString.unshow "308202243082011706092a864886f70d010301308201080282010100c4bdfbb69055be49894bffad8f70c4dc6bb37672f925b84ef1d42f8488cefc207c9f082b6436431649917f77e833ccb34d2c886fcb3eb7cbd0b4139f5bc4d353c826400ca4b470ace06a28a7fa66240e819aea538ba0468eeb4d72bdd63b6929d377ab48a50477c4297a151a88631d8bf21851eb8b16d1ace2f3a33aee09fa54eb6f7cacca2e04169e3018eafbff583db0ded4222c438b463cb5fdaf41b842ebccc1a41b2603fc958c48f63628b5040fddcdb330c64a39f1f162501edaa080b5371798c1e334163076faf1e9ea8cdd82588d9635f84a302998ea9c38e236dd374e7bb25f793a937e4e0dc4b4c5777309a0a1ea837951cab0b120e649a496dabf02010203820105000282010062de26782b5f99efad91ff50311776e1a8eab8e3f5381a77cb9153a5128aacfdb7cdcd4cb1f6001923fb06693909eeb56e198b6bdd82b7811e72d3d0c18f227371942c4aac9f334d66c107a2d1211b8aed816ee2ecda2d558e22ef7d5c484c11c491a3fa5498cf39755d2541cd4df8c7fabfee572ffcf16da457d74305a33bf517c621965bcd3b9368e60e4e4ae87b6e14a1918a62ae52d897748442018a7b872a036518d0a6b45327b562db23dbb9a7b8996700fa32577415019035f3d2c23e35e1315eb020f05f734402cbfb6fc67f3b445bdd8b8149cfb85bfa13882f8edea0c40f4ae44f9081c7f4b70cb65ebb591de9847d3a40b62a8e65b5602c41737e"

                          (*
        val plaintext = "The quick brown fox jumped over the lazy dog."
        val ciphertext = Crypto.encryptOneShot priv1 pub2 plaintext
        val recoveredtext = Crypto.decryptOneShot priv2 pub1 ciphertext
    in
        print (String.concat ["Plaintext: \"", plaintext, "\"\n",
            "Ciphertext: ", BString.show ciphertext, "\n",
            "Plaintext: \"", recoveredtext, "\"\n"])
    end

(* Run all tests *)
fun main () = (
    copTests ();
    (*
    hashTests ();
    hashDirTest ();
    nonceTest (); *)
    sigTest ();
    encryptTest ()
) handle Meas.Err msg => TextIO.print_err ("Meas err: " ^ msg ^ "\n")
       | Crypto.Err msg => TextIO.print_err ("Crypto err: " ^ msg ^ "\n")
       | Word8Extra.InvalidHex => TextIO.print_err ("Invalid hex\n")
       | _ => TextIO.print_err "Fatal: unknown error\n"
val _ = main ()

*)

val blockchainIpAddr = "127.0.0.1"
val blockchainIpPort = 8543
val jsonId = 3 (* any positive integer will do *)

(* val healthRecordContract = "0x744e262E95Eb21B383947E925e73153581dC6bFF" *)
(* val healthRecordContract = "0x6187E9EB7C3072018A58ed444df619e29af8f460" *)
val healthRecordContract = "0xe91a430d5b19e521193732678D6Cb369D857b930"

(* val userAddress = "0xbb1db114f1535e8b01f54a5fc9ab19146fdff846" *)
(* val userAddress = "0x9FF83fAea1bb7d67FfF72e859DDD68F94EffeCE6" *)
val userAddress = "0xd8e920A871ea48f2F0d7859B72602245b9c0621c"