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

(* convert a JSON to a coq MapC *)
(* json_map_to_coq_MapC :: (string,json) map -> (string -> 'a) -> coq_MapC string 'a *)
fun json_map_to_coq_MapC (jsonMap : (string,Json.json) map) fromStrFn =
  let val asc_list = Map.toAscList jsonMap
      val aux_fn = fn (k,v) => 
        let val v' = case Json.toString v of
                      Some s => fromStrFn s
                    | None => raise (Exception ("json_to_coq_MapC: not a string: \"" ^ Json.stringify v ^ "\"\n"))
        in (Coq_pair k v') end
  in
    List.map aux_fn asc_list
  end

