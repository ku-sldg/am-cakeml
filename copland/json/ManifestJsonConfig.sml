
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


end
