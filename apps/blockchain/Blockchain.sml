(* Dependencies:
 * ../../util/Bytestring.sml, ../../util/Http.sml
 *   ../../util/Extra.sml
 * ../../util/Json.sml
 * ../../system/posix/sockets/SocketFFI.sml
 * ../../util/Misc.sml
 *)
structure Blockchain =
struct
(***************** [JSON RPC](https://eth.wiki/json-rpc/API) *****************)
    (* formJsonRpc : int -> string -> Json.json list -> Json.json
     * Creates an Ethereum (geth client) JSON RPC call with ID number `id`,
     * using method `method`, with parameters `params`.
     *)
    fun formJsonRpc id method params =
        Json.fromPairList [("jsonrpc", Json.fromString "2.0"),
            ("id", Json.fromInt id),
            ("method", Json.fromString method),
            ("params", Json.fromList params)]

    (* eth_call
     * Inputs:
     *    1) Object
     *       "from" (optional)
     *          Data, 20 bytes
     *          address from which transaction was sent
     *       "to"
     *          Data, 20 bytes
     *          address to which the transaction is directed
     *       "gas" (optional)
     *          Quantity
     *          Integer of gas provided for the transaction
     *       "gasPrice" (optional)
     *          Quantity
     *          Integer of price per gas paid
     *       "value" (optional)
     *          Quantity
     *          Integer of value sent with transaction
     *       "data" (optional)
     *          Data
     *          Hash of method signature and parameters.
     *    2) Quantity | "latest" | "earliest" | "pending"
     *         An integer block number
     *       | "latest" latest mined block
     *       | "earliest" earliest/genesis block
     *       | "pending" pending state/transaction
     * Outputs:
     *    Data
     *    Return value of the executed contract
     *)
    (* formEthCallGeneric : int -> string -> string -> string -> Json.json -> Json.json
     * Creates an Ethereum (geth) JSON `eth_call` with ID number `id`, from the
     * address `from`, to the address `to`, with data `data`, and using the
     * quantity/tag `quantTag`.
     *)
    fun formEthCallGeneric id from to data quantTag =
        let
            val object =
                Json.fromPairList [("from", Json.fromString from),
                                ("to", Json.fromString to),
                                ("data", Json.fromString data)]
        in
            formJsonRpc id "eth_call" [object, quantTag]
        end

    (* formEthCallLatest : int -> string -> string -> string -> Json.json
     * Creates an Ethereum (geth) JSON `eth_call` with ID number `id`, from the
     * address `from`, to the address `to`, with data `data`, and using the
     * "latest" tag.
     *)
    fun formEthCallLatest id from to data =
        formEthCallGeneric id from to data (Json.fromString "latest")

    (* eth_sendTransaction
     * Inputs:
     *    1) Object
     *       "from"
     *          Data 20 bytes
     *          Address from which transaction was sent
     *       "to"
     *          Data 20 bytes
     *          Address to where transaction is sent
     *       "gas" (optional)
     *          Quantity
     *          Integer of the gas alotted for transaction execution. Returns
     *          unsused portion.
     *       "gasPrice" (optional)
     *          Quantity
     *          Integer of price paid per gas
     *       "value" (optional)
     *          Quantity
     *          Integer of value sent with transaction
     *       "data"
     *          Data
     *          Compiled code of a contract or hashed method signature and
     *          encoded parameters
     *       "nonce" (optional)
     *          Quantity
     *          Integer nonce which allows one to overwrite one's own pending
     *          transaction
     * Outputs:
     *    Data 32 bytes
     *    The transaction hash after transaction was mined or the zero hash if
     *    the transaction is not yet available.
     *)
    (* formEthSendTransaction : int -> string -> string -> string -> Json.json
     * Creates an Ethereum (geth) JSON `eth_sendTransaction` with ID number
     * `id`, from the address `from`, to the address `to`, and with data `data`.
     *)
    fun formEthSendTransaction id from to data =
        let
            val object =
                Json.fromPairList [("from", Json.fromString from),
                                ("to", Json.fromString to),
                                ("data", Json.fromString data)]
        in
            formJsonRpc id "eth_sendTransaction" [object]
        end

