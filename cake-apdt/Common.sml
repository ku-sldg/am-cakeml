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
