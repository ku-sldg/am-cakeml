(* Depends on: CoplandLang.sml, ByteString.sml, Instr.sml, CoqDefaults.sml,
   Eval.sml, crypto/Random.sml, and crypto/CryptoFFI.sml
 *)

(* evC -> ByteString.bs *)
val signEvC  = Crypto.signMsg o encodeEvC
val genHashC = Crypto.hash    o encodeEvC

(* sp -> evC -> evC *)
fun splitEvC s e = case s of
      ALL  => e
    | NONE => Mtc

(* asp -> primInstr *)
fun aspInstr a = case a of
      Cpy         => Copy
    | Aspc i args => Umeas i args
    | Sig         => Sign
    | Hsh         => Hash

(* term -> instr list *)
fun instrCompiler t = case t of
      Asp a      => [PrimInstr (aspInstr a)]
    | Att q t'   => [Reqrpy q t']
    | Lseq t1 t2 => instrCompiler t1 @ instrCompiler t2
    | Bseq (sp1, sp2) t1 t2 =>
        Split sp1 sp2 :: instrCompiler t1 @ Besr :: instrCompiler t2 @ [Joins]
    | Bpar (sp1, sp2) t1 t2 =>
        [Split sp1 sp2, Bep (instrCompiler t1) (instrCompiler t2), Joinp]

(* primInstr -> evC -> evC *)
fun primEv i ec = case i of
      Umeas id args => Uc id args (measureUsm mapUSM id args) ec
    | Copy => ec
    | Sign => Gc (signEvC ec) ec
    | Hash => Hc (genHashC ec)

(* This function diverges significantly from the Coq implementation.
   It may prove necessary to rewrite it in the original's monadic style. *)
(* pl -> nsMap -> evC -> instr list -> evC *)
fun evalVm pl map ec =
    let fun parallel_att_vm_thread il ec = evalVm pl map ec il
        (* fun toRemote t pl' ec = evToEvC (dispatchAt (REQ pl pl' map t (evCToEv pl ec))) *)
        fun toRemote t pl' ec = Mtc (* placeholder *)
        (* evC * evC list -> instr -> evC * evC list*)
        fun vmStep (ec, stack) i = case i of
              PrimInstr p => (primEv p ec, stack)
            | Split s1 s2 => (splitEvC s1 ec, (splitEvC s2 ec)::stack)
            | Joins => (SSc (List.hd stack) ec, List.tl stack)
            | Joinp => (PPc (List.hd stack) ec, List.tl stack)
            | Reqrpy pl' t => (toRemote t pl' ec, stack)
            | Besr => (List.hd stack, ec::(List.tl stack))
            | Bep il1 il2 => (parallel_att_vm_thread il1 ec,
                (parallel_att_vm_thread il2 (List.hd stack))::(List.tl stack))

     in fst o List.foldl vmStep (ec, []) end

fun evalTerm pl map ec = evalVm pl map ec o instrCompiler
