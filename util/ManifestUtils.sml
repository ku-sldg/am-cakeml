structure ManifestJsonConfig = struct
  exception Excn string

  type plc_t                  = coq_Plc
  type uuid_t                 = coq_UUID
  type privateKey_t           = coq_PrivateKey
  type pubKey_t               = coq_PublicKey
  type plcMap_t               = ((plc_t, uuid_t) coq_MapD)
  type pubKeyMap_t            = ((plc_t, pubKey_t) coq_MapD)
  type aspServer_t            = coq_ASP_Address
  type pubKeyServer_t         = coq_ASP_Address
  type plcServer_t            = coq_ASP_Address
  type uuidServer_t           = coq_ASP_Address

  (* just a wrapper for bstring.unshow to hoist it into option type 
      : string -> BString.bstring option *)
  fun bstring_cast (s : string) = Some (BString.unshow s)

  (* A wrapper around strings to hoist them into option types 
      : string -> string option *)
  fun string_cast (s : string) = Some s

  (* A wrapper around bools to hoist them into option types 
      : string -> bool option *)
  fun bool_cast (s : string) = 
    let val mid = case s of
                    "true" => True
                    | "false" => False
                    | _ => raise (Excn ("Manifest Json Config Error: Bool Cast cannot be used on '" ^ s ^ "'\n"))
    in
      Some mid
    end

  (* Attempts to parse out a value from Json and cast it
      : Json.json -> string -> (string -> ('A option)) -> 'A *)
  fun parse_and_cast (j : Json.json) (key : string) castFn =
    case (Json.lookup key j) of
      None => raise (Excn ("Could not find '" ^ key ^ "' in JSON"))
      | Some pval => 
          case (Json.toString pval) of
              None => raise (Excn ("'" ^ key ^ "' was found, but is not a string"))
              | Some sval =>
                  case (castFn sval) of
                      None => raise (Excn ("'" ^ key ^ "' found, but could not be cast"))
                      | Some pval' => pval'

  (* Encodes casts a value and encodes it into Json 
      : 'A -> ('A -> string) -> Json.json *)
  fun cast_and_encode v castFn = Json.fromString (castFn v)

  (* Parses a json file into its JSON representation 
      : string -> Json.json *)
  fun parseJsonFile (file : string) =
      Result.mapErr (op ^ "Parsing error: ") (Json.parse (TextIOExtra.readFile file))
      handle 
          TextIO.BadFileName => Err "Bad file name"
          | TextIO.InvalidFD   => Err "Invalid file descriptor"
          (* TODO: Handle JSON parsing exceptions *)

  (* Writes json to a file
    : Json.json -> string -> unit *)
  fun writeJsonFile (j : Json.json) (file : string) =
      (TextIOExtra.writeFile file (Json.stringify j)
      handle 
          TextIO.BadFileName => raise Excn "Bad file name"
          | TextIO.InvalidFD   => raise Excn "Invalid file descriptor") : unit

  (* Attempts to extract a plcMap from a Json structure of a concrete manifest
    : Json.json -> plcMap_t *)
  fun extract_plcMap (j : Json.json) =
      (let val gatherPlcs = case (Json.lookup "plcMap" j) of
                              None => raise (Excn ("Could not find 'plcMap' field in JSON"))
                              | Some v => v
          val jsonPlcPairList = case (Json.toList gatherPlcs) of
                          None => raise (Excn ("Could not convert Json into a list of json pairs")) 
                          | Some m => m (* (json list) *)
          (* Now we want to convert each element in the plcPairList to 
            a pair representation
              (json) -> (plc_t * uuid_t) *)
          fun converter (j : Json.json) =
              (let val jsonSubList = (case (Json.toList j) of
                                        None => raise (Excn "Could not convert a JSON place mapping to a list")
                                        | Some v => v)
                  val plc = (case (Json.toString (List.nth jsonSubList 0)) of
                              None => raise (Excn "Could not convert plc in mapping to a string")
                              | Some v => v)
                  val uuid = (case (Json.toString (List.nth jsonSubList 1)) of
                              None => raise (Excn "Could not convert uuid in mapping to a string")
                              | Some v => v)
              in
                (Coq_pair plc uuid)
              end) : (plc_t, uuid_t) prod
          val plcPairList = (List.map converter jsonPlcPairList) : (((plc_t, uuid_t) prod) list)
      in
        plcPairList
      end) : plcMap_t

  (* Encodes the plc Map as Json.json
    : plcMap_t -> Json.json *)
  fun encode_plcMap (p : plcMap_t) =
      let fun encoder pu_pair = 
              let val Coq_pair plc uuid = pu_pair
              in
                (* Converts the pair to a Json list representing the pair *)
                (Json.fromList [Json.fromString plc, Json.fromString uuid])
              end
          val newList = (List.map encoder p)
      in
        (Json.fromList newList)
      end

  (* Attempts to extract a pubKeyMap from a Json structure of a concrete manifest
    : Json.json -> pubKeyMap_t *)
  fun extract_pubKeyMap (j : Json.json) =
      (let val gatherPlcs = case (Json.lookup "pubKeyMap" j) of
                              None => raise (Excn ("Could not find 'pubKeyMap' field in JSON"))
                              | Some v => v
          val jsonPlcPairList = case (Json.toList gatherPlcs) of
                          None => raise (Excn ("Could not convert Json into a list of json pairs")) 
                          | Some m => m (* (json list) *)
          (* Now we want to convert each element in the plcPairList to 
            a pair representation
              (json) -> (plc_t * pubKey_t) *)
          fun converter (j : Json.json) =
              (let val jsonSubList = (case (Json.toList j) of
                                        None => raise (Excn "Could not convert a JSON pubkey mapping to a list")
                                        | Some v => v)
                  val plc = (case (Json.toString (List.nth jsonSubList 0)) of
                              None => raise (Excn "Could not convert plc in mapping to a string")
                              | Some v => v)
                  val pubKey = (case (Json.toString (List.nth jsonSubList 1)) of
                              None => raise (Excn "Could not convert pubkey in mapping to a string")
                              | Some v => v)
                  val binPubKey = BString.unshow pubKey
              in
                (Coq_pair plc binPubKey)
              end) : ((plc_t, pubKey_t) prod)
          val plcPairList = (List.map converter jsonPlcPairList) : (((plc_t, pubKey_t) prod) list)
      in
        plcPairList
      end) : pubKeyMap_t


  (* Encodes the pubKey Map as Json.json
    : pubKeyMap_t -> Json.json *)
  fun encode_pubKeyMap (p : pubKeyMap_t) =
      let fun encoder ppk_pair = 
            let val Coq_pair plc pubkey = ppk_pair
            in
              (* Converts the pair to a Json list representing the pair *)
              (Json.fromList [Json.fromString plc, Json.fromString (BString.show pubkey)])
            end
          val newList = (List.map encoder p)
      in
        (Json.fromList newList)
      end

  (* Parses Json representation of a concrete manifest into a coq_ConcreteManifest 
    : Json.json -> coq_ConcreteManifest *)
  fun extract_ConcreteManifest (j : Json.json) =
    let val plc = (parse_and_cast j "plc" string_cast)
        (* val uuid = (parse_and_cast j "uuid" string_cast)
        val privateKey = (parse_and_cast j "privateKey" bstring_cast) *)
        val plcMap = extract_plcMap j
        val pubKeyMap = extract_pubKeyMap j
        val aspServer_addr = (parse_and_cast j "aspServer" string_cast)
        val pubKeyServer_addr = (parse_and_cast j "pubKeyServer" string_cast)
        val plcServer_addr = (parse_and_cast j "plcServer" string_cast)
        val uuidServer_addr = (parse_and_cast j "uuidServer" string_cast)
    in
      (Build_ConcreteManifest plc plcMap pubKeyMap
        aspServer_addr pubKeyServer_addr plcServer_addr uuidServer_addr)
    end

  (* Encodes a coq_ConcreteManifest into its JSON representation 
    : coq_ConcreteManifest -> Json.json *)
  fun encode_ConcreteManifest (cm : coq_ConcreteManifest) =
    let val (Build_ConcreteManifest plc plcMap pubKeyMap aspServer_addr pubKeyServer_addr plcServer_addr uuidServer_addr) = cm
        val cmJson = [
          ("plc", Json.fromString plc),
          ("plcMap", (encode_plcMap plcMap)),
          ("pubKeyMap", (encode_pubKeyMap pubKeyMap)),
          ("aspServer", Json.fromString aspServer_addr),
          ("pubKeyServer", Json.fromString pubKeyServer_addr),
          ("plcServer", Json.fromString plcServer_addr),
          ("uuidServer", Json.fromString uuidServer_addr)
        ]
    in
      Json.fromMap (Map.fromList String.compare cmJson)
    end

  (* Encodes a coq_Manifest into its JSON representation 
    : coq_Manifest -> Json.json *)
  fun encode_Manifest (cm : coq_Manifest) =
    let val (Build_Manifest myplc aspidList uuidPlcList pubkeyPlcList policyVal) = cm
        val cmJson = [
          ("plc", Json.fromString myplc),
          ("asps", (aspidListToJsonList aspidList)),
          ("uuidPlcs", (placeListToJsonList uuidPlcList)),
          ("pubKeyPlcs", (placeListToJsonList pubkeyPlcList)),
          ("policy", Json.fromBool policyVal)
        ]
    in
      Json.fromMap (Map.fromList String.compare cmJson)
    end

  (* Extracts from json at key 'key' a list of strings into a list
      : Json.json -> string -> string list *)
  fun extract_list_items (j : Json.json) (key : string) =
    (case (Json.lookup key j) of
      None => raise (Excn ("Could not find '" ^ key ^ "' in JSON"))
      | Some pval => 
          let val partial_list = case (Json.toList pval) of
                                    Some s => s : (Json.json list)
                                    | None => raise (Excn ("Failed to extract list items, the key '" ^ key ^ "' was not a Json list\n"))
          in
            List.map (fn s => 
                        case (Json.toString s) of
                          Some s => s
                          | None => raise (Excn "Failed to extract list items, could not perform Json.toString\n")) partial_list
          end) : (string list)


  (* Parses Json representation of a formal manifest into a coq_Manifest 
    : Json.json -> coq_Manifest *)
  fun extract_Manifest (j : Json.json) =
    let val plc = (parse_and_cast j "plc" string_cast)
        val asps = extract_list_items j "asps"
        val uuidPlcs = extract_list_items j "uuidPlcs"
        val pubKeyPlcs = extract_list_items j "pubKeyPlcs"
        val policy = case (Json.lookup "policy" j) of
                        None => raise (Excn "Cannot find policy in Json for formal manifest\n")
                        | Some p => 
                            case (Json.toBool p) of
                              None => raise (Excn "Policy found but was not a bool")
                              | Some v => v
    in
      (Build_Manifest plc asps uuidPlcs pubKeyPlcs policy)
    end


  fun write_FormalManifest_file (c : coq_Manifest) =
    (let val (Build_Manifest my_plc asps uuidPlcs pubKeyPlcs policy) = c
        val am_cakeml_path_prefix = "/Users/adampetz/Documents/Spring_2023/am-cakeml"
        val fileName = (am_cakeml_path_prefix ^ "/apps/ManifestCompiler/DemoFiles/" ^ "FormalManifest_" ^ my_plc ^ ".sml")
        val _ = TextIOExtra.writeFile fileName ("val formal_manifest = \n\t(Build_Manifest \n\t\t\"" ^ my_plc ^ 
          "\"\n\t\t" ^ (listToString asps (fn a => ("\"" ^ a ^ "\""))) ^ 
          "\n\t\t" ^ (listToString uuidPlcs (fn a => ("\"" ^ a ^ "\""))) ^ 
          "\n\t\t" ^ (listToString pubKeyPlcs (fn a => ("\"" ^ a ^ "\""))) ^ 
          "\n\t\t" ^ (Bool.toString policy) ^ "\n\t) : coq_Manifest")
        val _ = c_system ("chmod 777 " ^ fileName)
    in
      ()
    end
    handle 
      TextIO.BadFileName => raise Excn "Bad file name"
      | TextIO.InvalidFD   => raise Excn "Invalid file descriptor") : unit

fun write_FormalManifestList (cl : coq_Manifest list) =
    List.map write_FormalManifest_file cl

  

fun print_json_man_id (m:coq_Manifest) =
    let val _ = print ("\n" ^ (Json.stringify (encode_Manifest m)) ^ "\n") in
    m
    end

fun print_json_man_list (ls: coq_Manifest list) =
    let val _ = List.map print_json_man_id ls
    in
      ()
    end

fun write_form_man_list_and_print_json (ls:(coq_Term, coq_Plc) prod list) = 
  let val demo_man_list : coq_Manifest list = man_gen_run_attify ls  (* demo_man_gen_run ts p  *)
      val _ = write_FormalManifestList demo_man_list
      (* val _ = print ("\nFormal Manifests generated from phrase: \n\n'" ^ (termToString t) ^ "'\n\nat top-level place: \n'" ^ p ^ "': \n") *)
  in
    (print_json_man_list demo_man_list) : unit
  end
  handle Excn e => TextIOExtra.printLn e

  fun parse_private_key file =
    BString.unshow (TextIOExtra.readFile file)

  fun argIndPresent (i:int) = (i <> ~1)

(*
  fun cli_arg_found (s:string) (argList:string list) = 
    let val ind = ListExtra.find_index argList s in
      argIndPresent ind 
    end
*)
  

  (* Retrieves the concrete manifest and private key 
    based upon Command Line arguments
    : () -> (coq_ConcreteManifest, string, coq_Term)*)
  fun retrieve_CLI_args _ =
    let val name = CommandLine.name ()
        val usage = ("Usage: " ^ name ^ " -m <concreteManifestFile>.json -k <privateKeyFile>\n" ^
                      "e.g.\t" ^ name ^ " -m concMan.json -k ~/.ssh/id_ed25519\n")
        val (jsonFile, privKey) = 
                (case CommandLine.arguments () of 
                    argList => (
                      let val manInd = ListExtra.find_index argList "-m"
                          val keyInd = ListExtra.find_index argList "-k"

                          (*
                          val cert_style_Ind = ListExtra.find_index argList "-cs"
                          val ssl_sig_Ind = ListExtra.find_index argList "-ss"
                          val cert_style_cache_p0_Ind = ListExtra.find_index argList "-csc"
                          val cert_style_cache_p1_Ind = ListExtra.find_index argList "-csc"
                          *)

                          val manIndBool = argIndPresent manInd 
                          val keyIndBool = argIndPresent keyInd
                          (*
                          val cert_style_IndBool = argIndPresent cert_style_Ind
                          val ssl_sig_IndBool = argIndPresent ssl_sig_Ind
                          val cscp0_IndBool = argIndPresent cert_style_cache_p0_Ind
                          val cscp1_IndBool = argIndPresent cert_style_cache_p1_Ind
                          *)

                      in
                      (
                        if (manIndBool = False)
                        then raise (Excn ("Invalid Arguments\n" ^ usage))
                        else (
                          if (keyIndBool = False)
                          then raise (Excn ("Invalid Arguments\n" ^ usage))
                            else (
                                let val fileName = List.nth argList (manInd + 1)
                                    val privKeyFile = List.nth argList (keyInd + 1) in
                                    (
                                      case (parseJsonFile fileName) of
                                        Err e => raise (Excn ("Could not parse JSON file: " ^ e ^ "\n"))
                                      | Ok j => (j, parse_private_key privKeyFile)

                                      (*
                                         let val main_term = 
                                               if (cert_style_IndBool)
                                               then (cert_style)
                                               else (
                                                  if (ssl_sig_IndBool)
                                                  then (kim_meas dest_plc kim_meas_targid)
                                                  else (
                                                      if (cscp0_IndBool)
                                                      then (cert_cache_p0_trimmed)
                                                      else (
                                                          if (cscp1_IndBool)
                                                          then (cert_cache_p1)
                                                          else (kim_meas dest_plc kim_meas_targid)
                                                          )
                                                      )
                                                  ) in
                                                (j, parse_private_key privKeyFile, main_term)
                                           end *)
                                    )
                                  end )))
                    end ))
        val cm = extract_ConcreteManifest jsonFile
         in
           (cm, privKey)
        end
end


structure ManifestUtils = struct
  exception Excn string

  type privateKey_t       = coq_PrivateKey
  type Partial_ASP_CB     = coq_ConcreteManifest -> coq_CakeML_ASPCallback
  type Partial_Plc_CB     = coq_ConcreteManifest -> coq_CakeML_PlcCallback
  type Partial_PubKey_CB  = coq_ConcreteManifest -> coq_CakeML_PubKeyCallback
  type Partial_UUID_CB    = coq_ConcreteManifest -> coq_CakeML_uuidCallback

  type AM_Config = (coq_ConcreteManifest * privateKey_t *
      (coq_CakeML_ASPCallback) * 
      (coq_CakeML_PlcCallback) * 
      (coq_CakeML_PubKeyCallback) * 
      (coq_CakeML_uuidCallback))

  val local_formal_manifest = Ref (Err "Formal Manifest not set") : ((coq_Manifest, string) result) ref

  val local_concreteManifest = Ref (Err "Concrete Manifest not set") : ((coq_ConcreteManifest, string) result) ref

  val local_aspCb = Ref (Err "ASP Callback not set") : ((Partial_ASP_CB, string) result) ref

  val local_plcCb = Ref (Err "Plc Callback not set") : ((Partial_Plc_CB, string) result) ref

  val local_pubKeyCb = Ref (Err "PubKey Callback not set") : ((Partial_PubKey_CB, string) result) ref

  val local_uuidCb = Ref (Err "UUID callback not set") : ((Partial_UUID_CB, string) result) ref

  val local_PrivKey = Ref (Err "Private Key not set") : ((privateKey_t, string) result) ref

  val local_authTerm = Ref (Err "Auth Term not set") : ((coq_Term, string) result) ref

  val local_authEv = Ref (Err "Auth Raw Evidence not set") : ((coq_RawEv, string) result) ref

  (* Retrieves the concrete manifest, or exception if not configured 
    : _ -> coq_ConcreteManifest *)
  fun get_ConcreteManifest _ =
    (case (!local_concreteManifest) of
      (Ok v) => v
      | Err e => raise Excn e) : coq_ConcreteManifest

    (* Retrieves the plc corresponding to this processes Manifest/AM_Config
      throws an exception if configuration not completed
    : _ -> coq_Plc *)
  fun get_myPlc _ = 
    (let val (Build_ConcreteManifest my_plc _ _ _ _ _ _) = get_ConcreteManifest() in
      my_plc
    end) : coq_Plc

  (* Compiles a concrete manifest from a Formal Manifest and AM Lib
    : coq_Manifest -> coq_AM_Library -> coq_ConcreteManifest *)
  fun compile_manifest (fm : coq_Manifest) (al : coq_AM_Library) =
    (case (manifest_compiler fm al) of
      Coq_pair (Coq_pair (Coq_pair (Coq_pair concrete _) _) _) _ => concrete
    ) : coq_ConcreteManifest

  (* Setups up the relevant information and compiles the manifest
      : coq_Manifest -> coq_AM_Library -> () *)
  fun setup_AM_config (fm : coq_Manifest) (al : coq_AM_Library) (privKey : privateKey_t) (t:coq_Term) =
    (case (manifest_compiler fm al) of
      Coq_pair (Coq_pair (Coq_pair (Coq_pair concrete aspDisp) plcDisp) pubKeyDisp) uuidDisp =>
        let val _ = local_formal_manifest := Ok fm
            val _ = local_concreteManifest := Ok concrete
            val _ = local_aspCb := Ok aspDisp
            val _ = local_plcCb := Ok plcDisp
            val _ = local_pubKeyCb := Ok pubKeyDisp
            val _ = local_uuidCb := Ok uuidDisp
            val _ = local_PrivKey := Ok privKey
            val _ = local_authTerm := Ok t
            (*
            val _ = local_authEv := 
              let val myPlc = get_myPlc () in 
                run_cvm_rawEv t myPlc coq_mt
              end
              *)
        in
          ()
        end) : unit

  (* Retrieves the formal manifest, or exception if not configured 
    : _ -> coq_Manifest *)
  fun get_FormalManifest _ =
    (case (!local_formal_manifest) of
      (Ok v) => v
      | Err e => raise Excn e) : coq_Manifest

  (* Retrieves the Copland phrase for request Authorization, or exception if not configured 
    : _ -> coq_Manifest *)
  fun get_authTerm _ =
    (case (!local_authTerm) of
      (Ok v) => v
      | Err e => raise Excn e) : coq_Term

  (* Retrieves the Raw Evidence for request Authorization, or exception if not configured 
    : _ -> coq_Manifest *)
  fun get_AuthEv _ =
    (case (!local_authEv) of
      (Ok v) => v
      | Err e => raise Excn e) : coq_RawEv

  (* Sets the concrete manifest, should not throw
    : coq_ConcreteManifest -> () *)
  fun set_ConcreteManifest (c : coq_ConcreteManifest) =
    let val _ = local_concreteManifest := Ok c
    in 
      ()
    end

  (* Retrieves the asp callback, or exception if not configured 
    : _ -> coq_CakeML_ASPCallback *)
  fun get_ASPCallback _ =
    (let val cm = get_ConcreteManifest() 
    in
      case (!local_aspCb) of
      (Ok v) => (v cm)
      | Err e => raise Excn e
    end) : coq_CakeML_ASPCallback

  (* Retrieves the plc callback, or exception if not configured 
    : _ -> coq_CakeML_PlcCallback *)
  fun get_PlcCallback _ =
    (let val cm = get_ConcreteManifest()
    in
      case (!local_plcCb) of
      (Ok v) => (v cm)
      | Err e => raise Excn e
    end) : coq_CakeML_PlcCallback

  (* Retrieves the asp callback, or exception if not configured 
    : _ -> coq_CakeML_PubKeyCallback *)
  fun get_PubKeyCallback _ =
    (let val cm = get_ConcreteManifest()
    in
      case (!local_pubKeyCb) of
      (Ok v) =>
      let val _ = print "\n\nLooking up pubkey callback\n\n" in
        (v cm)
      end
      | Err e => raise Excn e
    end) : coq_CakeML_PubKeyCallback

  (* Retrieves the asp callback, or exception if not configured 
    : _ -> coq_CakeML_uuidCallback *)
  fun get_UUIDCallback _ =
    (let val cm = get_ConcreteManifest()
    in
      case (!local_uuidCb) of
      (Ok v) => (v cm)
      | Err e => raise Excn e
    end) : coq_CakeML_uuidCallback

  
  (* Retrieves the uuid corresponding to this processes Manifest/AM_Config
      throws an exception if configuration not completed
    : _ -> coq_UUID *)
  fun get_myUUID _ = 
    (let val my_plc = get_myPlc()
        val plc_to_uuid = get_PlcCallback()
        val my_uuid = plc_to_uuid my_plc
    in
      my_uuid
    end) : coq_UUID

  (* Retrieves the private key corresponding to this processes Manifest/AM_Config
      throws an exception if configuration not completed
    : _ -> coq_PrivateKey *)
  fun get_myPrivateKey _ = 
    (case (!local_PrivKey) of
      (Ok v) => v
      | Err e => raise Excn e) : coq_PrivateKey

  (* Retrieves all AM config information, 
      if a Manifest has not be compiled yet it will throw an error
    : _ -> AM_Config *)
  fun get_AM_config _ =
    (let val cm = get_ConcreteManifest()
        val privKey = get_myPrivateKey()
        val aspCb = get_ASPCallback()
        val plcCb = get_PlcCallback()
        val pubKeyCb = get_PubKeyCallback()
        val uuidCb = get_UUIDCallback()
    in
      (cm, privKey, aspCb, plcCb, pubKeyCb, uuidCb)
    end) : AM_Config

  (* Directly combines setup and get steps in one function call. 
      Additionally, we must provide a "fresh" Concrete Manifest to 
      use for manifest operations
    : coq_Manifest -> coq_AM_Library -> AM_Config *)
  fun setup_and_get_AM_config (fm : coq_Manifest) (al : coq_AM_Library) (cm : coq_ConcreteManifest) (privKey : privateKey_t) (t:coq_Term) =
    (let val _ = setup_AM_config fm al privKey t
         val _ = set_ConcreteManifest cm in
      get_AM_config()
    end) : AM_Config
end











(* 

  (* Retrieves the concrete manifest and private key 
    based upon Command Line arguments
    : () -> (coq_ConcreteManifest, string, coq_Term)*)
  fun retrieve_CLI_args _ =
    let val name = CommandLine.name ()
        val usage = ("Usage: " ^ name ^ " -m <concreteManifestFile>.json -k <privateKeyFile>\n" ^
                      "e.g.\t" ^ name ^ " -m concMan.json -k ~/.ssh/id_ed25519\n")
        val (jsonFile, privKey, t) = 
                (case CommandLine.arguments () of 
                    argList => (
                      let val manInd = ListExtra.find_index argList "-m"
                          val keyInd = ListExtra.find_index argList "-k"
                          val cert_style_Ind = ListExtra.find_index argList "-cs"
                          val ssl_sig_Ind = ListExtra.find_index argList "-ss"
                          val cert_style_cache_p0_Ind = ListExtra.find_index argList "-csc"
                          val cert_style_cache_p1_Ind = ListExtra.find_index argList "-csc"

                          val manIndBool = argIndPresent manInd 
                          val keyIndBool = argIndPresent keyInd
                          val cert_style_IndBool = argIndPresent cert_style_Ind
                          val ssl_sig_IndBool = argIndPresent ssl_sig_Ind
                          val cscp0_IndBool = argIndPresent cert_style_cache_p0_Ind
                          val cscp1_IndBool = argIndPresent cert_style_cache_p1_Ind

                      in
                      (
                        if (manIndBool = False)
                        then raise (Excn ("Invalid Arguments\n" ^ usage))
                        else (
                          if (keyIndBool = False)
                          then raise (Excn ("Invalid Arguments\n" ^ usage))
                            else (
                                let val fileName = List.nth argList (manInd + 1)
                                    val privKeyFile = List.nth argList (keyInd + 1) in
                                    (
                                      case (parseJsonFile fileName) of
                                        Err e => raise (Excn ("Could not parse JSON file: " ^ e ^ "\n"))
                                      | Ok j =>
                                         let val main_term = 
                                               if (cert_style_IndBool)
                                               then (cert_style)
                                               else (
                                                  if (ssl_sig_IndBool)
                                                  then (kim_meas dest_plc kim_meas_targid)
                                                  else (
                                                      if (cscp0_IndBool)
                                                      then (cert_cache_p0_trimmed)
                                                      else (
                                                          if (cscp1_IndBool)
                                                          then (cert_cache_p1)
                                                          else (kim_meas dest_plc kim_meas_targid)
                                                          )
                                                      )
                                                  ) in
                                                (j, parse_private_key privKeyFile, main_term)
                                           end
                                    )
                                  end )))
                    end ))
        val cm = extract_ConcreteManifest jsonFile
         in
           (cm, privKey, t)
        end


        *)