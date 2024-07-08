
fun natToInt n =
    case n
     of O => 0
      | S n' => 1 + natToInt n'

fun natFromInt i = if i < 0
                   then O
                   else if i = 0
                        then O
                        else S (natFromInt (i - 1))

fun nat_from_int_result i = 
    if i < 0
    then Coq_errC ("Int " ^ Int.toString i ^ " is not a valid nat")
    else if i = 0
          then Coq_resultC O
          else case (nat_from_int_result (i - 1)) of
                  Coq_errC s => Coq_errC s
                | Coq_resultC n => Coq_resultC (S n)

val natToString = Int.toString o natToInt

(** val coq_Serializable_nat : nat coq_Serializable **)

val coq_Serializable_nat : nat coq_Serializable =
  Build_Serializable 
    natToString 
    (fn s => 
      case (Int.fromString s) of
        None => Coq_errC ("String " ^ s ^ " is not a valid int")
      | Some v => nat_from_int_result v)
