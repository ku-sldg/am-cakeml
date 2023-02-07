(** first, need a function for string comparison (for asp ids) **)

(* CLEANUP: Down the road, this can be extracted
from Eqb_Evidence.v in Coq. We have these functions, 
just a lot of cruft comes with it *)

fun eqb_aspid a1 a2 = (a1 = a2)

(** second, need a function for nat comparison (for place) **)

fun eqb a1 a2 = (a1 = a2)