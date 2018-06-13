datatype nat = O
             | S of nat

fun natToString n =
    case n of O => Int.toString 0
            | S n' => Int.toString (1 + (case Int.fromString (natToString n') of NONE => 0
                                                                               | SOME i => i))

datatype order = SEQ | PAR

datatype apdt = USM
              | KIM of nat
              | SIG
              | AT of nat * apdt
              | LN of apdt * apdt
              | BR of order * apdt * apdt

datatype ev = Mt
            | N of nat
            | K of nat * nat
            | U of nat
            | G of ev * nat
            | SS of ev * ev
            | P of ev * ev

fun sequ e1 e2 =
    case e1 of Mt => e2
             | _  => SS e1 e2

fun para e1 e2 =
    case (e1, e2) of (Mt, _) => e2
                   | (_, Mt) => e1
                   |  _      => P e1 e2

fun eval t p e =
    case t of
        KIM q => sequ e (K q p)
      | USM => sequ e (U p)
      | SIG => G e p
      | AT q t => eval t q e
      | LN t1 t2 => eval t2 p (eval t1 p e)
      | BR SEQ t1 t2 => sequ (eval t1 p e) (eval t2 p e)
      | BR PAR t1 t2 => para (eval t1 p e) (eval t2 p e)

fun eapdt t = eval t O Mt

val printList = TextIO.print_list

fun evidencePrint e =
    let
        fun printHelper e =
            case e of
                N n => (printList [ "N ", natToString n ]; ())
              | K q p => (printList [ "K ", natToString q, " ", natToString p ]; ())
              | U p => (printList [ "U ", natToString p ]; ())
              | G e' p => (print "G ("; printHelper e'; print ") "; print (natToString p); print ")"; ())
              | SS e1 e2 => (print "SS ("; printHelper e1; print ") ("; printHelper e2; print ")"; ())
              | P  e1 e2 => (print "P ("; printHelper e1; print ") ("; printHelper e2; print ")"; ());
    in
        printHelper e;
        print "\n";
        ()
    end

val aTerm = (KIM (S O))

(* evidencePrint (eapdt aTerm) *)

val ex =
  AT (S (S O)) (LN (BR PAR (KIM (S O)) (AT (S O) (LN USM SIG))) SIG)

val aex =
  AT (S (S O)) (LN (LN (KIM (S O)) (AT (S O) (LN USM SIG))) SIG)

val usm =
  USM

val kim =
  KIM (S O)

val usmSig =
  LN usm SIG

val lnKimUsm =
  LN kim usm

val lnKimUsmSig =
  LN lnKimUsm SIG

val atUsm =
  AT O usm

val atKim =
  AT O kim

val atUsmSig =
  AT O usmSig

val atLnKimUsm =
  AT O lnKimUsm

val atLnKimUsmSig =
  AT O lnKimUsmSig

val brUsmKim =
  BR PAR usm kim

val brUsmKimSig =
  LN brUsmKim SIG

val lnBrUsmKim =
  LN brUsmKim brUsmKim

val lnBrUsmKimSig =
  LN brUsmKimSig brUsmKimSig

val kim2 =
  KIM (S (S O))

val lnAtKim2Usm =
  LN (AT (S O) (LN kim2 SIG)) (AT (S (S O)) (LN USM SIG))

val brAtKim2Usm =
  BR SEQ (AT (S O) (LN kim2 SIG)) (AT (S (S O)) (LN USM SIG))

val _ = evidencePrint (eapdt ex)
val _ = evidencePrint (eapdt aex)
val _ = evidencePrint (eapdt usm)
val _ = evidencePrint (eapdt kim)
val _ = evidencePrint (eapdt usmSig)
val _ = evidencePrint (eapdt lnKimUsm)
val _ = evidencePrint (eapdt lnKimUsmSig)
val _ = evidencePrint (eapdt atUsm)
val _ = evidencePrint (eapdt atKim)
val _ = evidencePrint (eapdt atUsmSig)
val _ = evidencePrint (eapdt atLnKimUsm)
val _ = evidencePrint (eapdt atLnKimUsmSig)
val _ = evidencePrint (eapdt brUsmKim)
val _ = evidencePrint (eapdt brUsmKimSig)
val _ = evidencePrint (eapdt lnBrUsmKim)
val _ = evidencePrint (eapdt lnBrUsmKimSig)
val _ = evidencePrint (eapdt kim2)
val _ = evidencePrint (eapdt lnAtKim2Usm)
val _ = evidencePrint (eapdt brAtKim2Usm)
