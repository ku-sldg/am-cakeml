
(* TODO: dependencies *)
structure AM_CLI_Utils = struct
  type priv_key_t = string
  type server_am_args_t = coq_AM_Manager_Config
  (* (coq_Manifest * coq_AM_Library * coq_FS_Location * priv_key_t) *)
  type client_am_args_t = (coq_Manifest * coq_Term)
  
  (* Parse a JSON file into a JSON object *)
  (* : string -> (coq_Manifest, string) coq_ResultT *)
  fun parse_term_from_file (filename : string) =
    let
      val file_text = TextIOExtra.readFile filename
    in
      case (Json.parse file_text) of
        Err c => Coq_errC c
      | Ok js => 
        case (cakeML_JSON_to_coq_JSON js) of
          Coq_errC c => Coq_errC c
        | Coq_resultC js =>
          let val (Build_Jsonifiable _ from_JSON) = coq_Jsonifiable_Term
          in
            from_JSON js
          end
    end

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
          let val (Build_Jsonifiable _ from_JSON) = concrete_Jsonifiable_Manifest
          in
            from_JSON js
          end
    end

  fun argIndPresent (i:int) = (i <> ~1)
  
  fun retrieve_Client_AM_CLI_args _ =
    let val name = CommandLine.name ()
        val usage = ("Usage: " ^ name ^ "you basically cant use this wrong")
        val argList = CommandLine.arguments ()
        (* val usage = ("Usage: " ^ name ^ "-m <ManifestFile>.json -t <term_file>.json\n\ne.g.\t" ^ name ^ " -m formMan.json -t cert.json\n\n")
        val argList = CommandLine.arguments ()
        val manInd        = ListExtra.find_index argList "-m"
        val termInd        = ListExtra.find_index argList "-t"
        val manIndBool    = argIndPresent manInd 
        val termIndBool   = argIndPresent termInd  *)
    in 
      ()
    (* if ((manIndBool = False) orelse (termIndBool = False))
    then raise (Exception ("Invalid Arguments\n" ^ usage))
    else (
      let val manFileName   = List.nth argList (manInd + 1)
          val termFileName  = List.nth argList (termInd + 1)
      in
        (case (parse_manifest_from_file manFileName) of
          Coq_errC e => raise (Exception ("Could not parse JSON Manifest file: " ^ e ^ "\n"))
        | Coq_resultC manifest =>
          (case (parse_term_from_file termFileName) of
            Coq_errC e => raise (Exception ("Could not parse Term file: " ^ e ^ "\n"))
          | Coq_resultC term => (manifest, term)
          )
          )
      end) *)
    end

  (* Retrieves the manifest filename and private key (as strings)
    based upon Command Line arguments
    : () -> am_args_t
  *)
  fun retrieve_Server_AM_CLI_args _ =
    (let val name = CommandLine.name ()
        val usage = ("Usage: " ^ name ^ "-m <ManifestFile>.json -b <asp_bin_location> -u <ip:port>\n\ne.g.\t" ^ name ^ " -m formMan.json -b /opt/asps -u localhost:5000\n\n")
        val argList = CommandLine.arguments ()
        val manInd        = ListExtra.find_index argList "-m"
        val aspBinInd     = ListExtra.find_index argList "-b"
        val uuidInd       = ListExtra.find_index argList "-u"
        val manIndBool    = argIndPresent manInd 
        val aspBinBool    = argIndPresent aspBinInd
        val uuidIndBool   = argIndPresent uuidInd
    in 
      if ((manIndBool = False) orelse (aspBinBool = False) orelse (uuidIndBool = False))
      then raise (Exception ("Invalid Arguments\n" ^ usage))
      else (
        let val manFileName   = List.nth argList (manInd + 1)
            val aspBinLoc     = List.nth argList (aspBinInd + 1)
            val uuidLoc       = List.nth argList (uuidInd + 1)
        in
          (case (parse_manifest_from_file manFileName) of
            Coq_errC e => raise (Exception ("Could not parse JSON Manifest file: " ^ e ^ "\n"))
          | Coq_resultC manifest =>
              (Coq_mkAM_Man_Conf manifest aspBinLoc uuidLoc)
          )
        end
      )
    end) : server_am_args_t
end