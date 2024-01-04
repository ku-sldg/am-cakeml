(* Depends on:  stubs/BS.sml, extracted/Term_Defs_Core.cml, 
     extracted/Term_Defs.cml, ... (TODO: crypto dependencies?) *)

(* CLEANUP:
Change CMake structure so that 
'appraisal_asps' and 'attestation_asps'
build their own folders respectively
 *)



(* CLEANUP: Add this as a stub in Coq (Appraisal_IO_Stubs.v?) *)
(* 
   fun decode_RawEv : coq_BS -> coq_RawEv
   This should be the inverse of encode_RawEv.
*)
fun decode_RawEv bsval = jsonBsListToList (strToJson (BString.toString bsval))


val pub = BString.unshow "3082010a0282010100c822fb2b7842e61fa6a779a48f2164793e21d640687146b48ac4e977a4a69f90383c94f3ea5e5336052b728f0a83151603edef890b2a6099376ae87a384a6b236ed51c7f19d94c8b4acb9b00de6cb1c6fc40ff9fec7967ebdbc48cd9b15103411a3b8978d93e59988a7baa21dd3e6fa220359e228f847b81be77bf2467bea40496135a8d06a42c3416bffec3646c8fda7eee19a74275fa2b21bfaa5c8b0dc8e82511b2d8b9a7b760b1d0ae0be03cd98615f3e6c2bc51b1ab11f5b87aad9b44264a2470f26a3a55e4dbd1fa6ea52e66093b4a3eae73bcd7237f07b1ea394a9f893b32d6da15a46f5d7e77c5a6b12ebf41cc7743f4cc241266e58566645dfbbd210203010001"
                         
val priv1 = BString.unshow "308202260201003082011706092a864886f70d010301308201080282010100c4bdfbb69055be49894bffad8f70c4dc6bb37672f925b84ef1d42f8488cefc207c9f082b6436431649917f77e833ccb34d2c886fcb3eb7cbd0b4139f5bc4d353c826400ca4b470ace06a28a7fa66240e819aea538ba0468eeb4d72bdd63b6929d377ab48a50477c4297a151a88631d8bf21851eb8b16d1ace2f3a33aee09fa54eb6f7cacca2e04169e3018eafbff583db0ded4222c438b463cb5fdaf41b842ebccc1a41b2603fc958c48f63628b5040fddcdb330c64a39f1f162501edaa080b5371798c1e334163076faf1e9ea8cdd82588d9635f84a302998ea9c38e236dd374e7bb25f793a937e4e0dc4b4c5777309a0a1ea837951cab0b120e649a496dabf02010204820104028201005b984694c9b5728c00b22440bbe8dd629cb915cc2cc8c46bef8e24aa007f3b516c4c7807e65de2bc041d1304b1f82707f69ff7b6e4f87ce146d7e25a52a9ac1e2168b0e64a22c6b7daccd4577ed323b0574897c8b292cabec38b3f2e2d4ddc5066b6fcbf46a9f1daf1d78304536793bd0333bccde98976705446b84599dc4c9219de4f350fae7a7c905b301bff54c25925f22cb713fa6ac568bcc1b59a56278b3a3ab616942903ef35e7d40c018731ab1cadd78f89e357549826582f586ec8d67fe5480912c65f97fd97226bf8b457e6083971fb1419661f9b0998ac1c52bc83645e3d7cdf5451e171bf0c64bf4fe072670e67f35e54f59a6a17f4baed47ce45"

val pub1 = BString.unshow "308202243082011706092a864886f70d010301308201080282010100c4bdfbb69055be49894bffad8f70c4dc6bb37672f925b84ef1d42f8488cefc207c9f082b6436431649917f77e833ccb34d2c886fcb3eb7cbd0b4139f5bc4d353c826400ca4b470ace06a28a7fa66240e819aea538ba0468eeb4d72bdd63b6929d377ab48a50477c4297a151a88631d8bf21851eb8b16d1ace2f3a33aee09fa54eb6f7cacca2e04169e3018eafbff583db0ded4222c438b463cb5fdaf41b842ebccc1a41b2603fc958c48f63628b5040fddcdb330c64a39f1f162501edaa080b5371798c1e334163076faf1e9ea8cdd82588d9635f84a302998ea9c38e236dd374e7bb25f793a937e4e0dc4b4c5777309a0a1ea837951cab0b120e649a496dabf02010203820105000282010045375d15a62aa268929379ac9ce0e3bd3fe318a97cb16b107f2899c7912751bdbd2bace416b36b68c4eb701d2fdd9ecf167411821d2d7956dc97bfb46a00e1be8280f2b97d5f9ca932ca5bea032c10214711460c3360bd10e891850bb93c91971822e527b1b64dc60b713cc9f100c5b983c4f616bdbf3e8b8cfc51d06e7f0dc87165b29caebc3732b4c6a7f201e4163b97c7520fe8ece7117edb3e82f2031869cc98b0a4726b9a06291d4b538325810c4d58daf9a13ab3bbc457ec5d43ebf00d33ef9b7fc7ebb7f828e9f28fe6c2708283855abda66dec49c5bb9e5bc30e39a134981186a68753f47ae7b6c751434901e9b970b1ce2fd72b0745fc3c2ecfdf9b"


