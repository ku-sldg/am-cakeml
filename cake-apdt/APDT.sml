(* APDT.v *)
datatype apdt = VAR of id
              | NONCE
              | MEA of m
              | COM of c
              | AT of apdt * apdt
              | LN of apdt * apdt
              | BR of apdt * apdt
              | V of value
              | ABS of ty * apdt
              | APP of apdt * apdt

type context = ty list
val (empty_context : context) = []

fun list_at l (n : nat) =
    case l of [] => None
            | h :: t => (case n of O => Some h
                                 | S n' => list_at t n')

fun push_ctx (e : ty) (l : context) = e :: l

fun get_ctx (l : context) (i : id) =
    case i of (Id i') => list_at l i'

fun typeOfV (v : value) =
    case v of Vmt => None
            | Vpla n => Some (PTE n)
            | Vu p _ => Some (U p)
            | Vk q p _ => Some (K q p)
            | Vnv p _  => Some (N p)
            | Vg p _ e => (case (typeOfV e) of
                              Some tv => Some (G tv p)
                            | _ => None)
            | Vss e1 e2 => (case (typeOfV e1) of
                                Some ty1 => (case (typeOfV e2) of
                                                 Some ty2 => Some (SS ty1 ty2)
                                               | None => None)
                              | None => None)
            | Vpp e1 e2 => (case (typeOfV e1) of
                                Some ty1 => (case (typeOfV e2) of
                                                 Some ty2 => Some (P ty1 ty2)
                                               | None => None)
                              | None => None)

fun ev_to_typeR (e : ev) =
    case e of
        PTE q => PT q
      | _ => MEAS

fun typeOf (gamma : context) (t : apdt) (p : pl) =
    case t of
        V v => (case (typeOfV v) of
                    None => None
                  | Some ev => Some (ev_to_typeR ev))

      | VAR i => get_ctx gamma i

      | NONCE => Some MEAS

      | MEA (KIM q) => Some MEAS

      | MEA USM => Some MEAS

      | COM SIG => None

      | AT r t' => (case (typeOf gamma r p) of
                       Some (PT q) => (case (typeOf gamma t' q) of
                                           Some MEAS => Some MEAS
                                         | _ => None)
                     | _ => None)

      | LN t1 t2 => (case t2 of
                         COM SIG => (case (typeOf gamma t1 p) of
                                         Some MEAS => Some MEAS
                                       | _ => None)
                       | _ => (case (typeOf gamma t1 p) of
                                   Some MEAS => (case (typeOf gamma t2 p) of
                                                     Some MEAS => Some MEAS
                                                               | _ => None)
                                 | _ => None))
      | BR t1 t2 => (case (typeOf gamma t1 p) of
                         Some MEAS => (case (typeOf gamma t2 p) of
                                           Some MEAS => Some MEAS
                                         | _ => None)
                       | _ => None)
      | ABS ty t' => (case (typeOf (push_ctx ty gamma) t' p) of
                          Some ty2 => Some (ARROW ty ty2)
                        | _ => None)
      | APP t1 t2 => (case (typeOf gamma t1 p) of
                          Some (ARROW ty1 ty2) => (case (typeOf gamma t2 p) of
                                                       Some ty1' => if ty1 = ty1'
                                                                    then Some ty2
                                                                    else None
                                                     | _ => None)
                        | _ => None)
      | _ => Some MEAS
