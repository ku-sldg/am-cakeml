
(* TODO: dependencies *)
structure AM_CLI_Utils = struct
  type priv_key_t = string
  type am_args_t = (coq_Manifest * coq_AM_Library * priv_key_t)

  (* Parse a JSON file into a JSON object *)
  (* : string -> (coq_Manifest, string) coq_ResultT *)
  fun parse_manifest_from_file (filename : string) =
    let
      val json = TextIOExtra.readFile filename
    in
      case (Json.parse json) of
        Err c => Coq_errC c
      | Ok j => Coq_resultC (ManifestJsonConfig.extract_Manifest j)
    end

  (* Parse a JSON file into a JSON object *)
  (* : string -> (coq_AM_Library, string) coq_ResultT *)
  fun parse_am_lib_from_file (filename : string) =
    let
      val file = TextIO.openIn filename
      val json = TextIO.inputAll file
      val _ = TextIO.closeIn file
    in
      case (Json.parse json) of
        NONE => Err "Could not parse JSON file"
      | SOME j => Ok j
    end
  
  (* Parse a private key file into a string *)
  (* : string -> (string, string) coq_ResultT *)
  fun parse_private_key (filename : string) =
    let
      val file = TextIO.openIn filename
      val key = TextIO.inputAll file
      val _ = TextIO.closeIn file
    in
      Ok key
    end

  (* Retrieves the manifest filename and private key (as strings)
    based upon Command Line arguments
    : () -> (string, string) 
  *)
  fun retrieve_CLI_args _ =
    let val name = CommandLine.name ()
        val usage = ("Usage: " ^ name ^ " -m <ManifestFile>.json -l <AmLibFile>.json (-k <privateKeyFile>)\n\ne.g.\t" ^ name ^ " -m formMan.json -l amLib.json -k ~/.ssh/id_ed25519\n\n")
        val argList = CommandLine.arguments ()
        val manInd        = ListExtra.find_index argList "-m"
        val amLibInd      = ListExtra.find_index argList "-l"
        val keyInd        = ListExtra.find_index argList "-k"
        val manIndBool    = argIndPresent manInd 
        val amLibIndBool  = argIndPresent amLibIndj
        val keyIndBool    = argIndPresent keyInd
    in 
      if ((manIndBool = False) orelse (amLibIndBool = False))
      then raise (Excn ("Invalid Arguments\n" ^ usage))
      else (
        if (keyIndBool = False)
        then (* We do not have a priv key yet, later we hope to offer it as option to be provisioned later *) 
            raise (Excn ("Invalid Arguments, WE REQUIRE PRIV KEY CURRENTLY!\n" ^ usage))
        else (
          let val manFileName   = List.nth argList (manInd + 1)
              val amLibFileName = List.nth argList (amLibInd + 1)
              val privKeyFile   = List.nth argList (keyInd + 1)
          in
            (case (parse_manifest_from_file manFileName) of
              Coq_errC e => raise (Exception ("Could not parse JSON Manifest file: " ^ e ^ "\n"))
            | Coq_resultC r =>
              (case (parse_am_lib_from_file amLibFileName) of
                Coq_errC e => raise (Exception ("Could not parse JSON AM Lib file: " ^ e ^ "\n"))
              | Coq_resultC r =>
                (case (parse_private_key privKeyFile) of
                  Coq_errC e => raise (Exception ("Could not parse private key file: " ^ e ^ "\n"))
                | Coq_resultC r => (manFileName, privKey, termFileName)
                )
              )
            )
          end))
    end
    handle 
              TextIO.BadFileName => Err ("Bad file name: " ^ file)
          | TextIO.InvalidFD   => Err "Invalid file descriptor"
end