
(* TODO: dependencies *)
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
          TextIO.BadFileName => Err ("Bad file name: " ^ file)
          | TextIO.InvalidFD   => Err "Invalid file descriptor"
          (* TODO: Handle JSON parsing exceptions *)

  (* Writes json to a file
    : Json.json -> string -> unit *)
  fun writeJsonFile (j : Json.json) (file : string) =
      (TextIOExtra.writeFile file (Json.stringify j)
      handle 
          TextIO.BadFileName => raise Excn ("Bad file name: " ^ file)
          | TextIO.InvalidFD   => raise Excn "Invalid file descriptor") : unit


(* Now we want to convert each element in the plcPairList to 
  a pair representation
    (json) -> ('a * 'b) *)
fun converter (j : Json.json) f g =
    (let val jsonSubList = (case (Json.toList j) of
                              None => raise (Excn "Could not convert a JSON place mapping to a list")
                              | Some v => v)
        val a = (case ((* Json.toString *) f (List.nth jsonSubList 0)) of
                    None => raise (Excn "Could not convert (fst pr) in Json list to type a")
                    | Some v => v)
        val b = (case ((* Json.toString *) g (List.nth jsonSubList 1)) of
                    None => raise (Excn "Could not convert (snd pr) in Json list to type b")
                    | Some v => v)
    in
      (Coq_pair a b)
    end) (* : ('a, 'b) prod *)



(* Attempts to extract a map from a Json structure
  : Json.json -> (('a, 'b) coq_MapD) *)
