(* Depends on: CoplandLang.sml, ByteString.sml, and CoqDefaults.sml *)

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
