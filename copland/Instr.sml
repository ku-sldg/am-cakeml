(* Depends on: util *)

datatype id = Id nat
fun id_compare (Id i) (Id j) = nat_compare i j
fun idToString (Id i) = "Id " ^ natToString i

type pl = nat
val plToString = natToString

type asp_id = id
val aspIdToString = idToString

type arg = string
fun argToString a = a


datatype sp = ALL | NONE
fun spToString s = case s of
      ALL  => "ALL"
    | NONE => "NONE"

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

fun aspToString asp = case asp of
      Cpy => "Cpy"
    | Sig => "Sig"
    | Hsh => "Hsh"
    | Aspc aid al => concatWith " " ["(Aspc", aspIdToString aid, listToString al argToString, ")"]

fun termToString t = concatWith " "
    let fun parens t = "(" ^ termToString t ^ ")"
        fun pairToString s1 s2 = "(" ^ s1 ^ ", " ^ s2 ^ ")"
     in case t of
          Asp a => ["Asp", aspToString a]
        | Att p t => ["Att", plToString p, parens t]
        | Lseq t1 t2 => ["Lseq", parens t1, parens t2]
        | Bseq (s1, s2) t1 t2 => ["Bseq", pairToString (spToString s1) (spToString s2), parens t1, parens t2]
        | Bpar (s1, s2) t1 t2 => ["Bpar", pairToString (spToString s1) (spToString s2), parens t1, parens t2]
    end

(* Evidence *)

type n_id = id
val nIdToString = idToString
                      
local type bs = BString.bstring in
datatype ev =
      Mt
    | U asp_id (arg list) bs ev
    | G bs ev
    | H bs
    | N n_id bs
    | SS ev ev
    | PP ev ev
end
(*
datatype evt =
         Mtt
       | Ut asp_id (arg list) evt
       | Gt pl evt
       | Ht pl evt
       | Nt n_id
       | SSt evt evt
       | PPt evt evt
*)

fun evToString e = concatWith " "
    let fun parens e = "(" ^ evToString e ^ ")"
     in case e of
          Mt           => ["Mt"]
        | U i al bs ev => ["U", aspIdToString i, listToString al argToString, BString.show bs, parens ev]
        | G bs ev      => ["G", BString.show bs, parens ev]
        | H bs         => ["H", BString.show bs]
        | N i bs       => ["N", nIdToString i, BString.show bs]
        | SS ev1 ev2   => ["SS", parens ev1, parens ev2]
        | PP ev1 ev2   => ["PP", parens ev1, parens ev2]
    end

(* ev -> bstring *)
val encodeEv =
    let fun evList ev = case ev of
          Mt         => [BString.empty]
        | U _ _ bs e => bs :: evList e
        | G bs e     => bs :: evList e
        | H bs       => [bs]
        | N _ bs     => [bs]
        | SS e1 e2   => evList e1 @ evList e2
        | PP e1 e2   => evList e1 @ evList e2
     in BString.concatList o evList
    end

datatype evt =
         Mtt
       | Ut asp_id (arg list) evt
       | Gt pl evt
       | Ht pl evt
       | Nt n_id
       | SSt evt evt
       | PPt evt evt

fun evtToString e = concatWith " "
    let fun parens e = "(" ^ evtToString e ^ ")"
     in case e of
          Mtt           => ["Mtt"]
        | Ut i al ev    => ["Ut", aspIdToString i, listToString al argToString, parens ev]
        | Gt p ev       => ["Gt", plToString p, parens ev]
        | Ht p ev       => ["Ht", plToString p, parens ev]
        | Nt i          => ["Nt", nIdToString i]
        | SSt ev1 ev2   => ["SSt", parens ev1, parens ev2]
        | PPt ev1 ev2   => ["PPt", parens ev1, parens ev2]
    end

(* sp -> evt -> evt *)
fun splitEvt s e = case s of
      ALL  => e
    | NONE => Mtt
                                 
(* asp -> pl -> evt -> evt *)
fun eval_asp a p e = case a of
      Aspc id args => Ut id args e
    | Cpy => e
    | Sig => Gt p e
    | Hsh => Ht p e

(* term -> pl -> evt -> evt *)
fun eval t p e =
    case t of
        Asp a => eval_asp a p e
      | Att q t' => eval t' q e
      | Lseq t1 t2 => eval t2 p (eval t1 p e)
      | Bseq (sp1,sp2) t1 t2 =>
        let val e1t = eval t1 p (splitEvt sp1 e)
            val e2t = eval t2 p (splitEvt sp2 e) in
            SSt e1t e2t
        end
      | Bpar (sp1,sp2) t1 t2 =>
        let val e1t = eval t1 p (splitEvt sp1 e)
            val e2t = eval t2 p (splitEvt sp2 e) in
            PPt e1t e2t
        end
    

local type bs = BString.bstring in
datatype evc =
      Mtc
    | Uc asp_id (arg list) bs evc
    | Gc pl bs evc
    | Hc pl bs evt
    | Nc n_id bs
    | SSc evc evc
    | PPc evc evc
end

fun evcToString e = concatWith " "
    let fun parens e = "(" ^ evcToString e ^ ")"
        fun parenst e = "(" ^ evtToString e ^ ")"
    in case e of
          Mtc             => ["Mtc"]
        | Uc i al bs ev   => ["Uc", aspIdToString i, listToString al argToString, BString.show bs, parens ev]
        | Gc p bs ev      => ["Gc", plToString p, (*"sig(",*)BString.show bs,(*") ",*) parens ev]
        | Hc p bs et      => ["Hc", plToString p, BString.show bs,  parenst et]
        | Nc i bs         => ["Nc", nIdToString i, BString.show bs]
        | SSc ev1 ev2     => ["SSc", parens ev1, parens ev2]
        | PPc ev1 ev2     => ["PPc", parens ev1, parens ev2]
    end

(* ev -> bstring *)
val encodeEvC =
    let fun evList ev = case ev of
          Mtc         => [BString.empty]
        | Uc _ _ bs e => bs :: evList e
        | Gc _ bs e     => bs :: evList e
        | Hc _ bs _       => [bs]
        | Nc _ bs     => [bs]
        | SSc e1 e2   => evList e1 @ evList e2
        | PPc e1 e2   => evList e1 @ evList e2
     in BString.concatList o evList
    end
