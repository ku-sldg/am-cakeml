(* TODO:
 * * Write decrypt FFI
 * * Learn about the purpose of the `nonce` and `counter` in encrypt/decrpyt
 *   operation.
 * * Server to let others validate aliases and grab CA's public key.
 * * A way for local users to update the CA's public key database.
 * * Generate public & private keys for CA.
 *)
structure CA =
struct
    local
        val idCompare = BString.compare
        (* The CA's private signing key *)
        val signingKey =
            BString.unshow "F315A3F90B070341EF55421644CF19C2AE62AC7DAE28A99C06DB9907F059452A"
        (* The CA's private encryption key *)
        val encryptKey =
            BString.unshow "D18CF9B8440CF722EDBF31F1BA5F0F67C4913FEFA93744C0B8B180A91698A40A"
        (* pubkeyMap: (id_type, bstring) map ref *)
        val pubkeyMap = Ref (Map.fromList idCompare [(BString.nullByte, BString.nullByte)])
    in
        (* addPublicKey: id_type -> bstring -> unit
         * `addPublicKey id pubkey`
         * Adds `(id, pubkey)` to the CA record.
         *)
        fun addPublicKey id pubkey = 
            pubkeyMap := Map.insert (!pubkeyMap) id pubkey
        (* removePublicKey: id_type -> bstring -> unit
         * `removePublicKey id`
         * Removes the public key for agent with ID is `id` from the CA record.
         *)
        fun removePublicKey id =
            pubkeyMap := Map.delete (!pubkeyMap) id
        (* updatePublicKey: id_type -> bstring -> unit
         * `updatePublicKey id pubkey`
         * Update the CA record with the entry `(id, pubkey)`.
         *)
        fun updatePublicKey id pubkey =
            (removePublicKey id;
            addPublicKey id pubkey)
        (* lookupPublicKey: id_type -> bstring option
         * `lookupPublicKey id`
         * Looks up the public key associated with `id`.
         *)
        fun lookupPublicKey id = Map.lookup (!pubkeyMap) id
        (* getSigningKey: unit -> bstring
         * Returns the CA's public signature key.
         *)
        fun getSigningKey () =
            Ok (Crypto.generateSignaturePublicKey signingKey)
            handle Crypto.Err msg =>
                    Err (String.concat ["getSigningKey Error: ", msg])
        (* getEncryptionKey: unit -> bstring
         * Returns the CA's public encryption key.
         *)
        fun getEncryptionKey () =
            Ok (Crypto.generateEncryptionPublicKey encryptKey)
            handle Crypto.Err msg =>
                    Err (String.concat ["getEncryptionKey Error: ", msg])
        (* validateAlias: id_type -> bsting -> bstring -> bstring option
         * `validateAlias id nonce alias`
         * Signs the alias with the CA's private key. Then looks up the public
         * key associated `id`. If one is found, encrypts the signed alias with
         * that public key and nonce. Otherwise, returns `None`.
         *)
        fun validateAlias id nonce alias =
            let
                val sign = Crypto.signMsg signingKey alias
                val secreto =
                    Option.map
                        (fn pub => Crypto.generateDHSecret encryptKey pub)
                        (lookupPublicKey id)
            in
                Option.map
                    (fn secret => Crypto.encrypt secret nonce 0 sign)
                    secreto
            end
            handle Crypto.Err _ => None
    end
    (* dispatch: json -> json
     * Process a JSON value with a 'method' field. Performs the specified
     * method passing along with any additional arguments from the
     * 'arguments' field. Returns a JSON value with either a 'result' field
     * which contains the result of the method call, or an 'error' field
     * detailing the error that occurred.
     *)
    fun dispatch json =
        case (Option.mapPartial Json.toString (Json.lookup "method" json),
            Option.mapPartial Json.toList (Json.lookup "arguments" json)) of
          (None, _) => 
            Json.fromPairList
                [("error",
                Json.fromString "JSON error: 'method' field not found.")]
        | (Some "getSigningKey", _) =>
            (case getSigningKey () of
              Ok signKey =>
                Json.fromPairList
                    [("result",
                    Json.fromString (BString.show signKey))]
            | Err msg =>
                Json.fromPairList
                    [("error",
                    Json.fromString msg)])
        | (Some "getEncryptionKey", _) =>
            (case getEncryptionKey () of
              Ok encryptKey =>
                Json.fromPairList
                    [("result",
                    Json.fromString (BString.show encryptKey))]
            | Err msg =>
                Json.fromPairList
                    [("error",
                    Json.fromString msg)])
        | (Some "validateAlias", Some [idJson, nonceJson, aliasJson]) =>
            (let
                val ido = Option.map BString.unshow (Json.toString idJson)
                val nonceo = Option.map BString.unshow (Json.toString nonceJson)
                val aliaso = Option.map BString.unshow (Json.toString aliasJson)
            in
                case (ido, nonceo, aliaso) of
                  (None, _, _) => 
                    Json.fromPairList
                        [("error",
                        Json.fromString "ID argument is not a byte string.")]
                | (_, None, _) =>
                    Json.fromPairList
                        [("error",
                        Json.fromString "Nonce argument is not a byte string.")]
                | (_, _, None) =>
                    Json.fromPairList
                        [("error",
                        Json.fromString "Alias argument is not a byte string.")]
                | (Some id, Some nonce, Some alias) =>
                    OptionExtra.option
                        (Json.fromPairList
                            [("error", Json.fromString "id not found")])
                        (fn validatedAlias =>
                            Json.fromPairList
                                [("result", Json.fromString (BString.show validatedAlias))])
                        (validateAlias id nonce alias)
            end
            handle Word8Extra.InvalidHex =>
                    Json.fromPairList
                        [("error",
                        Json.fromString "One of the arguments to 'validateAlias' was not a byte string.")])
        | (Some "addPublicKey", Some [idJson, pubkeyJson]) =>
            (let
                val ido = Option.map BString.unshow (Json.toString idJson)
                val pubkeyo = Option.map BString.unshow (Json.toString pubkeyJson)
            in
                case (ido, pubkeyo) of
                  (None, _) =>
                    Json.fromPairList
                        [("error",
                        Json.fromString "ID argument is not a byte string.")]
                | (_, None) =>
                    Json.fromPairList
                        [("error",
                        Json.fromString "Public key argument is not a byte string.")]
                | (Some id, Some pubkey) =>
                    (addPublicKey id pubkey;
                    Json.fromPairList
                        [("result", Json.fromPairList [])])
            end
            handle Word8Extra.InvalidHex =>
                    Json.fromPairList
                        [("error",
                        Json.fromString "One of the arguments to 'addPublicKey' was not a byte string.")])
        | (Some "removePublicKey", Some [idJson]) =>
            (let
                val ido = Option.map BString.unshow (Json.toString idJson)
            in
                case ido of
                  None =>
                    Json.fromPairList
                        [("error",
                        Json.fromString "ID argument is not a byte string.")]
                | Some id =>
                    (removePublicKey id;
                    Json.fromPairList
                        [("result", Json.fromPairList [])])
            end
            handle Word8Extra.InvalidHex =>
                    Json.fromPairList
                        [("error",
                        Json.fromString "Argument to 'removePublicKey' was not a byte string.")])
        | (Some "updatePublicKey", Some [idJson, pubkeyJson]) =>
            (let
                val ido = Option.map BString.unshow (Json.toString idJson)
                val pubkeyo = Option.map BString.unshow (Json.toString pubkeyJson)
            in
                case (ido, pubkeyo) of
                  (None, _) =>
                    Json.fromPairList
                        [("error",
                        Json.fromString "ID argument is not a byte string.")]
                | (_, None) =>
                    Json.fromPairList
                        [("error",
                        Json.fromString "Public key argument is not a byte string.")]
                | (Some id, Some pubkey) =>
                    (updatePublicKey id pubkey;
                    Json.fromPairList
                        [("result", Json.fromPairList [])])
            end
            handle Word8Extra.InvalidHex =>
                    Json.fromPairList
                        [("error",
                        Json.fromString "One of the arguments to 'updatePublicKey' was not a byte string.")])
        | (_, _) =>
            Json.fromPairList
                [("error",
                Json.fromString "Unrecognized 'method' field or wrong number of arguments provided.")]
    (* handleIncoming: sockfd -> unit
        * Accepts a listening socket file descriptor, reads the JSON input from
        * it, and finally writes a JSON result to that file descriptor.
        *)
    fun handleIncoming listener =
        let
            val client = Socket.accept listener
        in
            (case (Json.parse (Socket.inputAll client)) of
                Ok json =>
                Socket.output client (Json.stringify (dispatch json))
            | Err errMsg => 
                Socket.output
                    client
                    (Json.stringify
                        (Json.fromPairList
                            [("error",
                            Json.fromString
                                (String.concat ["JSON parsing error: ", errMsg]))])));
            Socket.close client
        end
        handle Socket.Err s =>
                TextIO.print_err (String.concat ["Socket failure: ", s, "\n"])
            | Socket.InvalidFD =>
                TextIO.print_err "Invalid file descriptor.\n"

    (* startServer: int -> int -> unit
        * `startServer port queueLen`
        * Starts a server listening on `port` with a queue length of
        * `queueLen`.
        *)
    fun startServer port queueLen =
        loop handleIncoming (Socket.listen port queueLen)
        handle Socket.Err s =>
                TextIO.print_err (String.concat ["Socket failure on listener instantiation: ", s, "\n"])
            | Crypto.Err s =>
                TextIO.print_err (String.concat ["Crypto error: ", s, "\n"])
            | _ =>
                TextIO.print_err "Fatal unkonwn error.\n"
end

(* main : unit -> unit
 * Run the server from the command line.
 *)
fun main () =
    let
        val name = CommandLine.name ()
        val usage =
            String.concat ["Usage: ", name, " port queueLength\n",
                "e.g. ", name, " 5001 5\n"]
    in
        case CommandLine.arguments () of
          [portStr, queueStr] =>
            (case (Int.fromString portStr, Int.fromString queueStr) of
              (Some port, Some queueLen) =>
                CA.startServer port queueLen
            | (_, _) => TextIO.print_err usage)
        | _ => TextIO.print_err usage
    end

val _ = main ()
