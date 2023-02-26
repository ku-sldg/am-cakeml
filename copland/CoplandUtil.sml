(* Depends on: util, extracted *)

(* plToString : coq_Plc -> string *)
val plToString = natToString

(* aspIdToString : coq_ASP_ID -> string *)
fun aspIdToString s = s

(* targIdToString : coq_TARG_ID -> string *)
fun targIdToString s = s

(* argToString : coq_Arg -> string *)
fun argToString s = s

(* aspParamsToString : coq_ASP_PARAMS -> string *)
fun aspParamsToString ps =
    case ps of
        Coq_asp_paramsC aspid args tpl tid =>
        concatWith " " ["(ASP_PARAMS", aspIdToString aspid,
                        listToString args argToString,
                        plToString tpl, targIdToString tid, ")"]
(* spToString : coq_SP -> string *)
fun spToString sp =
    case sp of
        ALL => "ALL"
      | NONE => "NONE"

(* fwdToString : coq_FWD -> string *)
fun fwdToString fwd =
    case fwd of
        COMP => "COMP"
      | EXTD => "EXTD"
      | ENCR => "ENCR"
      | KILL => "KILL"
      | KEEP => "KEEP"

(* aspToString :: coq_ASP -> string *)
fun aspToString asp = case asp of
      NULL => "NULL"
    | CPY => "CPY"
    | SIG => "SIG"
    | HSH => "HSH"
    | ENC q => concatWith " " ["(ENC", plToString q, ")"]
    | ASPC sp fwd ps => concatWith " " ["(ASPC", spToString sp, fwdToString fwd,
                                        aspParamsToString ps, ")"]


(* termToString :: coq_Term -> string *)
fun termToString t = concatWith " "
    let fun parens t = "(" ^ termToString t ^ ")"
        fun pairToString s1 s2 = "(" ^ s1 ^ ", " ^ s2 ^ ")"
     in case t of
          Coq_asp a => ["ASP", aspToString a]
        | Coq_att p t => ["Att", plToString p, parens t]
        | Coq_lseq t1 t2 => ["Lseq", parens t1, parens t2]
        | Coq_bseq (Coq_pair s1 s2) t1 t2 =>
          ["Bseq", pairToString (spToString s1) (spToString s2),
           parens t1, parens t2]
        | Coq_bpar (Coq_pair s1 s2) t1 t2 =>
          ["Bpar", pairToString (spToString s1) (spToString s2),
           parens t1, parens t2]
    end


(* Evidence Type utils *)

(* nIdToString : coq_N_ID -> string *)
val nIdToString = natToString
                      
(* evToString :: Evidence -> string *)                      
fun evToString e = concatWith " "
    let fun parens e = "(" ^ evToString e ^ ")"
     in case e of
            Coq_mt         => ["Mt"]
          | Coq_uu p fwd ps ev  =>
            ["UU_E", plToString p, fwdToString fwd, aspParamsToString ps,
             parens ev]
        | Coq_nn i       => ["N", nIdToString i]
        | Coq_ss ev1 ev2   => ["SS_E", parens ev1, parens ev2]
    end

(* evidenceCToString :: coq_EvidenceC -> string *)
fun evidenceCToString e = concatWith " "
    let fun parens e = "(" ^ evidenceCToString e ^ ")"
     in case e of
            Coq_mtc_app         => ["Mtc"]
          | Coq_nnc_app i bs => ["NNc", nIdToString i, BString.toString bs]
          | Coq_ggc_app p ps bs e' =>
            ["GGc", plToString p, aspParamsToString ps,
             BString.toString bs, parens e' ]
          | Coq_hhc_app p ps bs e' => ["HHc", plToString p, aspParamsToString ps,
                                   BString.toString bs, parens e' (* evToString et *)]
          | Coq_eec_app p ps bs e' => ["EEc", plToString p, aspParamsToString ps,
                                   BString.toString bs, parens e']
          (* | Coq_kkc p ps et => ["KKc", plToString p, aspParamsToString ps,
                                evToString et] *)
          | Coq_ssc_app ev1 ev2   => ["SSc", parens ev1, parens ev2]
    end

    
    

(* rawEvToString :: coq_RawEv -> string *)
fun rawEvToString e = listToString e BString.toString

(* evCToString : coq_EvC -> string *)
fun evCToString evc =
    case evc of
        Coq_evc rawEv et =>
        concatWith " " ["(EvC", rawEvToString rawEv, evToString et, ")"]

(*
(* ev -> bstring *)
val encodeEv =
    let fun evList ev = case ev of
          Mt         => [BString.empty]
        | U _ _ bs e => bs :: evList e
        | G bs e     => bs :: evList e
        | H bs       => [bs]
        | N _ bs e   => bs :: evList e
        | SS e1 e2   => evList e1 @ evList e2
        | PP e1 e2   => evList e1 @ evList e2
     in BString.concatList o evList
    end

*)
