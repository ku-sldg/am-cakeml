(* custom Maps impl in cakeml to match the Coq version:  coq_MapC *)

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
