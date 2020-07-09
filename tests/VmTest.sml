(* Depends on interp/Instr.sml *)

val map   = Map.insert emptyNsMap (S O) "127.0.0.1"
val term  = Lseq (Asp (Aspc (Id O) ["hashTest.txt"])) (Asp Sig)
val nonce = genNonce ()

val priv = (ByteString.toRawString o ByteString.fromHexString)
           "2E5773B2A19A2CB05FEE44650D8DC877B3D806F74C199043657C805288CD119B"

val _ = print (
    let val evStr = evalTerm O map priv (Nc (Id O) nonce Mtc) term
     in evCToString evStr ^ "\n"
    end
    handle TextIO.BadFileName => "Bad file name: \"hashTest.txt\"\n"
         | _                  => "Fatal: Unknown error!\n"
)
