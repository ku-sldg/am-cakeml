(* Depends on: crypto/Aes256.sml, crypto/CryptoFFI.sml *)

(*
A Deterministic Random Bit Generator (DRBG) based on the AES-256 block cipher
in the counter (CTR) mode of operation. Specified by NIST (see section 10.2):
    https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-90Ar1.pdf

This implementation is slightly simplified compared to the above specification.
E.G. it will always generate 16 random bytes, rather than letting you specify
how many you want. The underlying mechanics are the same, though. We make
syscalls to get random values for our key and counter (together acting as our
seed), and then simply operate the AES-256 in CTR mode (conceptually encrypting
zero blocks).
*)
structure Aes256CtrDrbg = struct
    type drbg = (Aes256Ctr.ctr * int) ref

    (* Reseed after 2^16 generations. This is very conservative, compared to
       the 2^48 max provided by the NIST document *)
    val max_count = 65536

    fun init () = (Aes256Ctr.init (urand 32) (urand 16), 0)

    fun reseed drbg = drbg := (init ())

    fun genBits drbg =
        let (* Note: `!` is the dereferencing operator *)
            val (ctr, count) = !drbg
        in
            if count >= max_count
                then            (* I actually _have_ to do let/in rather than *)
                    let val _ = reseed drbg (* semicolon/sequencing, due to   *)
                    in genBits drbg end     (* right-to-left evaluation order *)
                else
                    Aes256Ctr.encrCtr ctr
        end
end


local
    val dbgr = ref (Aes256CtrDrbg.init ())
in
    (* Returns 16 random bytes *)
    fun rand () = Aes256CtrDrbg.genBits dbgr
end
