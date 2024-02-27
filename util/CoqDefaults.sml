(* No external dependencies *)

(* Default Coq *)

(*
datatype 'a option = None
                   | Some 'a
*)
                     

datatype nat = O
             | S nat

fun natToInt n =
    case n
     of O => 0
      | S n' => 1 + natToInt n'

fun natFromInt i = if i < 0
                   then O
                   else if i = 0
                        then O
                        else S (natFromInt (i - 1))

val natToString = Int.toString o natToInt

fun nat_plus n m =
    case n of O => m
            | S n' => S (nat_plus n' m)


(* add alias added as temp fix for extraction purposes *)
fun add n m = nat_plus n m

fun nat_minus n m =
    case n of O => O
            | S n' => case m of O => n
                              | S m' => (nat_minus n' m')

fun nat_eq n m =
    case n of O => (case m of O => True | _ => False)
            | S n' => (case m of S m' => nat_eq n' m' | _ => False)

fun nat_leb n m =
    case n of O => True
            | S n' => (case m of S m' => nat_leb n' m' | O => False)

fun nat_compare n m = case (n, m)
    of (S n', S m') => nat_compare n' m'
     | (S n', O) => Greater
     | (O, S m') => Less
     | (O, O) => Equal

fun nat_length l =
    case l of
        [] => O
      | h::t => S (nat_length t)

val one = S O

(* List functions *)
fun list_at l (n : nat) =
    case l of [] => None
            | h :: t => (case n of O => Some h
                                 | S n' => list_at t n')

fun listToString l f = String.concat [ "[", listToStringInner l f, "]" ]
and listToStringInner l f =
    case l
     of [] => ""
      | x::[] => f x
      | x::xs => String.concat [(f x), ", ", (listToStringInner xs f)]

fun concatWith s l =
    case l
     of [] => ""
      | x::[] => x
      | x::xs => x ^ s ^ (concatWith s xs)

(* Pair functions *)
fun pair_compare p f1 f2 = let val (p1, p2) = p in
                               let val fst_cmp = f1 p1 in
                                   if fst_cmp = Equal
                                   then f2 p2
                                   else fst_cmp
                               end
                           end
