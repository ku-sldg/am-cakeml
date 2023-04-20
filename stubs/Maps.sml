(* custom Maps impl in cakeml to match the Coq version:  coq_MapC *)

type ('a, 'b) coq_MapC = ('a, 'b) map (* ('a, 'b) prod list *)

type 'a coq_eqClass = unit

val nat_EqClass = ()

fun map_empty _ = Map.empty nat_compare

fun map_get h m x = Map.lookup m x

fun map_set h m x v = Map.insert m x v

fun invert_map heq1 heq2 m = 
  let val pairList = Map.toAscList m 
      val flipper = fn kv => case kv of (k,v) => (v,k) 
      val revPairList = List.map flipper pairList in
    Map.fromList String.compare revPairList
  end
