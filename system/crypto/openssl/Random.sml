(* Depends on: CryptoFFI *)

structure Random = struct 
    local 
        datatype rng = Rng
            BString.bstring (* key,   32 bytes *)
            BString.bstring (* nonce, 12 bytes *)
            (int ref)       (* ctr *)
    in 
        type rng = rng

        (* bstring -> rng *)
        (* argument should be 32 bytes *)
        fun seed bs = Rng (BString.toLength BString.LittleEndian 32 bs) (BString.nulls 12) (Ref 0)

        (* rng -> int -> bstring *)
        fun random _ len = Crypto.randomBytes len
    end
end