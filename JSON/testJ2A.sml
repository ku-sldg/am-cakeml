(* ********************************** *)



(*---------------------------------------------------------------------------*)
(* Called from an executable which wants to get <name>.json from the         *)
(* command line.                                                             *)
(*---------------------------------------------------------------------------*)

fun boolFind test alist =
    case List.find test alist
     of Some _ => True
     |  _ => False

fun parseCmdLine execName =
 let fun printHelp() = print ("Usage: "^execName^" {-t} {-e} <name>.json\n")
     fun fail() = (printHelp(); raise Json.ERR "jsonFileName" "")
     fun isDot ch = (ch = #".")
     val args = CommandLine.arguments()
     fun isTermArg s = (s = "-t")
     fun isEvidenceArg s = (s = "-e")
     val filename = case args
                     of [] => fail()
                      | otherwise => (case String.tokens isDot (List.last args)
                                       of [file,"json"] => List.last args
                                        | otherwise => fail())
 in  (filename, boolFind isTermArg args, boolFind isEvidenceArg  args)
 end


val (filename, isTerm, isEvidence) = parseCmdLine "j2a"
val parse_output = ((Json.fromFileMany filename)
    handle Json.ERR fcnName msg => (print ("Json.ERR in: " ^ fcnName ^ " " ^ msg ^ "\n\n"); ([], "")))

val parsed = fst parse_output
val len = List.length parsed
val _ = print (snd parse_output)
val _ = print ("number of json objects: " ^ (Int.toString len) ^ "\n\n")
(* val _ = List.map print (List.map (fn x => Json.print_json x 0) parsed) *)

fun displayTermFromJson js =
    tToString (JsonToApdt.jsonToApdt js) ^ "\n\n"
    handle Json.ERR fcnName msg => "Json.ERR in: " ^ fcnName ^ " " ^ msg ^ "\n\n"

fun displayEvidenceFromJson js =
    evToString (JsonToEvidence.jsonToEvidence js) ^ "\n\n"
    handle Json.ERR fcnName msg => "Json.ERR in: " ^ fcnName ^ " " ^ msg ^ "\n\n"

val _ = if isEvidence
        then List.map print (List.map displayEvidenceFromJson parsed)
        else List.map print (List.map displayTermFromJson parsed)