val priv2 = BString.unshow "308202260201003082011706092a864886f70d010301308201080282010100c4bdfbb69055be49894bffad8f70c4dc6bb37672f925b84ef1d42f8488cefc207c9f082b6436431649917f77e833ccb34d2c886fcb3eb7cbd0b4139f5bc4d353c826400ca4b470ace06a28a7fa66240e819aea538ba0468eeb4d72bdd63b6929d377ab48a50477c4297a151a88631d8bf21851eb8b16d1ace2f3a33aee09fa54eb6f7cacca2e04169e3018eafbff583db0ded4222c438b463cb5fdaf41b842ebccc1a41b2603fc958c48f63628b5040fddcdb330c64a39f1f162501edaa080b5371798c1e334163076faf1e9ea8cdd82588d9635f84a302998ea9c38e236dd374e7bb25f793a937e4e0dc4b4c5777309a0a1ea837951cab0b120e649a496dabf02010204820104028201005b0638014e949bbbf8aed699e4ba9690d4d53c1de27596d215d07f086ea2475f8d67d1dee7ad5192eb79a58ff7cf1cbce571834654e13de2e315da720b81c13c4daf11740df61960e02103d7181a9de97b966ad9e5d5b85df890885af4432ba483face41e7a9d3278b407cddb07184e9a8af1bd49faece0d6586e1810911aea6543a134df2113cbe086bfa64ffe7e245becee4a1f1c144a5d7f8d492535b20bcb7d1da28003c1f49c188b67b50bd0bc8942709d4de5a898137f9a9b3eba8ff65091db219897097287768976f46e5ae55f43bedbfff12c438e09a7e2704f990a8647a0fb76283578c48a6c3f362f8f931821849ae7274c5c2629de8fec957e296"


val pub2 = BString.unshow "308202243082011706092a864886f70d010301308201080282010100c4bdfbb69055be49894bffad8f70c4dc6bb37672f925b84ef1d42f8488cefc207c9f082b6436431649917f77e833ccb34d2c886fcb3eb7cbd0b4139f5bc4d353c826400ca4b470ace06a28a7fa66240e819aea538ba0468eeb4d72bdd63b6929d377ab48a50477c4297a151a88631d8bf21851eb8b16d1ace2f3a33aee09fa54eb6f7cacca2e04169e3018eafbff583db0ded4222c438b463cb5fdaf41b842ebccc1a41b2603fc958c48f63628b5040fddcdb330c64a39f1f162501edaa080b5371798c1e334163076faf1e9ea8cdd82588d9635f84a302998ea9c38e236dd374e7bb25f793a937e4e0dc4b4c5777309a0a1ea837951cab0b120e649a496dabf02010203820105000282010062de26782b5f99efad91ff50311776e1a8eab8e3f5381a77cb9153a5128aacfdb7cdcd4cb1f6001923fb06693909eeb56e198b6bdd82b7811e72d3d0c18f227371942c4aac9f334d66c107a2d1211b8aed816ee2ecda2d558e22ef7d5c484c11c491a3fa5498cf39755d2541cd4df8c7fabfee572ffcf16da457d74305a33bf517c621965bcd3b9368e60e4e4ae87b6e14a1918a62ae52d897748442018a7b872a036518d0a6b45327b562db23dbb9a7b8996700fa32577415019035f3d2c23e35e1315eb020f05f734402cbfb6fc67f3b445bdd8b8149cfb85bfa13882f8edea0c40f4ae44f9081c7f4b70cb65ebb591de9847d3a40b62a8e65b5602c41737e"








