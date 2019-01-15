(* ********************************** *)

val filename = Json.jsonFileName "j2a"
val parse_output = ((Json.fromFileMany filename)
    handle Json.ERR fcnName msg => (print ("Json.ERR in: " ^ fcnName ^ " " ^ msg ^ "\n\n"); ([], "")))

val parsed = fst parse_output
val len = List.length parsed
val _ = print (snd parse_output)
val _ = print ("number of json objects: " ^ (Int.toString len) ^ "\n\n")
(* val _ = List.map print (List.map (fn x => Json.print_json x 0) parsed) *)

fun displayConversion js =
    tToString (JsonToApdt.jsonToApdt js) ^ "\n\n"
    handle Json.ERR fcnName msg => "Json.ERR in: " ^ fcnName ^ " " ^ msg ^ "\n\n"


val _ = List.map print (List.map displayConversion parsed)