(*** [ABI Encoding](https://docs.soliditylang.org/en/develop/abi-spec.html) ***)
    (* encodeInt : int -> (string, string) result
     * Transforms a ML integer into Ethereum JSON ABI int256. Returns an error
     * message if given integer is negative.
     *)
    fun encodeInt n =
        if n >= 0
        then Ok (BString.show (BString.fromIntLength 32 BString.BigEndian n))
        else Err "Blockchain.encodeInt: Can only encode non-negative integers"

    (* encodeBytes: BString.bstring -> string
     * Transforms a `BString.bstring` into an Ethereum JSON ABI bytes encoding.
     *)
    fun encodeBytes bs =
        let
            val bsLen = BString.length bs
            val offset = bsLen mod 32
            val suffix =
                if offset = 0
                then ""
                else BString.show (BString.nulls (32 - offset))
        in
            String.concat [Result.okValOf (encodeInt bsLen), BString.show bs,
                    suffix]
        end

    (* decodeInt: int BinaryParser.parser
     * Transforms an Ethereum JSON ABI uint(256) into a CakeML integer.
     *)
    fun decodeInt stream =
        BinaryParser.fixedInt 32 BString.BigEndian stream
    (* (* decodeInt : string -> (int, string) result
     * Transforms an Ethereum JSON ABI uint256 into an ML integer.
     * 
     * Returns an error when the encoding does not start with `"0x"`, does not
     * represent 32 bytes, or cannot be parsed by `BString.unshow`.
     *)
    fun decodeInt enc = 
        if String.size enc = 66 andalso String.substring enc 0 2 = "0x"
        then Ok (BString.toInt
                BString.BigEndian
                (BString.unshow (String.substring enc 2 64)))
            handle Word8Extra.InvalidHex =>
                Err "Blockchain.decodeInt: Error from BString.unshow caught."
        else Err "Blockchain.decodeInt: Hex string either did not start with \"0x\" or did not represent 32 bytes." *)

    (* decodeBytes: BString.bstring BinaryParser.parser
     * Transforms an arbitrary length Ethereum byte string into a
     * BString.bstring.
     *)
    fun decodeBytes stream =
        let
            fun mainParser m = 
                BinaryParser.bind
                    (BinaryParser.any m)
                    (fn bs =>
                        BinaryParser.return bs (BinaryParser.endingNulls 32))
        in
            BinaryParser.bind
                decodeInt
                (fn m =>
                    if m = 32
                    then BinaryParser.choice [
                            BinaryParser.bind decodeInt (fn n => mainParser n),
                            mainParser 32]
                    else mainParser m)
                stream
        end
    (* (* decodeBytes : string -> (BString.bstring, string) result
     * Transforms an Ethereum JSON ABI encoded string into a ML string.
     *
     * Returns an error when the encoding does not start with `"0x"`, is too
     * short, or `BString.unshow` throws an exception.
     *)
    fun decodeBytes enc =
        if String.size enc < 130 andalso String.substring enc 0 2 <> "0x"
        then Err "Blockchain.decodeBytes: Byte string either did not start with \"0x\" or was not long enough."
        else
            let
                val first = BString.toInt
                        BString.BigEndian
                        (BString.unshow (String.substring enc 2 64))
                val second = BString.unshow (String.substring enc 66 64)
                val rest = BString.unshow (String.extract enc 130 None)
                val restLen = BString.length rest
            in
                if first = 32 andalso
                    BString.toInt BString.BigEndian second = restLen
                then Ok rest
                else if first = 64 + restLen
                    then Ok (BString.concat second rest)
                    else Err "Blockchain.decodeBytes: Byte string is not properly encoded."
            end
            handle Word8Extra.InvalidHex =>
                Err "Blockchain.decodeBytes: Error from BString.unshow caught." *)

    (* encodeIntBytes: int -> BString.bstring -> (string, string) result
     * Transforms a tuple of type `(int, BString.bstring)` into an Ethereum
     * JSON ABI encoded `(uint256, bytes)`.
     *
     * This tuple is encoded as a concatenation of bytestring encodings: the
     * encoding of the integer, encoding the size of two integers in bytes (64),
     * and encoding the bytestring.
     *
     * Returns an error if given integer is negative.
     *)
    fun encodeIntBytes n bs =
        let
            val encIntr = encodeInt n
            val widthEnc = Result.okValOf (encodeInt 64) (* 2 * 32 *)
            val encBytes = encodeBytes bs
        in
            case encIntr of
              Ok encInt => Ok (String.concat [encInt, widthEnc, encBytes])
            | Err _ =>
                Err "Blockchain.encodeIntBytes: Can only encode non-negative integers."
        end
        
    (* encodeAddress: string -> (string, string) result
     * Transforms an Ethereum address (20 bytes) into its Ethereum JSON ABI
     * format (32 bytes, zero-padded on the left/high-end)
     *)
    fun encodeAddress str =
        (* We're converting to and from a `BString.bstring` in order to check
         * that the argument is a hexadecimal string. We'd rather get an error
         * from the program than get an error from the blockchain.
         *)
        if String.size str = 42 andalso String.substring str 0 2 = "0x"
        then
            let
                val bs = BString.unshow (String.extract str 2 None)
            in
                Ok (BString.show (BString.concat (BString.nulls 12) bs))
            end
            handle Word8Extra.InvalidHex =>
                Err "Blockchain.encodeAddress: Error from BString.unshow caught."
        else Err "Blockchain.encodeAddress: Tried to encode an invalid address."

(******************* Communicating with the Smart Contract *******************)
    (* sendRequest: string -> string -> (string -> Json.json) -> string -> string ->
     *   (Http.Response, string) result
     * `sendRequest funSig funParams formEthFunc host port`
     * Builds and sends a HTTP request to `host:port` where the body of the
     * request is built using the expression
     * `Json.stringify (formEthFunc (funSig ^ funParams))`. Returns the
     * HTTP response upon success, and an error message otherwise. This
     * along with `processResponse` are the main workhorses of the API calls
     * that communicate with the blockchain.
     *)
    fun sendRequest funSig funParams formEthFunc host port =
        let
            val data = String.concat [funSig, funParams]
            val jsonMsg = formEthFunc data
            val jsonStr = Json.stringify jsonMsg
            val hostPair =
                ("Host", String.concatWith ":" [host, Int.toString port])
            val contentType = ("Content-Type", "application/json")
            val contentLen =
                ("Content-Length", Int.toString (String.size jsonStr))
            val httpReq =
                Http.Request "POST" "/" "HTTP/1.1"
                    [hostPair, contentType, contentLen]
                    (Some jsonStr)
            val httpReqStr = Http.requestToString httpReq
            val socket = Socket.connect host port
            val _ = Socket.output socket httpReqStr
            val httpRespr = Http.responseFromString (Socket.inputAll socket)
            val _ = Socket.close socket
        in
            httpRespr
        end
    (* processResponse: Http.Response -> int -> (string -> ('a, string) result) ->
     *   string -> ('a, string) result
     * `processResponse httpResp jsonId func errMsgHeader`
     * Parses the HTTP response `httpResp` and pulls out the JSON value.
     * Checks the JSON "id" field matches `jsonId`, and applies the function
     * `func` to the JSON "result" field. Prepends `errMsgHeader` and any
     * error message that is returned. This along with `sendRequest` are the
     * main workhorses of the API calls that communicate with the blockchain.
     *)
    fun processResponse (Http.Response _ _ _ _ message) jsonId func errMsgHeader =
        let
            val jsonResp = Result.okValOf (Json.parse message)
            val respId =
                Option.getOpt
                    (Option.mapPartial
                        Json.toInt
                        (Json.lookup "id" jsonResp))
                    ~1
        in
            if jsonId = respId andalso jsonId >= 0
            then
                case (Option.mapPartial Json.toString (Json.lookup "result" jsonResp)) of
                  Some result => func result
                | None =>
                    Err (String.concat [errMsgHeader,
                                    ": JSON result field was either not found or not a string.\n",
                                    Json.stringify jsonResp])
            else Err (String.concat [errMsgHeader,
                                    ": JSON ids didn't match.\n",
                                    Json.stringify jsonResp])
        end
        handle Result.Exn =>
            Err (String.concat [errMsgHeader, ": JSON did not parse.\n",
                            message])

    (* getHash: string -> int -> int -> string -> string -> int -> (BString.bstring, string) result
        * `getHash host port jsonId recipient sender hashId`
        *
        * Queries Ethereum client located at host `host` and port number
        * `port`, calling the `getHash` method of our smart contract, located
        * at `recipient`, from `sender`, using the parameter `hashId`. The
        * `jsonId` parameter is an arbitrary integer used to identify the
        * response to this particular request. Both `recipient` and `sender`
        * must be hexademical strings prefixed with `0x` and represent 20
        * bytes.
        *)
    fun getHash host port jsonId recipient sender hashId =
        case (encodeInt hashId) of
          Err msg =>
            Err (String.concat ["Blockchain.getHash: id of the hash failed to encode.\n",
                            msg])
        | Ok hashIdEnc =>
            let
                val funSig = "0x6b2fafa9"
                fun formEthFunc data =
                    formEthCallLatest jsonId sender recipient data
                val decoder = BinaryParser.parseWithPrefix decodeBytes "0x"
            in
                case (sendRequest funSig hashIdEnc formEthFunc host port) of
                  Ok resp =>
                    processResponse resp jsonId decoder "Blockchain.getHash"
                | Err msg =>
                    Err (String.concat ["Blockchain.getHash: failed to parse HTTP response.\n", msg, "\n"])
            end
            handle Socket.Err msg =>
                  Err (String.concat ["Blockchain.getHash, socket error: ",
                                    msg])
                | Socket.InvalidFD =>
                    Err "Blockchain.getHash, socket error: invalid file descriptor."
                | _ => Err "Blockchain.getHash: unknown error."
    
    (* setHash: string -> int -> int -> string -> string -> int -> BString.bstring -> (BString.bstring, string) result
        * `setHash host port jsonId recipient sender hashId hashValue`
        *
        * Queries Ethereum client located at host `host` and port number
        * `port`, calling the `setHash` method of our smart contract, located
        * at `recipient`, from `sender`, using the parameters `hashId` and
        * `hashValue`. The `jsonId` parameter is an arbitrary integer used to
        * identify the response to this particular request. Both `recipient`
        * and `sender` must be hexadecimal strings prefixed with `0x` and
        * represent 20 bytes. The transaction hash is returned.
        *)
    fun setHash host port jsonId recipient sender hashId hashValue =
        case (encodeIntBytes hashId hashValue) of
          Err msg =>
            Err (String.concat ["Blockchain.setHash: id of the hash failed to encode.\n",
                            msg])
        | Ok paramEnc =>
            let
                val funSig = "0x6a7fd925"
                fun formEthFunc data =
                    formEthSendTransaction jsonId sender recipient data
                fun respFunc result =
                    Ok (BString.unshow (String.extract result 2 None))
                    handle Word8Extra.InvalidHex =>
                        Err "Blockchain.setHash: Error from BString.unshow caught"
            in
                case (sendRequest funSig paramEnc formEthFunc host port) of
                  Ok resp =>
                    processResponse resp jsonId respFunc "Blockchain.setHash"
                | Err msg =>
                    Err (String.concat ["Blockchain.setHash: failed to parse HTTP response.\n", msg, "\n"])
            end
            handle Socket.Err msg =>
                  Err (String.concat ["Blockchain.setHash, socket error: ",
                                    msg])
                | Socket.InvalidFD =>
                    Err "Blockchain.setHash, socket error: invalid file descriptor."
                | _ => Err "Blockchain.setHash: unknown error."
    
    (* addAuthorizedUser: string -> int -> int -> string -> string -> string -> (BString.bstring, string) result
        * `addAuthorizedUser host port jsonId recipient sender address`
        *
        * Queries Ethereum client located at host `host` and port number
        * `port`, calling the `addAuthorizedUser` method of our smart contract,
        * located at `recipient`, from `sender`, using the parameter `address`.
        * The  `jsonId` parameter is an arbitrary integer used to identify the
        * response to this particular request. All three `recipient`, `sender`,
        * and `address` need to be hexadecimal strings prefixed by `0x` and
        * representing 20 bytes. The transaction hash is returned.
        *)
    fun addAuthorizedUser host port jsonId recipient sender address =
        case (encodeAddress address) of
          Err msg =>
            Err (String.concat ["Blockchain.addAuthorizedUser: user's address failed to encode.\n",
                            msg])
        | Ok addEnc =>
            let
                val funSig = "0x177d2a74"
                fun formEthFunc data =
                    formEthSendTransaction jsonId sender recipient data
                fun respFunc result =
                    Ok (BString.unshow (String.extract result 2 None))
                    handle Word8Extra.InvalidHex =>
                        Err "Blockchain.addAuthorizedUser: Error from BString.unshow caught."
            in
                case (sendRequest funSig addEnc formEthFunc host port) of
                    Ok resp =>
                    processResponse resp jsonId respFunc "Blockchain.addAuthorizedUser"
                | Err msg =>
                    Err (String.concat ["Blockchain.addAuthorizedUser: failed to parse HTTP response.\n", msg, "\n"])
            end
            handle Socket.Err msg =>
                    Err (String.concat ["Blockchain.addAuthorizedUser, socket error: ",
                                    msg])
                | Socket.InvalidFD =>
                    Err "Blockchain.addAuthorizedUser, socket error: invalid file descriptor."
                | _ => Err "Blockchain.addAuthorizedUser: unknown error."
    
    (* removeAuthorizedUser: string -> int -> int -> string -> string -> string -> (BString.bstring, string) result
        * `removeAuthorizedUser host port jsonId recipient sender address`
        *
        * Queries Ethereum client located at host `host` and port number
        * `port`, calling the `removeAuthorizedUser` method of our smart
        * contract, located at `recipient`, from `sender`, using the parameter
        * `address`. The `jsonId` parameter is an arbitrary integer used to
        * identify the response to this particular request. All three
        * `recipient`, `sender`, `address` need to be hexadecimal strings
        * prefixed by `0x` and representing 20 bytes. The transaction hash is
        * returned.
        *)
    fun removeAuthorizedUser host port jsonId recipient sender address =
        case (encodeAddress address) of
          Err msg =>
            Err (String.concat ["Blockchain.removeAuthorizedUser: user's address failed to encode.\n",
                            msg])
        | Ok addEnc =>
            let
                val funSig = "0x89fabc80"
                fun formEthFunc data =
                    formEthSendTransaction jsonId sender recipient data
                fun respFunc result =
                    Ok (BString.unshow (String.extract result 2 None))
                    handle Word8Extra.InvalidHex =>
                        Err "Blockchain.removeAuthorizedUser: Error from BString.unshow caught"
            in
                case (sendRequest funSig addEnc formEthFunc host port) of
                  Ok resp =>
                    processResponse resp jsonId respFunc "Blockchain.removeAuthorizedUser"
                | Err msg =>
                    Err (String.concat ["Blockchain.removeAuthorizedUser: failed to parse HTTP response.\n", msg, "\n"])
            end
            handle Socket.Err msg =>
                  Err (String.concat ["Blockchain.removeAuthorizedUser, socket error: ",
                                    msg])
                | Socket.InvalidFD =>
                    Err "Blockchain.removeAuthorizedUser, socket error: invalid file descriptor."
                | _ => Err "Blockchain.removeAuthorizedUser: unknown error."
end

(* testing code
fun main () =
    let
        val sender = "0x55500e2c661b9b703421b92d15e15d292a9df669"
        val arg1 = Option.map fst (List.getItem (CommandLine.arguments ()))
        val arg = Option.valOf arg1
        val hashValue = BString.unshow "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f"
        val user = "0x000102030405060708090a0b0c0d0e0f10111213"
        val delUserBs = Option.valOf (Blockchain.removeAuthorizedUser "127.0.0.1" 8543 4 arg sender user)
        val addUserBs = Option.valOf (Blockchain.addAuthorizedUser "127.0.0.1" 8543 3 arg sender user)
        val setHashBs = Option.valOf (Blockchain.setHash "127.0.0.1" 8543 1 arg sender 1 hashValue)
        val getHashBs = Option.valOf (Blockchain.getHash "127.0.0.1" 8543 2 arg user 1)
    in
        case arg1 of
          Some arg => ()
        | None =>
            TextIO.print_err (String.concat ["usage: ", CommandLine.name (), " <dest addr>\n"])
    end

val _ = main ()
 *)
