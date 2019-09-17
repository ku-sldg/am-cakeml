(* Depends on CoplandLang.sml *)

datatype asp =
      Cpy
    | Kim asp_id pl (arg list)
    | Usm asp_id (arg list)
    | Sig
    | Hsh

datatype term =
      Asp asp
    | Att pl term
    | Lseq term term
    | Bseq (sp * sp) term term
    | Bpar (sp * sp) term term

datatype primInstr =
      Copy
    | Kmeas asp_id pl (arg list)
    | Umeas asp_id (arg list)
    | Sign
    | Hash

datatype instr =
      PrimInstr primInstr
    | Split sp sp
    | Joins
    | Joinp
    | Reqrpy pl term
    | Besr
    | Bep (instr list) (instr list)

(* Concrete evidence. Places removed, except for one of the KIM's arguments. *)
local type bs = ByteString.bs in
datatype evC =
      Mtc
    | Uc asp_id (arg list) bs evC
    | Kc asp_id (arg list) pl bs evC
    | Gc evC bs
    | Hc bs
    | Nc int bs evC
    | SSc evC evC
    | PPc evC evC
end

(* ev -> evC *)
fun evToEvC ev = case ev
   of Mt => Mtc
    | U id args pl bs ev => Uc id args bs (evToEvC ev)
    | K id args pl1 pl2 bs ev => Kc id args pl2 bs (evToEvC ev)
    | G pl ev bs => Gc (evToEvC ev) bs
    | H pl bs => Hc bs
    | N pl int bs ev => Nc int bs (evToEvC ev)
    | SS ev1 ev2 => SSc (evToEvC ev1) (evToEvC ev2)
    | PP ev1 ev2 => PPc (evToEvC ev1) (evToEvC ev2)

(* pl -> evC -> ev *)
fun evCToEv me ec = case ec
   of Mtc => Mt
    | Uc id args bs ec => U id args me bs (evCToEv me ec)
    | Kc id args pl bs ec => K id args me pl bs (evCToEv me ec)
    | Gc ec bs => G me (evCToEv me ec) bs
    | Hc bs => H me bs
    | Nc int bs ec => N me int bs (evCToEv me ec)
    | SSc ec1 ec2 => SS (evCToEv me ec1) (evCToEv me ec2)
    | PPc ec1 ec2 => PP (evCToEv me ec1) (evCToEv me ec2)

(* asp -> primInstr *)
fun aspInstr a = case a
   of Cpy          => Copy
    | Kim i p args => Kmeas i p args
    | Usm i args   => Umeas i args
    | Sig          => Sign
    | Hsh          => Hash

(* term -> instr list *)
fun instrCompiler t = case t
   of Asp a      => [PrimInstr (aspInstr a)]
    | Att q t'   => [Reqrpy q t']
    | Lseq t1 t2 => instrCompiler t1 @ instrCompiler t2
    | Bseq (sp1, sp2) t1 t2 =>
        Split sp1 sp2 :: instrCompiler t1 @ Besr :: instrCompiler t2 @ [Joins]
    | Bpar (sp1, sp2) t1 t2 =>
        [Split sp1 sp2, Bep (instrCompiler t1) (instrCompiler t2), Joinp]

(* Reuse ev functions *)
val signEvC  = signEv o evCToEv O
val genHashC = genHash o evCToEv O
fun splitEvC sp = evToEvC o splitEv sp o evCToEv O

(* primInstr -> evC -> evC *)
fun primEv i ec = case i
   of Kmeas id pl args => Kc id args pl (measureKim mapKIM id pl args) ec
    | Umeas id args => Uc id args (measureUsm mapUSM id args) ec
    | Copy => ec
    | Sign => Gc ec (signEvC ec)
    | Hash => Hc (genHashC ec)


(* pl -> nsMap -> evC -> instr list -> evC *)
fun evalVm pl map ec =
    let fun parallel_att_vm_thread il ec = evalVm pl map ec il
        (* fun toRemote t pl' ec = evToEvC (dispatchAt (REQ pl pl' map t (evCToEv pl ec))) *)
        fun toRemote t pl' ec = Mtc (* placeholder *)
        (* evC * evC list -> instr -> evC * evC list*)
        fun vmStep (ec, stack) i = case i
           of PrimInstr p => (primEv p ec, stack)
            | Split s1 s2 => (splitEvC s1 ec, (splitEvC s2 ec)::stack)
            | Joins => (SSc (List.hd stack) ec, List.tl stack)
            | Joinp => (PPc (List.hd stack) ec, List.tl stack)
            | Reqrpy pl' t => (toRemote t pl' ec, stack)
            | Besr => (List.hd stack, ec::(List.tl stack))
            | Bep il1 il2 => (parallel_att_vm_thread il1 ec,
                (parallel_att_vm_thread il2 (List.hd stack))::(List.tl stack))

     in fst o List.foldl vmStep (ec, []) end

fun evalTerm pl map ec = evalVm pl map ec o instrCompiler
