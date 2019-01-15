(* named_APDT.v *)
datatype napdt = NVAR of id
               | NMEA of m
               | NNONCE
               | NCOM of c
               | NAT  of napdt * napdt
               | NLN  of napdt * napdt
               | NBR  of napdt * napdt
               | NV   of value
               | NABS of id * ty * napdt
               | NAPP of napdt * napdt

fun elem (i : id) (l : id list) =
    case l of [] => false
            | (h :: t) => if (beq_id h i)
                          then true
                          else (elem i t)

fun free_vars (t : napdt) =
    case t of
        NVAR i => [i]
      | NABS i _ t' => List.filter (fn j => not (i = j)) (free_vars t')
      | NAPP t1 t2  => let val f_t1 = free_vars t1 in
                           let val f_t2 = free_vars t2 in
                               f_t1 @ (List.filter (fn x => not (elem x f_t1)) f_t2)
                           end
                       end
      | NAT _ t' => free_vars t'
      | NLN t1 t2 => let val f_t1 = free_vars t1 in
                         let val f_t2 = free_vars t2 in
                             f_t1 @ (List.filter (fn x => not (elem x f_t1)) f_t2)
                         end
                     end
      | NBR t1 t2 => let val f_t1 = free_vars t1 in
                         let val f_t2 = free_vars t2 in
                             f_t1 @ (List.filter (fn x => not (elem x f_t1)) f_t2)
                         end
                     end
      | _ => []

fun generate (n : nat) =
    case n of
        O => []
      | S n' => n :: generate n'

fun free (t : napdt) =
    let val f_t = free_vars t in
        List.zip (f_t, (generate (nat_length f_t)))
    end

fun add_one (s : (id * nat)) =
    case s of (i, n) => (i, (nat_plus n one))

fun db (t : napdt) (s : nat map) =
    case t of
        NVAR i => (case (map_get s i) of
                      Some n => VAR (Id n)
                    | _ => V Vmt)
      | NABS i ev t' => let val l = List.map add_one s in
                            ABS ev (db t' (map_set l i O))
                        end
      | NAPP t1 t2 => APP (db t1 s) (db t2 s)
      | NAT p t' => AT (db p s) (db t' s)
      | NLN t1 t2 => LN (db t1 s) (db t2 s)
      | NBR t1 t2 => BR (db t1 s) (db t2 s)
      | NMEA m => MEA m
      | NCOM c => COM c
      | NV v => V v
      | NNONCE => NONCE

fun debruijnize t = db t (free t)

fun neval t = eapdt (debruijnize t)
