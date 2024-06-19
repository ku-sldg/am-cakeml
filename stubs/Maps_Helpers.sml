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

(* convert a coq MapC to JSON *)
fun coq_MapC_to_Json m toStrFn = 
  let val list_json = 
      List.map (fn (Coq_pair k v) => (k, Json.fromString (toStrFn v))) m
  in
    Json.fromPairList list_json
  end

fun json_to_coq_MapC json fromStrFn = 
  let val asc_list = case Json.toMap json of
                    Some l => Map.toAscList l
                  | None => raise (Exception "json_to_coq_MapC: not a map")
      val aux_fn = fn (k,v) => 
        let val v' = case Json.toString v of
                      Some s => fromStrFn s
                    | None => raise (Exception "json_to_coq_MapC: not a string")
        in (Coq_pair k v') end
  in
    List.map aux_fn asc_list
  end

