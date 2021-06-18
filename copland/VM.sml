(* Depends on: util, Instr.sml, AM.sml *)


(* sp -> ev -> ev *)
fun splitEv s e = case s of
      ALL  => e
    | NONE => Mt

(*
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
    (*| Bseq (sp1, sp2) t1 t2 =>
        Split sp1 sp2 :: instrCompiler t1 @ Besr :: instrCompiler t2 @ [Joins]
    | Bpar (sp1, sp2) t1 t2 =>
        [Split sp1 sp2, Bep (instrCompiler t1) (instrCompiler t2), Joinp] *)
*)

(* am -> asp -> ev -> ev *)
fun primEv am a e = case a of
      Aspc id args => U id args (measureUsm (usmMap am) id args) e
    | Cpy => e
    | Sig => G (signEv am (privKey am) e) e
    | Hsh => H (genHash am e)

exception NNexpn string
fun isNoneNone sp =
    case sp of
        (NONE,NONE) => raise NNexpn "Term Containing (NONE,NONE) splitter found"

fun excludeNNterms t =
    case t of
        Bseq sp t1 t2 => (
         isNoneNone sp ;
         excludeNNterms t1 ;
         excludeNNterms t2 )
      | Bpar sp t1 t2 => (
         isNoneNone sp ;
         excludeNNterms t1 ;
         excludeNNterms t2 )
      | Lseq t1 t2 => (
          excludeNNterms t1 ;
          excludeNNterms t2)
      | Att pl t' =>
        excludeNNterms t'
        handle NNexpn msg =>
               TextIO.print_err
                   ("input term to 'excludeNNterms' had a split term like (NONE,NONE)")

               

(* This function diverges significantly from the Coq implementation.
   It may prove necessary to rewrite it in the original's monadic style. *)
(* am -> ev -> instr list -> ev*)
fun evalVm am e t =
    case t of
        Asp a => primEv am a e
      | Att pl t' => (dispatch am pl e t')
      | Lseq t1 t2 => evalVm am (evalVm am e t1) t2
      | Bseq (sp1,sp2) t1 t2 =>
        let val e1r = evalVm am (splitEv sp1 e) t1
            val e2r = evalVm am (splitEv sp2 e) t2 in
            SS e1r e2r
        end
      | Bpar (sp1,sp2) t1 t2 =>
        let val e1r = evalVm am (splitEv sp1 e) t1
            val e2r = evalVm am (splitEv sp2 e) t2 in
            PP e1r e2r
        end

(* am -> copEval *)
fun evalTerm am e t = evalVm am e t
