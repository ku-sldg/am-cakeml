(* Depends on interp/Instr.sml *)

val map   = Map.insert emptyNsMap (S O) "127.0.0.1"
val term  = Lseq (Asp (Aspc (Id O) ["hashTest.txt"])) (Asp Sig)
val nonce = genNonce ()

val _ = print (
    let val evStr = evalTerm O map (Nc (Id O) nonce Mtc) term
     in evCToString evStr ^ "\n"
    end
    handle TextIO.BadFileName => "Bad file name: \"hashTest.txt\"\n"
         | _                  => "Fatal: Unknown error!\n"
)
