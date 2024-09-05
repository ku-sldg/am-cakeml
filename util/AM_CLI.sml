
(* TODO: dependencies *)
structure AM_CLI_Utils = struct
  type priv_key_t = string
  type server_am_args_t = coq_AM_Manager_Config
  type client_am_args_t = (coq_Term * coq_Attestation_Session)
  
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
          let val (Build_Jsonifiable _ from_JSON) = concrete_Jsonifiable_Term
          in
            from_JSON js
          end
    end
  
  (* Parse a JSON file into a JSON object *)
  (* : string -> (coq_Attestation_Session, string) coq_ResultT *)
  fun parse_att_session_from_file (filename : string) =
    let
      val file_text = TextIOExtra.readFile filename
    in
      case (Json.parse file_text) of
        Err c => Coq_errC c
      | Ok js => 
        case (cakeML_JSON_to_coq_JSON js) of
          Coq_errC c => Coq_errC c
        | Coq_resultC js =>
          let val (Build_Jsonifiable _ from_JSON) = concrete_Jsonifiable_Attestation_Session
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
        val usage = ("Usage: " ^ name ^ " -t <term_file>.json -s <att_session.json> [-att <IP>:<PORT> (default=localhost:5000)] [-app <IP>:<PORT> (default=localhost:5003)] [-fromPlc <Plc> (default=TOP_PLC)] [-toPlc <Plc> (default=P0)]\n\ne.g.\t" ^ name ^ " -t cert.json -s my_session.json -app localhost:5042\n\n")
        val argList = CommandLine.arguments ()
        val termInd        = ListExtra.find_index argList "-t"
        val sessInd        = ListExtra.find_index argList "-s"
        val attInd         = ListExtra.find_index argList  "-att"
        val appInd         = ListExtra.find_index argList  "-app"
        val fromInd        = ListExtra.find_index argList  "-fromPlc"
        val toInd          = ListExtra.find_index argList  "-toPlc"


        val termIndBool    = argIndPresent termInd
        val sessIndBool    = argIndPresent sessInd
        val attIndBool     = argIndPresent attInd
        val appIndBool     = argIndPresent appInd
        val fromIndBool    = argIndPresent fromInd
        val toIndBool      = argIndPresent toInd

    in 
    (
    if ((termIndBool = False) orelse (sessIndBool = False))
    then raise (Exception ("Invalid Arguments\n" ^ usage))
    else (
      let val termFileName  = List.nth argList (termInd + 1)
          val sessFileName  = List.nth argList (sessInd + 1)
      in
          (case (parse_term_from_file termFileName) of
            Coq_errC e => raise (Exception ("Could not parse Term file: " ^ e ^ "\n"))
          | Coq_resultC term =>
            (case (parse_att_session_from_file sessFileName) of
              Coq_errC e => raise (Exception ("Could not parse Attestation Session from Json: " ^ e ^ "\n"))
            | Coq_resultC sess => 
              let val att_UUID = 
              (
                if (attIndBool)
                then List.nth argList (attInd + 1)
                else "localhost:5000"
              )
                  val app_UUID = 
              (
                if (appIndBool)
                then List.nth argList (appInd + 1)
                else "localhost:5003"
              ) 
                  val from_place = 
              (
                if (fromIndBool)
                then List.nth argList (fromInd + 1)
                else "TOP_PLC"
              ) 
                  val to_place = 
              (
                if (toIndBool)
                then List.nth argList (toInd + 1)
                else "P0"
              ) in 
            
                (term, sess, att_UUID, app_UUID, from_place, to_place)
              end
            )
          )
      end
      )
    )
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