fun extract_map_gen (j : Json.json) (k_top:string) f g (* (f : string -> 'a) *) =
    (let val gatherPlcs = case (Json.lookup k_top j) of
                            None => raise (Excn ("Could not find " ^ k_top ^ " field in JSON"))
                            | Some v => v
        val jsonPairList = case (Json.toList gatherPlcs) of
                        None => raise (Excn ("Could not convert Json into a list of json pairs")) 
                        | Some m => m (* (json list) *)

        val plcPairList = (List.map (fn x => (converter x f g)) jsonPairList) (* : ((('a, 'b) prod) list) *)
    in
      plcPairList
    end) (* :  ('a, 'b) coq_MapD) *)




(*


 (* Attempts to extract a map from a Json structure
    : Json.json -> (('a, 'b) coq_MapD) *)
  fun extract_map_gen (j : Json.json) (k_top:string) f (* (f : string -> 'a) *) =
      (let val gatherPlcs = case (Json.lookup k_top j) of
                              None => raise (Excn ("Could not find " ^ k_top ^ " field in JSON"))
                              | Some v => v
          val jsonPlcPairList = case (Json.toList gatherPlcs) of
                          None => raise (Excn ("Could not convert Json into a list of json pairs")) 
                          | Some m => m (* (json list) *)
          (* Now we want to convert each element in the plcPairList to 
            a pair representation
              (json) -> ('a * 'b) *)
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
                (Coq_pair plc (f uuid))
              end) (* : ('a, 'b) prod *)
          val plcPairList = (List.map converter jsonPlcPairList) (* : ((('a, 'b) prod) list) *)
      in
        plcPairList
      end) (* :  ('a, 'b) coq_MapD) *)

*)

fun decodePubkeyJsonString (j:Json.json) = 
      case (Json.toString j) of 
        None => None 
        | Some s => Some (BString.unshow s) : BString.bstring option




  fun extract_plcMap    (j:Json.json) = extract_map_gen j "plcMap" Json.toString Json.toString

  fun extract_pubKeyMap (j:Json.json) = extract_map_gen j "pubKeyMap" Json.toString decodePubkeyJsonString

  fun extract_appMap    (j:Json.json) = extract_map_gen j "appMap" Json.toString Json.toString

  fun extract_policy    (j:Json.json) = extract_map_gen j "policy" Json.toString Json.toString

  (* Encodes the (('a, 'b) coq_MapD) as Json.json
    : (('a, 'b) coq_MapD) -> ('b -> string) -> Json.json *)
  fun encode_map_gen m f g =
      let fun encoder ab_pair = 
            let val Coq_pair aval bval = ab_pair
            in
              (* Converts the pair to a Json list representing the pair *)
              (Json.fromList [(* Json.fromString *) f aval, (* Json.fromString (f bval) *) g bval])
            end
          val newList = (List.map encoder m)
      in
        (Json.fromList newList)
      end


  fun encode_plcMap m = encode_map_gen m Json.fromString Json.fromString

  fun encode_pubKeyMap m = encode_map_gen m Json.fromString (fn s => Json.fromString (BString.show s))

  fun encode_appMap m = encode_map_gen m Json.fromString Json.fromString

  fun encode_policy m = encode_map_gen m Json.fromString Json.fromString


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

  (* Encodes a coq_Manifest into its JSON representation 
    : coq_Manifest -> Json.json *)
  fun encode_Manifest (cm : coq_Manifest) =
    let val (Build_Manifest myplc aspidList appAspMap uuidPlcList pubkeyPlcList targetPlcList policyVal) = cm
        val cmJson = [
          ("plc", Json.fromString myplc),
          ("asps", (aspidListToJsonList aspidList)),
          ("appMap", (encode_appMap appAspMap)),
          ("uuidPlcs", (placeListToJsonList uuidPlcList)),
          ("pubKeyPlcs", (placeListToJsonList pubkeyPlcList)),
          ("targetPlcs", (placeListToJsonList targetPlcList)),
          ("policy", encode_policy policyVal)
        ]
    in
      Json.fromMap (Map.fromList String.compare cmJson)
    end


(* Parses Json representation of a formal manifest into a coq_Manifest 
  : Json.json -> coq_Manifest *)
fun extract_Manifest (j : Json.json) =
  let val plc = (parse_and_cast j "plc" string_cast)
      val asps = extract_list_items j "asps"
      val appAsps = extract_appMap j 
      val uuidPlcs = extract_list_items j "uuidPlcs"
      val pubKeyPlcs = extract_list_items j "pubKeyPlcs"
      val targetPlcs = extract_list_items j "targetPlcs"
      val policy = extract_policy j

  in
    (Build_Manifest plc asps appAsps uuidPlcs pubKeyPlcs targetPlcs policy)
  end

fun coqPair_toCodeString pr (* (:('a, 'b) prod)*) f (* :'a -> string) *) g (* :'b -> string) *) = 
    case pr of 
      Coq_pair a b => 
        let val lstring = f a 
            val rstring = g a in ("( Coq_pair " ^ lstring ^ " " ^ rstring ^ " )") 
        end

fun policy_plc_helper (p:coq_Plc) = "\"" ^ (plToString p) ^ "\"" : string 

fun policy_aspid_helper (i:coq_ASP_ID) = "\"" ^ (aspIdToString i) ^ "\"" : string 


fun write_FormalManifest_file_json (pathPrefix : string) (c : coq_Manifest) =
  (let val (Build_Manifest my_plc asps appMap uuidPlcs pubKeyPlcs targetPlcs policy) = c
      val fileName = (pathPrefix ^ "/FormalManifest_" ^ my_plc ^ ".json")
      val _ = TextIOExtra.writeFile fileName (Json.stringify (encode_Manifest c))
      val _ = c_system ("chmod 777 " ^ fileName)
  in
    ()
  end
  handle 
    TextIO.BadFileName => raise Excn ("Bad file name: " ^ (pathPrefix ^ "FormalManifest_<PLCNAMEHERE>.json"))
    | TextIO.InvalidFD   => raise Excn "Invalid file descriptor") : unit

fun read_FormalManifest_file_json (*(pathPrefix : string)*) (manfile:string) =
      (let val s = TextIOExtra.readFile manfile
          val jsonman = 
            case Json.parse s of
              Ok j => j
            | Err e => raise Excn ("Could not parse JSON file: " ^ e ^ "\n")
  in
    (extract_Manifest jsonman)
  end
  handle 
    TextIO.BadFileName => raise Excn ("Bad file name: " ^ manfile)(* (pathPrefix ^ "FormalManifest_<PLCNAMEHERE>.sml")) *)
    | TextIO.InvalidFD   => raise Excn "Invalid file descriptor"
    | Excn e => raise Excn ("Could not parse JSON file: " ^ e ^ "\n")) : coq_Manifest



(*  fun encode_termPlcList : ((coq_Term coq_Plc) coq_Pair) list -> json *)
fun encode_termPlcList m = encode_map_gen m termToJson Json.fromString

(*  fun extract_termPlcList : json -> ((coq_Term, coq_Plc) prod) list *)
fun extract_termPlcList (Json.Array args) =
    List.map (fn j => (converter j (fn t => Some (jsonToTerm t)) Json.toString)) args


(*  fun encode_EvidencePlcList : ((coq_Evidence coq_Plc) coq_Pair) list -> json *)
fun encode_EvidencePlcList m = encode_map_gen m evToJson Json.fromString

(*  fun extract_EvidencePlcList : json -> ((coq_Evidence, coq_Plc) prod) list *)
fun extract_EvidencePlcList (Json.Array args) =
    List.map (fn j => (converter j (fn et => Some (jsonToEv et)) Json.toString)) args


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
          val termJson = case Json.parse s of
              Ok j => j
            | Err e => raise Excn ("Could not parse JSON file: " ^ e ^ "\n")
  in
    (jsonToTerm termJson)
  end
  handle 
    TextIO.BadFileName => raise Excn ("Bad file name in read_term_file_json: " ^ filepath)
    | TextIO.InvalidFD   => raise Excn "Invalid file descriptor in read_term_file_json") : coq_Term






