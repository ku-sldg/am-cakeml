(* Depends on: util, copland, am/Measurements, am/ServerAm *)

structure ManGen_CLI_Utils = struct
  type ManGenArgs = (coq_ASP_Compat_MapT * coq_Evidence_Plc_list * coq_Term_Plc_list * string)
  
  (* Parse a JSON file into a coq_ASP_Compat_MapT *)
  (* : string -> (coq_AM_Library, string) coq_ResultT *)
  fun parse_compat_map_from_file (filename : string) =
    let
      val file_text = TextIOExtra.readFile filename
    in
      case (Json.parse file_text) of
        Err c => Coq_errC c
      | Ok js => 
        case (cakeML_JSON_to_coq_JSON js) of
          Coq_errC c => Coq_errC c
        | Coq_resultC js =>
          let val (Build_Jsonifiable _ from_JSON) = concrete_Jsonifiable_ASP_Compat_MapT 
          in
            from_JSON js
          end
    end



  (* Parse a JSON file into a coq_Evidence_Plc_list *)
  (* : string -> (coq_Evidence_Plc_list, string) coq_ResultT *)
  fun parse_ev_list_from_file (filename : string) =
    let
      val file_text = TextIOExtra.readFile filename
    in
      case (Json.parse file_text) of
        Err c => Coq_errC c
      | Ok js => 
        case (cakeML_JSON_to_coq_JSON js) of
          Coq_errC c => Coq_errC c
        | Coq_resultC js =>
          let val (Build_Jsonifiable _ from_JSON) = (coq_Jsonifiable_Evidence_Plc_list                        (coq_Jsonifiable_Evidence
                         (jsonifiable_map_serial_serial
                           coq_Stringifiable_ID_Type coq_Eq_Class_ID_Type
                           coq_Stringifiable_ID_Type) coq_Jsonifiable_FWD
                         coq_Jsonifiable_nat
                         (coq_Jsonifiable_ASP_Params
                           (jsonifiable_map_serial_serial
                             coq_Stringifiable_ID_Type coq_Eq_Class_ID_Type
                             coq_Stringifiable_ID_Type))))
          (* NOTE: We have to tell it the jsonifiable class for evidence in case there would be multiple ways to jsonify evidence *)
          in
            from_JSON js
          end
    end
  
  (* Parse a JSON file into a coq_Term_Plc_list *)
  (* : string -> (coq_Term_Plc_list, string) coq_ResultT *)
  fun parse_term_list_from_file (filename : string) =
    let
      val file_text = TextIOExtra.readFile filename
    in
      case (Json.parse file_text) of
        Err c => Coq_errC c
      | Ok js => 
        case (cakeML_JSON_to_coq_JSON js) of
          Coq_errC c => Coq_errC c
        | Coq_resultC js =>
          let val (Build_Jsonifiable _ from_JSON) = (coq_Jsonifiable_Term_Plc_list concrete_Jsonifiable_Term)
          (* NOTE: Same as above for evidence, we have to tell it the jsonifiable class for Terms in case there would be multiple ways *)
          in
            from_JSON js
          end
    end
  
    (**
      gets the command line arguments used to configure the manifest generator
      : () -> ManGenArgs
    *)
  fun retrieve_CLI_args () =
      (let val name = CommandLine.name()
          val usage = ("Usage: " ^ name ^ " -t <terms_file>.json -e <evidences_file>.json -cm <compat_map>.json -o <output_directory>\n")
      in
        case (CommandLine.arguments()) of
          argList =>
            let val termFileInd   = ListExtra.find_index argList "-t"
                val evidFileInd   = ListExtra.find_index argList "-e"
                val compMapInd    = ListExtra.find_index argList "-cm"
                val outDirInd     = ListExtra.find_index argList "-o"

                val termFileBool  = (termFileInd <> ~1)
                val evidFileBool  = (evidFileInd <> ~1)
                val compMapBool   = (compMapInd <> ~1)
                val outDirBool    = (outDirInd <> ~1)
            in
              if ((not termFileBool) orelse (not evidFileBool) orelse (not outDirBool) orelse (not compMapBool))
              then (raise (Exception ("Manifest Generator Argument Error: \n" ^ usage)))
              else
                let val termFile  = List.nth argList (termFileInd + 1) 
                    val evidFile  = List.nth argList (evidFileInd + 1) 
                    val compMapFile = List.nth argList (compMapInd + 1) 
                    val outDir    = List.nth argList (outDirInd + 1)
                in
                  (case (parse_ev_list_from_file evidFile) of
                    Coq_errC c => raise (Exception ("Error parsing evidence file: " ^ c))
                  | Coq_resultC evs =>
                    (case (parse_term_list_from_file termFile) of
                      Coq_errC c => raise (Exception ("Error parsing term file: " ^ c))
                    | Coq_resultC terms => 
                      (case (parse_compat_map_from_file compMapFile) of
                        Coq_errC c => raise (Exception ("Error parsing Compat Map file: " ^ c))
                      | Coq_resultC cm => (cm, evs, terms, outDir))
                    )
                  )
                end
            end
      end) : ManGenArgs
end
  
fun write_manifest_to_file (manifest : coq_Manifest) (filename : string) =
  let
    val (Build_Jsonifiable to_JSON _) = concrete_Jsonifiable_Manifest
    val coq_json = to_JSON manifest
    val json_str = coq_JSON_to_string coq_json
  in
    TextIOExtra.writeFile filename json_str
  end

fun write_out_manifests (out_dir : string) (env_list : coq_EnvironmentM) =
  List.map 
    (fn (plc, man) => 
      (write_manifest_to_file man (out_dir ^ "/Manifest_" ^ plc ^ ".json"))
    ) env_list

fun main () =
    let val (comp_map, evid_list, term_list, out_path) = ManGen_CLI_Utils.retrieve_CLI_args ()
        val _ = print "Manifest Generator CLI Args Retrieved\n"

        val environment = end_to_end_mangen comp_map evid_list term_list 
        val _ = print "Manifests Generated\n"

        val _ = case environment of
                  Coq_errC e => raise (Exception e)
                | Coq_resultC res => write_out_manifests out_path res
        val _ = print "Manifests Written to File\n"
    in
      ()
    end
    handle Exception e => TextIO.print_err e 
          | Word8Extra.InvalidHex => TextIO.print_err "BSTRING UNSHOW ERROR"
          | Json.Exn s1 s2 => TextIO.print_err ("JSON ERROR: " ^ s1 ^ " " ^ s2 ^ "\n") 
          | _ => TextIO.print_err "Unknown Error\n"

val _ = main ()
