(* Eval.v *)
type 'a fmap = (nat * 'a) list

val fmap_empty = []

fun find m (x : nat) =
    case m of
        [] => None
      | ((i, a) :: ms) => if i = x then Some a else find ms x

fun fmap_set m i v = (i,v) :: m

fun fmap_dom m = case m of [] => []
                        | ((i,a)::ms) => i :: fmap_dom ms

type platform = nat * nat
fun goldenUsm p = case p of (x,y) => x
fun goldenKim p = case p of (x,y) => y

type system = platform fmap
fun platforms (s : system) = s

val emptySystem = fmap_empty

fun measureUsm (s : system) (p : pl) =
    let val ps = platforms s in
        let val optionP = find ps p in
            case optionP of
                None => O
              | Some plat => goldenUsm plat
        end
    end

fun measureKim (s : system) (p : pl) =
    let val ps = platforms s in
        let val optionP = find ps p in
            case optionP of
                None => O
              | Some plat => goldenKim plat
        end
    end

fun signEv (p : pl) (v : value) = p
fun genNonce (p : pl) = p

datatype pm = Plus of nat
            | Minus

(* Debruijn substitution: Chapter 7 of TAPL *)
fun walk (d : pm) (c : nat) (t : apdt) =
    case t of
        VAR (Id n) => if (nat_leb c n)
                      then (case d of
                                Plus v => VAR (Id (nat_plus n v))
                              | Minus  => VAR (Id (nat_minus n one)))
                      else VAR (Id n)

      | ABS ty t' => ABS ty (walk d (nat_plus c one) t')
      | APP t1 t2 => APP (walk d c t1) (walk d c t2)
      | AT p t'   => AT p (walk d c t')
      | LN t1 t2  => LN (walk d c t1) (walk d c t2)
      | BR t1 t2  => BR (walk d c t1) (walk d c t2)
      | _ => t

fun termShift (d : pm) (t : apdt) = walk d O t

fun walkS (j : nat) (s : apdt) (c : nat) (t : apdt) =
    case t of
        VAR (Id n) => if (nat_eq n (nat_plus j c))
                      then termShift (Plus c) s
                      else VAR (Id n)

      | ABS ty t' => ABS ty (walkS j s (nat_plus c one) t')
      | APP t1 t2 => APP (walkS j s c t1) (walkS j s c t2)
      | AT p t'   => AT p (walkS j s c t')
      | LN t1 t2  => LN (walkS j s c t1) (walkS j s c t2)
      | BR t1 t2  => BR (walkS j s c t1) (walkS j s c t2)
      | _ => t

fun termSubst (j : nat) (s : apdt) (t : apdt) = walkS j s O t

fun termSubstTop (s : apdt) (t : apdt) =
    termShift Minus (termSubst O (termShift (Plus one) s) t)

fun eval (p : pl) (s : system) (t : apdt) =
    case t of
        V v => Some (V v)
      | VAR i => None
      | MEA USM => Some (V (Vu p (measureUsm s p)))
      | MEA (KIM q) => Some (V (Vk q p (measureKim s q)))
      | NONCE => Some (V (Vnv p (genNonce p)))
      | COM SIG => None
      | AT (V (Vpla q)) t' => eval q s t'
      | AT _ _ => None
      | LN t1 t2 => (case t2 of
                         COM SIG => (case (eval p s t1) of
                                         Some (V v1) => Some (V (Vg p (signEv p v1) v1))
                                       | _ => None)

                       | _ => (case (eval p s t1) of
                                   Some (V v1) => (case (eval p s t2) of
                                                       Some (V v2) => Some (V (Vss v1 v2))
                                                     | _ => None)
                                 | _ => None))

(* Another way to do the LN case *)
(* | LN t1 t2 => (case (eval p s t1) of *)
(*                    Some (V v1) => (case t2 of *)
(*                                        COM SIG => Some (V (Vg p (signEv p v1) v1)) *)
(*                                      | _ => (case (eval p s t2) of *)
(*                                                  Some (V v2) => Some (Vss v1 v2) *)
(*                                                | _ => None)) *)
(*                  | _ => None) *)

      | BR t1 t2 => (case (eval p s t1) of
                         Some (V v1) => (case (eval p s t2) of
                                             Some (V v2) => Some (V (Vpp v1 v2))
                                           | _ => None)
                       | _ => None)

      | ABS ty t' => Some (ABS ty t')
      | APP t1 t2 => (case (eval p s t1) of
                          Some (ABS ty t1') => (case (eval p s t2) of
                                                    Some (V v) => Some (termSubstTop (V v) t1')
                                                  | _ => None)
                        | _ => None)

fun eapdt t = eval O emptySystem t
