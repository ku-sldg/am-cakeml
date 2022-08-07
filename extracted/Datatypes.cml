datatype coq_unit =
  Coq_tt 

datatype bool =
  Coq_true 
| Coq_false 

datatype nat =
  O 
| S nat

datatype 'a option =
  Some 'a
| None 

datatype ('a, 'b) prod =
  Coq_pair 'a 'b

(** val snd : ('a1, 'a2) prod -> 'a2 **)

fun snd p = case p of
  Coq_pair _ y => y

datatype 'a list =
  Coq_nil 
| Coq_cons 'a ('a list)

(** val app : 'a1 list -> 'a1 list -> 'a1 list **)

fun app l m =
  case l of
    Coq_nil => m
  | Coq_cons a l1 => Coq_cons a (app l1 m)
