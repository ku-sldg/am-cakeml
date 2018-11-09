(* Default Coq *)
datatype nat = O
             | S of nat

fun nat_plus n m =
    case n of O => m
            | S n' => S (nat_plus n' m)

fun nat_minus n m =
    case n of O => O
            | S n' => case m of O => n
                              | S m' => (nat_minus n' m')

fun nat_eq n m =
    case n of O => (case m of O => true | _ => false)
            | S n' => (case m of S m' => nat_eq n' m' | _ => false)

fun nat_leb n m =
    case n of O => true
            | S n' => (case m of S m' => nat_leb n' m' | O => false)

fun nat_length l =
    case l of
        [] => O
      | h::t => S (nat_length t)

val one = S O
