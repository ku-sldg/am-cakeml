(* custom Maps impl in cakeml to match the Coq version:  coq_MapC *)
(* 
type ('a, 'b) coq_MapC = ('a, 'b) map (* ('a, 'b) prod list *)

type ('a, 'b) coq_MapD = ('a, 'b) map *)

type 'a coq_eqClass = unit

fun pair_to_Coq_pair p =
  let val (f,s) = p
  in
    Coq_pair f s
  end

fun mapD_from_pairList pList = 
  List.map pair_to_Coq_pair pList

fun mapC_from_pairList pList = 
  List.map pair_to_Coq_pair pList


fun map_to_mapC m =
  let val mList = Map.toAscList m
  in
    mList
  end
