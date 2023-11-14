
(* TODO: dependencies *)
structure BashFunctions = struct
  exception Excn string

  (* Writes json to a file
    : Json.json -> string -> unit *)
    fun writeJsonFile (j : Json.json) (file : string) =
        (TextIOExtra.writeFile file (Json.stringify j)
        handle 
            TextIO.BadFileName => raise Excn ("Bad file name: " ^ file)
            | TextIO.InvalidFD   => raise Excn "Invalid file descriptor") : unit

    fun write_FormalManifest_file_json (pathPrefix : string) (c : coq_Manifest) =
    (let val (Build_Manifest my_plc asps appMap uuidPlcs pubKeyPlcs targetPlcs policy) = c
        val fileName = (pathPrefix ^ "/FormalManifest_" ^ my_plc ^ ".json")
        val _ = TextIOExtra.writeFile fileName (Json.stringify (ManifestJsonConfig.encode_Manifest c))
        val _ = c_system ("chmod 777 " ^ fileName)
    in
        ()
    end
    handle 
        TextIO.BadFileName => raise Excn ("Bad file name: " ^ (pathPrefix ^ "FormalManifest_<PLCNAMEHERE>.json"))
        | TextIO.InvalidFD   => raise Excn "Invalid file descriptor") : unit

    fun read_FormalManifest_file_json (*(pathPrefix : string)*) (manfile:string) =
        (let val s = TextIOExtra.readFile manfile
            val jsonman = strToJson s 
    in
        (ManifestJsonConfig.extract_Manifest jsonman)
    end
    handle 
        TextIO.BadFileName => raise Excn ("Bad file name: " ^ manfile)(* (pathPrefix ^ "FormalManifest_<PLCNAMEHERE>.sml")) *)
        | TextIO.InvalidFD   => raise Excn "Invalid file descriptor") : coq_Manifest



    fun write_term_file_json (filepath : string) (t : coq_Term) =
    (let val _ = TextIOExtra.writeFile filepath (Json.stringify (termToJson t))
        val _ = c_system ("chmod 777 " ^ filepath)
    in
        ()
    end
    handle 
        TextIO.BadFileName => raise Excn ("Bad file name in write_term_file_json: " ^ (filepath))
        | TextIO.InvalidFD   => raise Excn "Invalid file descriptor in write_term_file_json") : unit



    fun read_term_file_json (filepath:string) =
        (let val s = TextIOExtra.readFile filepath
            val termJson = strToJson s 
    in
        (jsonToTerm termJson)
    end
    handle 
        TextIO.BadFileName => raise Excn ("Bad file name in read_term_file_json: " ^ filepath)
        | TextIO.InvalidFD   => raise Excn "Invalid file descriptor in read_term_file_json") : coq_Term






    fun write_termPlcList_file_json (filepath : string) (ts : ((coq_Term, coq_Plc) prod) list) =
    (let val _ = TextIOExtra.writeFile filepath (Json.stringify (ManifestJsonConfig.encode_termPlcList ts))
        val _ = c_system ("chmod 777 " ^ filepath)
    in
        ()
    end
    handle 
        TextIO.BadFileName => raise Excn ("Bad file name in write_termPlcList_file_json: " ^ (filepath))
        | TextIO.InvalidFD   => raise Excn "Invalid file descriptor in write_termPlcList_file_json") : unit



    fun read_termPlcList_file_json (filepath:string) =
        (let val s = TextIOExtra.readFile filepath
            val termPlcListJson = strToJson s 
    in
        (ManifestJsonConfig.extract_termPlcList termPlcListJson)
    end
    handle 
        TextIO.BadFileName => raise Excn ("Bad file name in read_termPlcList_file_json: " ^ filepath)
        | TextIO.InvalidFD   => raise Excn "Invalid file descriptor in read_termPlcList_file_json") : ((coq_Term, coq_Plc) prod) list






    fun write_EvidencePlcList_file_json (filepath : string) (ts : ((coq_Evidence, coq_Plc) prod) list) =
    (let val _ = TextIOExtra.writeFile filepath (Json.stringify (ManifestJsonConfig.encode_EvidencePlcList ts))
        val _ = c_system ("chmod 777 " ^ filepath)
    in
        ()
    end
    handle 
        TextIO.BadFileName => raise Excn ("Bad file name in write_EvidencePlcList_file_json: " ^ (filepath))
        | TextIO.InvalidFD   => raise Excn "Invalid file descriptor in write_EvidencePlcList_file_json") : unit



    fun read_EvidencePlcList_file_json (filepath:string) =
        (let val s = TextIOExtra.readFile filepath
            val evidencePlcListJson = strToJson s 
    in
        (ManifestJsonConfig.extract_EvidencePlcList evidencePlcListJson)
    end
    handle 
        TextIO.BadFileName => raise Excn ("Bad file name in read_evidencePlcList_file_json: " ^ filepath)
        | TextIO.InvalidFD   => raise Excn "Invalid file descriptor in read_evidencePlcList_file_json") : ((coq_Evidence, coq_Plc) prod) list









    fun write_FormalManifestList_json (pathPrefix : string) (cl : coq_Manifest list) =
        List.map (write_FormalManifest_file_json pathPrefix) cl


    (*
    fun write_form_man_list_json_and_print_json (pathPrefix : string) (ls:(coq_Term, coq_Plc) prod list) = 
    let val man_list : coq_Manifest list = man_gen_run_attify ls
        val _ = write_FormalManifestList_json pathPrefix man_list
        val _ = print_json_man_list man_list in 
            ()
    end
    handle Excn e => TextIOExtra.printLn e
    *)

    fun write_form_man_list_json_and_print_json_app (pathPrefix : string) (ets:(coq_Evidence, coq_Plc) prod list) (ls:(coq_Term, coq_Plc) prod list) = 
    let val man_list : coq_Manifest list = end_to_end_mangen_final ets ls (* man_gen_run_attify ls *)
        val _ = write_FormalManifestList_json pathPrefix man_list
        val _ = ManifestJsonConfig.print_json_man_list man_list in 
            ()
    end
    handle Excn e => TextIOExtra.printLn e




    fun parse_private_key file =
    BString.unshow (TextIOExtra.readFile file)


    (* Parses a json file into its JSON representation 
        : string -> Json.json *)
    fun parseJsonFile (file : string) =
        Result.mapErr (op ^ "Parsing error: ") (Json.parse (TextIOExtra.readFile file))
        handle 
            TextIO.BadFileName => Err ("Bad file name: " ^ file)
            | TextIO.InvalidFD   => Err "Invalid file descriptor"
            (* TODO: Handle JSON parsing exceptions *)

    fun argIndPresent (i:int) = (i <> ~1)

    fun retrieve_CLI_args _ =
    let val name = CommandLine.name ()
        val usage = ("Usage: " ^ name ^ " -m <ManifestFile>.json -k <privateKeyFile> (-t <ClientTermFile>.json)\n " ^
                        "e.g.\t" ^ name ^ " -m formMan.json -k ~/.ssh/id_ed25519 -t clientPhrase.json\n")
        val (manFileName, privKey, termFileName) = 
                (case CommandLine.arguments () of 
                    argList => (
                        let val manInd = ListExtra.find_index argList "-m"
                            val keyInd = ListExtra.find_index argList "-k"
                            val termFileInd = ListExtra.find_index argList "-t"
                            val manIndBool = argIndPresent manInd 
                            val keyIndBool = argIndPresent keyInd
                        in
                        (
                        if (manIndBool = False)
                        then raise (Excn ("Invalid Arguments\n" ^ usage))
                        else (
                            if (keyIndBool = False)
                            then raise (Excn ("Invalid Arguments\n" ^ usage))
                            else (
                                let val manFileName = List.nth argList (manInd + 1)
                                    val privKeyFile = List.nth argList (keyInd + 1)
                                    val termFile = List.nth argList (termFileInd + 1) in
                                    (
                                        case (parseJsonFile manFileName) of
                                        Err e => raise (Excn ("Could not parse JSON file: " ^ e ^ "\n"))
                                        | Ok _ => (manFileName, (parse_private_key privKeyFile), termFile)
                                    )
                                    end )))
                    end ))
            in
                (manFileName, privKey, termFileName) : (string * coq_PublicKey * string)
        end
    end
