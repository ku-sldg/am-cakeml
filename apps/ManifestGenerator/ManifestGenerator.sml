(* Depends on: util, copland, am/Measurements, am/ServerAm *)

structure ManGen_CLI_Utils = struct
  type ManGenArgs = (coq_Evidence_Plc_list * coq_Term_Plc_list * coq_AM_Library * string)

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
          let val (Build_Jsonifiable _ from_JSON) = (coq_Jsonifiable_Evidence_Plc_list coq_Jsonifiable_Evidence)
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
          let val (Build_Jsonifiable _ from_JSON) = (coq_Jsonifiable_Term_Plc_list coq_Jsonifiable_Term)
          (* NOTE: Same as above for evidence, we have to tell it the jsonifiable class for Terms in case there would be multiple ways *)
          in
            from_JSON js
          end
    end
  
  (* Parse a JSON file into a coq_AM_Library *)
  (* : string -> (coq_AM_Library, string) coq_ResultT *)
  fun parse_am_lib_from_file (filename : string) =
    let
      val file_text = TextIOExtra.readFile filename
    in
      case (Json.parse file_text) of
        Err c => Coq_errC c
      | Ok js => 
        case (cakeML_JSON_to_coq_JSON js) of
          Coq_errC c => Coq_errC c
        | Coq_resultC js =>
          let val (Build_Jsonifiable _ from_JSON) = coq_Jsonifiable_AM_Library
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
          val usage = ("Usage: " ^ name ^ " -t <terms_file>.json -e <evidences_file>.json -l <am_lib>.json -o <output_directory>\n")
      in
        case (CommandLine.arguments()) of
          argList =>
            let val termFileInd   = ListExtra.find_index argList "-t"
                val evidFileInd   = ListExtra.find_index argList "-e"
                val amLibInd      = ListExtra.find_index argList "-l"
                val outDirInd     = ListExtra.find_index argList "-o"

                val termFileBool  = (termFileInd <> ~1)
                val evidFileBool  = (evidFileInd <> ~1)
                val amLibBool     = (amLibInd <> ~1)
                val outDirBool    = (outDirInd <> ~1)
            in
              if ((not termFileBool) orelse (not evidFileBool) orelse (not outDirBool) orelse (not amLibBool))
              then (raise (Exception ("Manifest Generator Argument Error: \n" ^ usage)))
              else
                let val termFile  = List.nth argList (termFileInd + 1) 
                    val evidFile  = List.nth argList (evidFileInd + 1) 
                    val amLibFile = List.nth argList (amLibInd + 1) 
                    val outDir    = List.nth argList (outDirInd + 1)
                in
                  (case (parse_ev_list_from_file evidFile) of
                    Coq_errC c => raise (Exception ("Error parsing evidence file: " ^ c))
                  | Coq_resultC evs =>
                    (case (parse_term_list_from_file termFile) of
                      Coq_errC c => raise (Exception ("Error parsing term file: " ^ c))
                    | Coq_resultC terms => 
                      (case (parse_am_lib_from_file amLibFile) of
                        Coq_errC c => raise (Exception ("Error parsing AM Library file: " ^ c))
                      | Coq_resultC al => (evs, terms, al, outDir))
                    )
                  )
                end
            end
      end) : ManGenArgs
end
  
fun write_manifest_to_file (manifest : coq_Manifest) (filename : string) =
  let
    val (Build_Jsonifiable to_JSON _) = coq_Jsonifiable_Manifest
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
    let val (evid_list, term_list, amLib, out_path) = ManGen_CLI_Utils.retrieve_CLI_args ()
        val _ = print "Manifest Generator CLI Args Retrieved\n"

        val environment = end_to_end_mangen evid_list term_list amLib
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
