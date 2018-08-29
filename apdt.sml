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

(* Common.v *)
type bits = nat
type pl = nat

datatype m = USM
           | KIM of pl

datatype c = SIG

datatype id = Id of nat

fun beq_id i j =
    case i of
        (Id i') => case j of
                       (Id j') => if i' = j' then true else false

type 'a map = (id * 'a) list

val map_empty = []

fun map_get m x =
    case m of
        [] => None
      | ((i, a) :: ms) => if i = x then Some a else map_get ms x

fun map_set m i v = (i,v) :: m

fun map_dom m = case m of [] => []
                        | ((i,a)::ms) => i :: map_dom ms

datatype ev = N of nat (* None evidence *)
            | PTE of nat
            | K of nat * nat (* Kernel measurement *)
            | U of nat       (* User spcae measurement *)
            | G of ev * nat  (* Signature *)
            | SS of ev * ev  (* Sequence *)
            | P of ev * ev   (* Parallel *)

datatype value = Vmt
               | Vpla of pl
               | Vu of pl * bits
               | Vk of pl * pl * bits
               | Vnv of pl * bits
               | Vg of pl * bits * value
               | Vss of value * value
               | Vpp of value * value

datatype ty = MEAS
            | PT of nat
            | ARROW of ty * ty

(* (* APDT.v *) *)
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

(* Old *)

val printList = TextIO.print_list

fun natToInt n = case n of O   => 0
                         | S n' => 1 + natToInt n'

(* fun intToNat i = if i <= 0 then O else S (intToNat i - 1) *)

fun natToString n = Int.toString (natToInt n)

val bitsToString = natToString

val placeToString = natToString

fun valueToString (v : value) =
    case v of
        Vmt => "Vmt"
      | Vpla p => String.concat ["Vpla ", placeToString p]
      | Vu p b => String.concat ["Vu ", "(", placeToString p, ") ", "(", bitsToString b, ")"]
      | Vk p1 p2 b => String.concat ["Vk ", "(", placeToString p1, ") ", "(", placeToString p2, ") ", "(", bitsToString b, ")"]
      | Vnv p b    => String.concat ["Vnv ", "(", placeToString p, ") ", "(", bitsToString b, ")"]
      | Vg p b v'  => String.concat ["Vg ", "(", placeToString p, ") ", "(", bitsToString b, ") ", "(", valueToString v', ")"]
      | Vss v1 v2  => String.concat ["Vss ", "(", valueToString v1, ") ", "(", valueToString v2, ")"]
      | Vpp v1 v2  => String.concat ["Vpp ", "(", valueToString v1, ") ", "(", valueToString v2, ")"]

fun measurementToString (m : m) =
    case m of
        USM => "USM"
      | KIM p => String.concat ["KIM ", placeToString p]

fun commandToString (c : c) =
    case c of SIG => "SIG"

fun tyToString (ty : ty) =
    case ty of MEAS => "MEAS"
            | PT n => String.concat ["PT ", natToString n]
            | ARROW ty1 ty2 => String.concat ["(", tyToString ty1, ")", "(", tyToString ty2, ")"]

fun apdtToString (t : apdt) =
    case t of
        VAR (Id n) => String.concat ["VAR ", natToString n]
      | V v => String.concat ["V ", valueToString v]
      | NONCE => String.concat ["NONCE "]
      | MEA m => String.concat ["MEA ", measurementToString m]
      | COM c => String.concat ["COM ", commandToString c]
      | AT p t' => String.concat ["AT ", apdtToString p, apdtToString t']
      | LN t1 t2 => String.concat ["LN ", "(", apdtToString t1, ") ", "(", apdtToString t2, ")"]
      | BR t1 t2 => String.concat ["BR ", "(", apdtToString t1, ") ", "(", apdtToString t2, ")"]
      | ABS ty t' => String.concat ["ABS ", "(", tyToString ty, ") ", "(", apdtToString t', ")"]
      | APP t1 t2 => String.concat ["APP ", "(", apdtToString t1, ") ", "(", apdtToString t2, ")"]

(* Examples *)
fun main () = (print "Nothing Yet\n")
val _ = main ()
