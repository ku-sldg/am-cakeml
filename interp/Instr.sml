(* Depends on: CoplandLang.sml, ByteString.sml, CoqDefaults.sml, Eval.sml,
   crypto/Random.sml, and crypto/CryptoFFI.sml
 *)

(* Based on Coq VM implementation, with a couple differences:
     1. USM/ASP terms maintain an argument list
     2. Concrete signature evidence lacks a place field
     3. Concrete hash evidence lacks a recursive evidence field
 *)


(* ASTs *)

datatype asp =
      Cpy
    | Aspc asp_id (arg list)
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


(* Concrete Evidence *)

type n_id = id
val nIdToString = idToString

local type bs = ByteString.bs in
datatype evC =
      Mtc
    | Uc asp_id (arg list) bs evC
    | Gc bs evC
    | Hc bs
    | Nc n_id bs evC
    | SSc evC evC
    | PPc evC evC
end

fun evCToString e = concatWith " "
    let fun withParens e = "(" ^ evCToString e ^ ")"
     in case e of
          Mtc            => ["Mtc"]
        | Uc i al bs evC => ["Uc", aspIdToString i, listToString al id,
                             ByteString.show bs, withParens evC]
        | Gc bs evC      => ["Gc", ByteString.show bs, withParens evC]
        | Hc bs          => ["Hc", ByteString.show bs]
        | Nc i bs evC    => ["Nc", nIdToString i, ByteString.show bs,
                             withParens evC]
        | SSc evC1 evC2  => ["SSc", withParens evC1, withParens evC2]
        | PPc evC1 evC2  => ["PPc", withParens evC1, withParens evC2]
    end

(* evC -> ByteString.bs *)
val encodeEvC =
    let fun evCList evc = case evc of
          Mtc         => [ByteString.empty]
        | Uc _ _ bs e => bs :: evCList e
        | Gc bs e     => bs :: evCList e
        | Hc bs       => [bs]
        | Nc _ bs e   => bs :: evCList e
        | SSc e1 e2   => evCList e1 @ evCList e2
        | PPc e1 e2   => evCList e1 @ evCList e2
     in List.foldr ByteString.append ByteString.empty o evCList
    end

(* evC -> ByteString.bs *)
val signEvC  = Crypto.signMsg o encodeEvC
val genHashC = Crypto.hash    o encodeEvC

(* sp -> evC -> evC *)
fun splitEvC s e = case s of
      ALL  => e
    | NONE => Mtc


(* Compiler / VM*)

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
