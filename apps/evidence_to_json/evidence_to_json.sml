
fun read_global_context (filename : string) =
  let
    val file_text = TextIOExtra.readFile filename
  in
    case (Json.parse file_text) of
      Err c => Coq_errC c
    | Ok js => 
      case (cakeML_JSON_to_coq_JSON js) of
        Coq_errC c => Coq_errC c
      | Coq_resultC js =>
        let val (Build_Jsonifiable _ from_JSON) = concrete_Jsonifiable_GlobalContext 
        in
          from_JSON js
        end
  end
  handle TextIO.BadFileName => raise (Exception ("Error parsing global context from file: Filename '" ^ filename ^ "' does not exist\n"))
  
fun write_evidence_to_file (term : coq_EvidenceT) (filename : string) =
  let
    val (Build_Jsonifiable to_JSON _) = concrete_Jsonifiable_EvidenceT
    val coq_json = to_JSON term
    val json_str = coq_JSON_to_string coq_json
  in
    TextIOExtra.writeFile filename json_str
  end

fun main () =
  case (CommandLine.arguments()) of
    argList =>
    let val termInd     = ListExtra.find_index argList "-t"
        val outFileInd  = ListExtra.find_index argList "-o"
        val globContInd  = ListExtra.find_index argList "-g"

        val termBool    = (termInd <> ~1)
        val outFileBool = (outFileInd <> ~1)
        val globContBool = (globContInd <> ~1)
        
        val name = CommandLine.name()
        val usage = ("Usage: " ^ name ^ " -t [cert|cert_appr|bg|parmut|layered_bg] -o <output_file>\n")
    in
      if ((not termBool) orelse (not globContBool) orelse (not outFileBool))
      then (raise (Exception ("EvidToJson Argument Error: \n" ^ usage)))
      else
        let val termName  = List.nth argList (termInd + 1) 
            val outFile   = List.nth argList (outFileInd + 1)
            val global_context = List.nth argList (globContInd + 1)
            val global_context_val = 
              case read_global_context global_context of
                Coq_resultC globContFile => globContFile
              | Coq_errC c => raise (Exception ("Error parsing global context file: " ^ c))
            val outEvid   = 
            case map_get coq_Eq_Class_ID_Type termName (full_flexible_mechanisms global_context_val) of
              Some term_ev_pair => 
              let val ev : (coq_EvidenceT, string) coq_ResultT = (snd term_ev_pair) in
              case ev of
                Coq_resultC evs => evs
              | Coq_errC c => raise (Exception ("Error parsing evidence file: " ^ c))
              end
            | None => 
              raise (Exception ("EvidToJson Argument Error - Unknown term identifier: \"" ^ termName ^ "\"\n" ^ usage))
        in
          write_evidence_to_file outEvid outFile
        end
    end
    handle Exception e => TextIO.print_err e 
          | Word8Extra.InvalidHex => TextIO.print_err "BSTRING UNSHOW ERROR"
          | Json.Exn s1 s2 => TextIO.print_err ("JSON ERROR: " ^ s1 ^ " " ^ s2 ^ "\n") 
          | _ => TextIO.print_err "Unknown Error\n"

val _ = main ()
