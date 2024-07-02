
(* TODO: dependencies *)
structure AM_CLI_Utils = struct
  type priv_key_t = string
  type am_args_t = (coq_Manifest * coq_AM_Library * priv_key_t)

  (* Parse a JSON file into a JSON object *)
  (* : string -> (coq_Manifest, string) coq_ResultT *)
  fun parse_manifest_from_file (filename : string) =
    let
      val file_text = TextIOExtra.readFile filename
    in
      case (Json.parse file_text) of
        Err c => Coq_errC c
      | Ok js => 
        case (cakeML_JSON_to_coq_JSON js) of
          Coq_errC c => Coq_errC c
        | Coq_resultC js =>
          let val (Build_Jsonifiable _ from_JSON) = coq_Jsonifiable_Manifest
          in
            from_JSON js
          end
    end

  (* Parse a JSON file into a JSON object *)
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
  
  (* Parse a private key file into a string *)
  (* : string -> (string, string) coq_ResultT *)
  (* TODO: better error handling here -- i.e. reasonable error message if file not found... *)
  fun parse_private_key file =
    Coq_resultC (BString.unshow (TextIOExtra.readFile file))
    handle Word8Extra.InvalidHex => Coq_errC "BString Unshow Error in parsing private key"
  
  fun argIndPresent (i:int) = (i <> ~1)

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
        val amLibIndBool  = argIndPresent amLibInd
        val keyIndBool    = argIndPresent keyInd
    in 
      if ((manIndBool = False) orelse (amLibIndBool = False))
      then raise (Exception ("Invalid Arguments\n" ^ usage))
      else (
        if (keyIndBool = False)
        then (* We do not have a priv key yet, later we hope to offer it as option to be provisioned later *) 
            raise (Exception ("Invalid Arguments, WE REQUIRE PRIV KEY CURRENTLY!\n" ^ usage))
        else (
          let val manFileName   = List.nth argList (manInd + 1)
              val amLibFileName = List.nth argList (amLibInd + 1)
              val privKeyFile   = List.nth argList (keyInd + 1)
          in
            (case (parse_manifest_from_file manFileName) of
              Coq_errC e => raise (Exception ("Could not parse JSON Manifest file: " ^ e ^ "\n"))
            | Coq_resultC manifest =>
              (case (parse_am_lib_from_file amLibFileName) of
                Coq_errC e => raise (Exception ("Could not parse JSON AM Lib file: " ^ e ^ "\n"))
              | Coq_resultC am_lib =>
                (case (parse_private_key privKeyFile) of
                  Coq_errC e => raise (Exception ("Could not parse private key file: " ^ e ^ "\n"))
                | Coq_resultC priv_key => (manifest, am_lib, priv_key)
                )
              )
            )
          end))
    end
end