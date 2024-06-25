(* custom Maps impl in cakeml to match the Coq version:  coq_MapC *)

(* convert a coq MapC to JSON *)
fun coq_MapC_to_Json m toStrFn = 
  let val list_json = 
      List.map (fn (k, v) => (k, Json.fromString (toStrFn v))) m
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
        in (k, v') end
  in
    List.map aux_fn asc_list
  end

