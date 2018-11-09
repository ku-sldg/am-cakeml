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
