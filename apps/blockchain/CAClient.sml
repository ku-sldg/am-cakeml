structure CAClient =
struct
    val id = BString.unshow "01"
    (* Client's private encyrption key*)
    val privateKey =
        BString.unshow "EAE543E1122591D6535A34D279C2147E2BB6B5D636D95F02214C973772F41E62"
    (* Client's aliased private encryption key *)
    val aliasPrivateKey =
        BString.unshow "D8409AFBF2B9862E14F2C628967D80231860A140CFB1E924015103E4C9A3579E"

    (* sendToCA: int -> json -> (json, string) result
     * `sendToCA port inJson`
     * Sends `inJson` request to CA on localhost, port number `port` and
     * receives the json response, or produces an error message.
     *)
    fun sendToCA port inJson =
        let
            val server = Socket.connect "127.0.0.1" port
            val _ = Socket.output server (Json.stringify inJson)
            val output = Socket.inputAll server
            val _ = Socket.close server
        in
            Json.parse output
        end
        handle Socket.Err s => 
                Err (String.concat ["Socket error: ", s])
            | Socket.InvalidFD =>
                Err "Invalid file descriptor."

    (* addPublicKey: int -> (unit, string) result
     * `addPublicKey port`
     * Sends a request to the CA to add this client's `id` and public key. The
     * CA should be listening in on the localhost at port number `port`.
     *)
    fun addPublicKey port =
        let
            val pubKey = Crypto.generateEncryptionPublicKey privateKey
            val outJson =
                Json.fromPairList
                    [("method", Json.fromString "addPublicKey"),
                    ("arguments",
                        Json.fromList [Json.fromString (BString.show id),
                                        Json.fromString (BString.show pubKey)])]
        in
            case sendToCA port outJson of
              Err msg =>
                Err (String.concat ["Error adding public key: ", msg])
            | Ok return =>
                case Json.lookup "result" return of
                  None =>
                    Err (String.concat
                          ["Error getting result from adding public key.\n",
                            Json.stringify return])
                | Some result => Ok ()
        end
        handle Crypto.Err msg =>
                Err (String.concat ["addPublicKey error: ", msg])

    (* getCASigningKey: int -> (bstring, string) result
     * `getCASigningKey port`
     * Sends a request to the CA to receive its public signing key. The CA
     * should be listening in on the localhost at port number `port`.
     *)
    fun getCASigningKey port =
        let
            val outJson =
                Json.fromPairList
                    [("method", Json.fromString "getSigningKey"),
                    ("arguments", Json.fromList [])]
            fun getResult x =
                Option.map BString.unshow
                    (Option.mapPartial
                        Json.toString
                        (Json.lookup "result" x))
        in
            case sendToCA port outJson of
              Err msg =>
                Err (String.concat ["Error getting CA's signing key: ", msg])
            | Ok return =>
                case getResult return of
                  None =>
                    Err (String.concat
                            ["Error getting CA's signing key: invalid result received\n",
                            Json.stringify return])
                | Some signKey => Ok signKey
        end
        handle Word8Extra.InvalidHex =>
                Err "Error getting CA's public signing key: invalid public key received."

    (* getCAEncryptionKey: int -> (bstring, string) result
     * `getCAEncryptionKey port`
     * Sends a request to the CA to receive its public encryption key. The CA
     * should be listening in on the localhost at port number `port`.
     *)
    fun getCAEncryptionKey port =
        let
            val outJson =
                Json.fromPairList
                    [("method", Json.fromString "getEncryptionKey"),
                    ("arguments", Json.fromList [])]
            fun getResult x =
                Option.map BString.unshow
                    (Option.mapPartial
                        Json.toString
                        (Json.lookup "result" x))
        in
            case sendToCA port outJson of
              Err msg =>
                Err (String.concat ["Error getting CA's encryption key: ", msg])
            | Ok return =>
                case getResult return of
                  None =>
                    Err (String.concat
                            ["Error getting CA's encryption key: invalid result received\n",
                            Json.stringify return])
                | Some encryptKey => Ok encryptKey
        end
        handle Word8Extra.InvalidHex =>
                Err "Error getting CA's public encryption key: invalid public key received."

    (* validateAlias: int -> bstring -> bstring -> bstring -> (bstring, string) result
     * `validateAlias port nonce aliasPubKey caEncryptKey`
     * Sends the request to the CA to validate the given alias' public key. The
     * CA should be listening on the localhost, port number `port`. `nonce`
     * should be a length 12 bytestring. `caEncryptKey` is the CA's public
     * encryption key needed for ECDH to generate the common secret.
     *)
    fun validateAlias port nonce aliasPubKey caEncryptKey =
        let
            val outJson =
                Json.fromPairList
                    [("method", Json.fromString "validateAlias"),
                    ("arguments",
                        Json.fromList 
                            [Json.fromString (BString.show id),
                            Json.fromString (BString.show nonce),
                            Json.fromString (BString.show aliasPubKey)])]
            fun getResult x =
                Option.map BString.unshow
                    (Option.mapPartial
                        (Json.toString)
                        (Json.lookup "result" x))
            val encryptedSignedKey =
                case sendToCA port outJson of
                  Err msg =>
                    Err (String.concat ["Error validating alias:\n", msg])
                | Ok return =>
                    case getResult return of
                      None =>
                        Err (String.concat
                                ["Error getting result from validating public key.\n",
                                Json.stringify return])
                    | Some result => Ok result
            val secret = Crypto.generateDHSecret privateKey caEncryptKey
        in
            Result.bind encryptedSignedKey
                (fn bs => Ok (Crypto.decrypt secret nonce 0 bs))
        end
        handle Crypto.Err m =>
                Err (String.concat ["Error validating alias: ", m])
            | Word8Extra.InvalidHex =>
                Err "Error validating alias: invalid byte string received."

    (* demo: int -> unit
     * `demo port`
     * With the CA listening on the localhost at port number `port`:
     * 1. Adds the clients id and public key to the CA.
     * 2. Gets the CA's public encryption key.
     * 3. Validates an alias public key with the CA.
     * 4. Gets the CA's public signature key.
     * 5. Checks the signature on the alias public key received from the CA.
     * 6. Prints the results (or errors) to the console.
     *)
    fun demo port =
        let
            val unitr = addPublicKey port
            val caEncryptr = Result.bind unitr (fn _ => getCAEncryptionKey port)
            val aliasPublicKey =
                Crypto.generateEncryptionPublicKey aliasPrivateKey
            val nonce = BString.nulls 12
            val signr =
                Result.bind caEncryptr
                    (fn caEncrypt =>
                        validateAlias port nonce aliasPublicKey caEncrypt)
            val resultr =
                Result.bind signr
                    (fn signat =>
                        Result.map
                            (fn key => (signat, key))
                            (getCASigningKey port))
        in
            case resultr of
              Ok (signat, key) =>
                TextIO.print_list ["alias: ", BString.show aliasPublicKey, "\n",
                    "signature: ", BString.show signat, "\n",
                    "Signature check: ",
                    Bool.toString (Crypto.sigCheck key signat aliasPublicKey),
                    "\n"]
            | Err msg =>
                TextIO.print_err (String.concat ["demo error: ", msg, "\n"])
        end
        handle Crypto.Err msg =>
                TextIO.print_err (String.concat ["demo error: ", msg, "\n"])
end

(* main: unit -> unit
 * Runs the client demo on the command line.
 *)
fun main () =
    let
        val name = CommandLine.name ()
        val usage =
            String.concat ["Usage: ", name, " port\ne.g. ", name, " 5001\n"]
    in
        case CommandLine.arguments () of
          [portStr] =>
            (case Int.fromString portStr of
              Some port => CAClient.demo port
            | None => print usage)
        | _ => print usage
    end

val _ = main ()
