type coq_Plc = nat

type coq_N_ID = nat

type coq_Event_ID = nat

type coq_ASP_ID = string

type coq_TARG_ID = string

type coq_Arg = string

datatype coq_ASP_PARAMS =
  Coq_asp_paramsC coq_ASP_ID (coq_Arg list) coq_Plc coq_TARG_ID

datatype coq_Evidence =
  Coq_mt 
| Coq_nn coq_N_ID
| Coq_gg coq_Plc coq_ASP_PARAMS coq_Evidence
| Coq_hh coq_Plc coq_ASP_PARAMS coq_Evidence
| Coq_ss coq_Evidence coq_Evidence

datatype coq_SP =
  ALL 
| NONE 

datatype coq_FWD =
  COMP 
| EXTD 

datatype coq_ASP =
  NULL 
| CPY 
| ASPC coq_SP coq_FWD coq_ASP_PARAMS
| SIG 
| HSH 

type coq_Split = (coq_SP, coq_SP) prod

datatype coq_Term =
  Coq_asp coq_ASP
| Coq_att coq_Plc coq_Term
| Coq_lseq coq_Term coq_Term
| Coq_bseq coq_Split coq_Term coq_Term
| Coq_bpar coq_Split coq_Term coq_Term

datatype coq_ASP_Core =
  NULLC 
| CLEAR 
| CPYC 
| ASPCC coq_FWD coq_ASP_PARAMS

type coq_Loc = nat

datatype coq_Core_Term =
  Coq_aspc coq_ASP_Core
| Coq_attc coq_Plc coq_Term
| Coq_lseqc coq_Core_Term coq_Core_Term
| Coq_bseqc coq_Core_Term coq_Core_Term
| Coq_bparc coq_Loc coq_Core_Term coq_Core_Term

(** val sig_params : coq_ASP_PARAMS **)

val sig_params =
  failwith "AXIOM TO BE REALIZED"

(** val hsh_params : coq_ASP_PARAMS **)

val hsh_params =
  failwith "AXIOM TO BE REALIZED"

(** val asp_term_to_core : coq_ASP -> coq_Core_Term **)

fun asp_term_to_core a = case a of
  NULL => Coq_aspc NULLC
| CPY => Coq_aspc CPYC
| ASPC sp fwd params =>
  (case sp of
     ALL => Coq_aspc (ASPCC fwd params)
   | NONE => Coq_lseqc (Coq_aspc CLEAR) (Coq_aspc (ASPCC fwd params)))
| SIG => Coq_aspc (ASPCC EXTD sig_params)
| HSH => Coq_aspc (ASPCC COMP hsh_params)

(** val copland_compile : coq_Term -> coq_Core_Term **)

fun copland_compile t = case t of
  Coq_asp a => asp_term_to_core a
| Coq_att q t' => Coq_attc q t'
| Coq_lseq t1 t2 => Coq_lseqc (copland_compile t1) (copland_compile t2)
| Coq_bseq s t1 t2 =>
  let val Coq_pair s0 s1 = s in
  (case s0 of
     ALL =>
     (case s1 of
        ALL => Coq_bseqc (copland_compile t1) (copland_compile t2)
      | NONE =>
        Coq_bseqc (copland_compile t1) (Coq_lseqc (Coq_aspc CLEAR)
          (copland_compile t2)))
   | NONE =>
     (case s1 of
        ALL =>
        Coq_bseqc (Coq_lseqc (Coq_aspc CLEAR) (copland_compile t1))
          (copland_compile t2)
      | NONE =>
        Coq_bseqc (Coq_lseqc (Coq_aspc CLEAR) (copland_compile t1))
          (Coq_lseqc (Coq_aspc CLEAR) (copland_compile t2)))) end
| Coq_bpar s t1 t2 =>
  let val Coq_pair s0 s1 = s in
  (case s0 of
     ALL =>
     (case s1 of
        ALL => Coq_bparc O (copland_compile t1) (copland_compile t2)
      | NONE =>
        Coq_bparc O (copland_compile t1) (Coq_lseqc (Coq_aspc CLEAR)
          (copland_compile t2)))
   | NONE =>
     (case s1 of
        ALL =>
        Coq_bparc O (Coq_lseqc (Coq_aspc CLEAR) (copland_compile t1))
          (copland_compile t2)
      | NONE =>
        Coq_bparc O (Coq_lseqc (Coq_aspc CLEAR) (copland_compile t1))
          (Coq_lseqc (Coq_aspc CLEAR) (copland_compile t2)))) end

type coq_RawEv = coq_BS list

datatype coq_EvC =
  Coq_evc coq_RawEv coq_Evidence

(** val mt_evc : coq_EvC **)

val mt_evc =
  Coq_evc Coq_nil Coq_mt

(** val get_et : coq_EvC -> coq_Evidence **)

fun get_et e = case e of
  Coq_evc _ et => et

(** val get_bits : coq_EvC -> coq_BS list **)

fun get_bits e = case e of
  Coq_evc ls _ => ls

datatype coq_Ev =
  Coq_null nat coq_Plc
| Coq_copy nat coq_Plc
| Coq_umeas nat coq_Plc coq_ASP_PARAMS coq_Evidence
| Coq_req nat coq_Plc coq_Plc coq_Term coq_Evidence
| Coq_rpy nat coq_Plc coq_Plc coq_Evidence
| Coq_split nat coq_Plc
| Coq_join nat coq_Plc
| Coq_cvm_thread_start coq_Loc coq_Plc coq_Core_Term coq_Evidence
| Coq_cvm_thread_end coq_Loc
