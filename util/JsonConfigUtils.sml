structure JsonConfig = struct
  exception Excn string

  type port                 = int
  type queueLength          = int
  type privateKey           = BString.bstring
  type plc                  = int
  type ip                   = string
  type publicKey            = BString.bstring
  type PlcConfig            = (plc * ip * port * publicKey)
  type PlcMap               = ((plc, PlcConfig) map)
  type ClientConfig         = (port * queueLength * privateKey * PlcMap)
  type ServerConfig         = (port * queueLength * privateKey * PlcMap)
  type PubKeyServerConfig   = (port * queueLength * privateKey * PlcMap)

  (* just a wrapper for bstring.unshow to hoist it into option type 
      : string -> BString.bstring option *)
  fun bstring_cast (s : string) = Some (BString.unshow s)

  (* A wrapper around strings to hoist them into option types 
      : string -> string option *)
  fun string_cast (s : string) = Some s

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
      
  (* Gets the Json configuration file, defaults to NULL if we encounter an error
      : _ -> Json.json *)
  fun get_json _ = 
      let val name  = CommandLine.name ()
          val usage = ("Usage: " ^ name ^ " configurationFile\n"
                      ^ "e.g.   " ^ name ^ " config.json\n")

      in case CommandLine.arguments () of
            [fileName] => (
              case parseJsonFile fileName of
                  Err e  => raise (Excn ("Could not parse JSON file: " ^ e ^ "\n"))
                | Ok json => json
          )
      end

  (* Attempts to extract a PlcConfig from a Json structure 
      : Json.json -> PlcConfig *)
  fun extract_plc_config (j : Json.json) =
      let val id = (parse_and_cast j "id" Int.fromString)
          val ip = (parse_and_cast j "ip" string_cast)
          val port = (parse_and_cast j "port" Int.fromString)
          val publicKey = (parse_and_cast j "publicKey" bstring_cast)
      in 
        (id, ip, port, publicKey)
      end

  (* Encodes a PlcConfig into a Json structure 
      : PlcConfig -> Json.json *)
  fun encode_plc_config (p : PlcConfig) =
      let val (id, ip, port, pubkey) = p
          val pConfJson = [
              ("id", cast_and_encode id Int.toString), 
              ("ip", Json.fromString ip),
              ("port", cast_and_encode port Int.toString),
              ("publicKey", cast_and_encode pubkey BString.show)
              ]
      in
        Json.fromMap (Map.fromList String.compare pConfJson)
      end

  (* Attempts to extract a PlcMap from a Json structure 
      : Json.json -> PlcMap *)
  fun extract_plc_map (j : Json.json) =
      let val gatherPlcs = case (Json.lookup "plcs" j) of
                              None => raise (Excn ("Could not find 'plcs' field in JSON"))
                              | Some v => v
          val mapBase = case (Json.toMap gatherPlcs) of
                          None => raise (Excn ("Could not convert Json into a mapping")) 
                          | Some m => m (* (string, json) map *)
          (* Now we want to convert the keys to Plcs and the values to PlcConfigs 
              (string * Json.json) -> (int * PlcConfig) *)
          fun converter ((s, j) : string * Json.json) =
              let val key = case Int.fromString s of
                                None => raise (Excn ("Could not convert plc key to an integer"))
                                | Some v => v
                  val pconf = extract_plc_config j
              in
                (key, pconf)
              end
          val mapList = Map.toAscList mapBase (* (string * json) list *)
          val reIndexedMap = List.map converter mapList (* (int * PlcConfig ) list *)
      in
        (Map.fromList Int.compare reIndexedMap)
      end
  
  (* Encodes a PlcMap into a Json structure
      : PlcMap -> Json.json *)
  fun encode_plc_map (p : PlcMap) = 
      let val unpackedMap = Map.toAscList p
          fun encoder ((p, c) : int * PlcConfig) = 
              (let val pStr = Int.toString p
                  val confJson = encode_plc_config c
              in
                (pStr, confJson)
              end) : (string * Json.json)
          val newList = (List.map encoder unpackedMap) : (string * Json.json) list
          val encMap = (Map.fromList String.compare newList) : (string, Json.json) map
          val insideJson = (Json.fromMap encMap)
      in
        (* We need to get the external "plcs" tag on *)
        (Json.fromPairList [("plcs", insideJson)])
      end

  (* Attempts to extract the ClientConfig from a Json structure 
      : Json.json -> ClientConfig = (port * queueLength * privateKey * PlcMap)*)
  fun extract_client_config (j : Json.json) =
      (let val port = (parse_and_cast j "port" Int.fromString)
          val queueLength = (parse_and_cast j "queueLength" Int.fromString)
          val privateKey = (parse_and_cast j "privateKey" bstring_cast)
          val pmap = extract_plc_map j
      in 
        (port, queueLength, privateKey, pmap)
      end) : ClientConfig

  (* Attempts to extract the ServerConfig from a Json structure 
      : Json.json -> ServerConfig = (port * queueLength * privateKey * PlcMap)*)
  fun extract_server_config (j : Json.json) =
      (let val port = (parse_and_cast j "port" Int.fromString)
          val queueLength = (parse_and_cast j "queueLength" Int.fromString)
          val privateKey = (parse_and_cast j "privateKey" bstring_cast)
          val pmap = extract_plc_map j
      in 
        (port, queueLength, privateKey, pmap)
      end) : ServerConfig

  (* Attempts to extract the PubKeyServerConfig from a Json structure 
      : Json.json -> PubKeyServerConfig = (port * queueLength * privateKey * PlcMap)*)
  fun extract_pubkeyserver_config (j : Json.json) =
      (let val port = (parse_and_cast j "port" Int.fromString)
          val queueLength = (parse_and_cast j "queueLength" Int.fromString)
          val privateKey = (parse_and_cast j "privateKey" bstring_cast)
          val pmap = extract_plc_map j
      in 
        (port, queueLength, privateKey, pmap)
      end) : PubKeyServerConfig
end