(*
(** val decrypt_bs_to_rawev : coq_BS -> coq_ASP_PARAMS -> coq_RawEv **)

fun decrypt_bs_to_rawev bs ps (* priv pub *) =
    let val recoveredtext = "" (* Crypto.decryptOneShot (* priv pub *) priv2 pub1 bs *)
        val bs_recovered = BString.fromString recoveredtext
        val res = decode_RawEv bs_recovered
        val _ = print ("\nDecryption Succeeded: \n" ^ (rawEvToString res) ^ "\n" ) in
        res
    end
*)

(*

(** val chec_asp_EXTD :
    coq_ASP_PARAMS -> coq_Plc -> coq_BS -> coq_RawEv -> coq_BS **)
fun check_asp_EXTD (ps : coq_ASP_PARAMS) (p : coq_Plc) (bs : coq_BS) (ls : coq_RawEv) =
    case ps of
        Coq_asp_paramsC aspid args tpl tid =>
        case (aspid = tpm_sig_aspid) of
            True => appraise_tpm_sig ps p bs ls
                              
          | _ => case (aspid = ssl_sig_aspid) of
                     True => appraise_ssl_sig ps p bs ls

                   | _ => case (aspid = kim_meas_aspid) of
                              True => appraise_kim_meas_asp_stub ps p bs ls
                                                 
                            | _ => let val _ = print ("\nAppraisal Check of ASP with ID: " ^ aspid ^ "\n") in
                                       BString.fromString ("check(" ^ aspid ^ ")") (* TODO: check data val here? *)
                                   end


*)
                                       
                                       
(** fun checkNonce : coq_BS -> coq_BS -> coq_BS **)
fun checkNonce nonceGolden nonceCandidate =
    if (nonceGolden = nonceCandidate)
    then
        let val _ = print "Nonce Check PASSED\n\n" in
            passed_bs
        end
    else
        let val _ = print "Nonce Check FAILED\n\n" in
            failed_bs
        end


(** val gen_nonce_bits : coq_BS **)

val gen_nonce_bits = (BString.fromString "anonce") (* TODO: real nonce gen *)
  (* failwith "AXIOM TO BE REALIZED" *)


(** val decrypt_bs_to_rawev_prim :
    coq_BS -> coq_ASP_PARAMS -> coq_PublicKey -> (coq_RawEv,
    coq_DispatcherErrors) coq_ResultT **)
fun decrypt_bs_to_rawev_prim bs params pubkey = Coq_errC (Runtime errStr_decryption_prim)
(*
fun decrypt_bs_to_rawev_prim bs params pubkey = 
    let val recoveredtext = Crypto.decryptOneShot priv2 pubkey (*pub1*) (* priv1 pubkey *) bs (*priv2 pub1 bs *)
        val bs_recovered = BString.fromString recoveredtext
        val res = decode_RawEv bs_recovered
        val _ = print ("\nDecryption Succeeded: \n" ^ (rawEvToString res) ^ "\n" ) in
        (Coq_resultC res)
    end
*)



(* Coq_errC (Runtime errStr_decryption_prim) *)

  (*failwith "AXIOM TO BE REALIZED"*)


(*

fun decrypt_bs_to_rawev bs ps (* priv pub *) =
    let val recoveredtext = "" (* Crypto.decryptOneShot (* priv pub *) priv2 pub1 bs *)
        val bs_recovered = BString.fromString recoveredtext
        val res = decode_RawEv bs_recovered
        val _ = print ("\nDecryption Succeeded: \n" ^ (rawEvToString res) ^ "\n" ) in
        res
    end

*)




(*
datatype coq_DispatcherErrors =
  Unavailable 
| Runtime coq_StringT
*)

fun dispatch_error_toString e = 
    case e of 
        Unavailable => "Unavailable" 
    | Runtime str => "Runtime error: " ^ str 



(*
datatype coq_AM_Error =
  Coq_cvm_error coq_CVM_Error
| Coq_am_error coq_StringT
| Coq_am_dispatch_error coq_DispatcherErrors

*)

(** val print_am_error : coq_AM_Error -> bool -> bool **)

fun print_am_error e _ = 
    case e of 
        Coq_cvm_error _ => 
            let val _ = print ("\n\n\n" ^ errStr_cvm_error ^ "\n\n\n") in True
            end
    | Coq_am_error s => 
        let val _ = print ("\n\n\n" ^ s ^ "\n\n\n") in True
        end
    | Coq_am_dispatch_error s =>
        let val _ =  print ("\n\n\n\n\n" ^ (dispatch_error_toString s) ^ "\n\n\n") in True
        end





(*
(** val print_am_error : coq_AM_Error -> bool -> bool **)

fun print_am_error e _ = case b of
  True => (case b of
             True => b
           | False => negb b)
| False => negb b

*)
