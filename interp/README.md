This directory contains the Copland ASTs and evaluators.
 - `CoplandLang.sml` defines ASTs for the original Copland term and evidence languages
 - `Eval.sml` implements an interpreter over the original Copland term language
 - `Instr.sml` contains all ASTs, compiler, and evaluator to support the newer VM semantics.

## CakeML VM vs Coq VM
The CakeML implementation of the new VM-based semantics diverges slightly from the Coq specification.

First, some differences in the language itself. The term and instruction corresponding to USMs/ASPs possess a list of strings representing arguments. This was present in the original Copland spec, but removed from the current Coq spec to simplify proofs. This will be added back to the Coq spec. In addition, signature evidence lacks a field for place that is present in the Coq spec. This was likewise an artifact of verification, and will soon be removed.

The final difference in the language definition is a lack of sub-evidence for the Hash evidence constructor. In the Coq spec, this value holds the evidence that is hashed. However, we believe that in most uses the pre-hashed evidence can and should be discarded. This not only shortens the final evidence value, but also disposes of information that the target may consider sensitive (it is easy to imagine a scenario where a target would accept a protocol during negotiation to produce a hash of a file, but not one which would expose the file's exact contents). We also believe that, with the hash sub-evidence removed, we could recreate the original functionality, e.g. with a parallel term which hashes on one branch, and copies on the other (i.e. `e; (Hash || Copy)`). This change is tentative.

Aside from the language discrepancies, there is only one difference in the implementation, which is how we define execution over VM instructions. The two implementations should produce the same results (modulo the aforementioned language changes), but are defined in different ways. The Coq spec takes instructions to a VM monad. CakeML does not explicitly support monads. Therefore, in the CakeML implementation, the evaluation of instructions is defined more directly as a transformation of the state (i.e. evidence stack). If these two styles are difficult to reconcile during verification, it should be feasible to rewrite the CakeML version in a more monadic style. The result would not be very readable (lacking do-notation and custom infix functions), but it may be more proof-friendly.