fun write_termPlcList_file_json (filepath : string) (ts : ((coq_Term, coq_Plc) prod) list) =
  (let val _ = TextIOExtra.writeFile filepath (Json.stringify (encode_termPlcList ts))
      val _ = c_system ("chmod 777 " ^ filepath)
  in
    ()
  end
  handle 
    TextIO.BadFileName => raise Excn ("Bad file name in write_termPlcList_file_json: " ^ (filepath))
    | TextIO.InvalidFD   => raise Excn "Invalid file descriptor in write_termPlcList_file_json") : unit



fun read_termPlcList_file_json (filepath:string) =
      (let val s = TextIOExtra.readFile filepath
          val termPlcListJson = case Json.parse s of
              Ok j => j
            | Err e => raise Excn ("Could not parse JSON file: " ^ e ^ "\n")
  in
    (extract_termPlcList termPlcListJson)
  end
  handle 
    TextIO.BadFileName => raise Excn ("Bad file name in read_termPlcList_file_json: " ^ filepath)
    | TextIO.InvalidFD   => raise Excn "Invalid file descriptor in read_termPlcList_file_json") : ((coq_Term, coq_Plc) prod) list






fun write_EvidencePlcList_file_json (filepath : string) (ts : ((coq_Evidence, coq_Plc) prod) list) =
  (let val _ = TextIOExtra.writeFile filepath (Json.stringify (encode_EvidencePlcList ts))
      val _ = c_system ("chmod 777 " ^ filepath)
  in
    ()
  end
  handle 
    TextIO.BadFileName => raise Excn ("Bad file name in write_EvidencePlcList_file_json: " ^ (filepath))
    | TextIO.InvalidFD   => raise Excn "Invalid file descriptor in write_EvidencePlcList_file_json") : unit



fun read_EvidencePlcList_file_json (filepath:string) =
      (let val s = TextIOExtra.readFile filepath
          val evidencePlcListJson = case Json.parse s of
              Ok j => j
            | Err e => raise Excn ("Could not parse JSON file: " ^ e ^ "\n")
  in
    (extract_EvidencePlcList evidencePlcListJson)
  end
  handle  (* TODO: handle bad json parsing here?! *)
    TextIO.BadFileName => raise Excn ("Bad file name in read_evidencePlcList_file_json: " ^ filepath)
    | TextIO.InvalidFD   => raise Excn "Invalid file descriptor in read_evidencePlcList_file_json") : ((coq_Evidence, coq_Plc) prod) list









fun write_FormalManifestList_json (pathPrefix : string) (cl : coq_Manifest list) =
    List.map (write_FormalManifest_file_json pathPrefix) cl

fun print_json_man_id (m:coq_Manifest) =
    let val _ = print ("\n" ^ (Json.stringify (encode_Manifest m)) ^ "\n") in
    m
    end

fun print_json_man_list (ls: coq_Manifest list) =
    let val _ = List.map print_json_man_id ls
    in
      ()
    end

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
      val _ = print_json_man_list man_list in 
        ()
  end
  handle Excn e => TextIOExtra.printLn e


(* TODO: better error handling here -- i.e. reasonable error message if file not found... *)
fun parse_private_key file =
  BString.unshow (TextIOExtra.readFile file)

fun argIndPresent (i:int) = (i <> ~1)
  

(* Retrieves the manifest filename and private key (as strings)
  based upon Command Line arguments
  : () -> (string, string) 
*)
fun retrieve_CLI_args _ =
  let (* val _ = print "\n\nDEBUG PRINT:  START of retrieve_CLI_args... \n\n" *)
      val name = CommandLine.name ()
      val usage = ("Usage: " ^ name ^ " -m <ManifestFile>.json -k <privateKeyFile> (-t <ClientTermFile>.json)\n " ^
                    "e.g.\t" ^ name ^ " -m formMan.json -k ~/.ssh/id_ed25519 -t clientPhrase.json\n")
      val (manFileName, privKey, termFileName, provisioningBool) = 
              (case CommandLine.arguments () of 
                  argList => (
                    let val manInd = ListExtra.find_index argList "-m"
                        val keyInd = ListExtra.find_index argList "-k"
                        val termFileInd = ListExtra.find_index argList "-t"
                        val provInd = ListExtra.find_index argList "-p" 
                        val manIndBool = argIndPresent manInd 
                        val keyIndBool = argIndPresent keyInd
                        val provIndBool = argIndPresent provInd
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
                                  val termFile = List.nth argList (termFileInd + 1) 
                                  (* val _ = print "\n\nDEBUG PRINT:  In retrieve_CLI_args... \n\n" *)
                                  in
                                  (
                                    case (parseJsonFile manFileName) of
                                      Err e => raise (Excn ("Could not parse JSON file: " ^ e ^ "\n"))
                                    | Ok _ => (manFileName, (parse_private_key privKeyFile), termFile, provIndBool)
                                           (* TODO: case match on parse_private_key for better error handling here...  *)
                                  )
                                end )))
                  end ))
        in
          (manFileName, privKey, termFileName, provisioningBool) : (string * pubKey_t * string * bool)
      end
end