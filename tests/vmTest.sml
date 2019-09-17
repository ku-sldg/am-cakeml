(* Depends on interp/Instr.sml *)

val map   = Map.insert emptyNsMap (S O) "127.0.0.1"
val term  = Lseq (Asp (Usm (Id O) ["hashTest.txt"])) (Asp Sig)
val nonce = genNonce ()

val evC = evalTerm O map (Nc 0 nonce Mtc) term
val _ = (print o evToString o evCToEv O) evC
val _ = print "\n"
