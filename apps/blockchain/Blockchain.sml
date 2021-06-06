(* Dependencies:
 * ../../util/Bytestring.sml, ../../util/Http.sml
 *   ../../util/Extra.sml
 * ../../util/Json.sml
 * ../../system/posix/sockets/SocketFFI.sml
 *)
(* TODO: Forgot to prefix the function signature hash to JSON RPC ABI data. *)

exception EthereumExn string

(***************** [JSON RPC](https://eth.wiki/json-rpc/API) *****************)
(* formJsonRpc : int -> string -> Json.json list -> Json.json
 * Creates an Ethereum (geth client) JSON RPC call with ID number `id`, using
 * method `method`, with parameters `params`.
 *)
fun formJsonRpc id method params =
    Json.AList [("jsonrpc", Json.String "2.0"),
           ("id", Json.Number (Json.Int id)),
           ("method", Json.String method),
           ("params", Json.List params)]

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
        val object = Json.AList [("from", Json.String from),
                            ("to", Json.String to),
                            ("data", Json.String data)]
    in
        formJsonRpc id "eth_call" [object, quantTag]
    end

(* formEthCallLatest : int -> string -> string -> string -> Json.json
 * Creates an Ethereum (geth) JSON `eth_call` with ID number `id`, from the
 * address `from`, to the address `to`, with data `data`, and using the "latest"
 * tag.
 *)
fun formEthCallLatest id from to data =
    formEthCallGeneric id from to data (Json.String "latest")

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
 *    The transaction hash after transaction was mined or the zero hash if the
 *    transaction is not yet available.
 *)
(* formEthSendTransaction : int -> string -> string -> string -> Json.json
 * Creates an Ethereum (geth) JSON `eth_sendTransaction` with ID number `id`,
 * from the address `from`, to the address `to`, and with data `data`.
 *)
fun formEthSendTransaction id from to data =
    let
        val object = Json.AList [("from", Json.String from),
                            ("to", Json.String to),
                            ("data", Json.String data)]
    in
        formJsonRpc id "eth_sendTransaction" [object]
    end

(* formJsonPostReq: string -> string -> string
 * Onto a message/string, adds a minimal HTTP POST request header.
 *)
fun formJsonPostReq hostStr str =
    let
        val crlf = String.concat (List.map (String.str o Char.chr) [13, 10])
    in
        String.concatWith crlf [
            "POST / HTTP/1.1",
            String.concat ["Host: ", hostStr],
            "User-Agent: curl/7.68.0",
            "Accept: */*",
            "Content-Type: application/json",
            String.concat ["Content-Length: ", Int.toString (String.size str)],
            "", str
            ]
    end

(*** [ABI Encoding](https://docs.soliditylang.org/en/develop/abi-spec.html) ***)
(* encodeInt : int -> string
 * Transforms a ML integer into Ethereum JSON ABI int256.
 *)
fun encodeInt n =
    if n >= 0
    then BString.show (BString.fromIntLength 32 BString.BigEndian n)
    else raise EthereumExn "Can only encode non-negative integers"

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
        String.concat [encodeInt bsLen, BString.show bs, suffix]
    end

(* decodeInt : string -> int
 * Transforms an Ethereum JSON ABI uint256 into an ML integer.
 * 
 * Raises a `Word8Extra.InvalidHex` exception when `BString.unshow` cannot
 * parse the input. Raises `EthereumExn` when the encoding does not start
 * with `"0x"`. Raises an exception through String.substring if input is too
 * short.
 *)
fun decodeInt enc =
    if String.substring enc 0 2 = "0x"
    then BString.toInt
            BString.BigEndian
            (BString.unshow (String.substring enc 2 64))
    else raise EthereumExn "Hex string did not start with \"0x\"."

(* decodeBytes : string -> BString.bstring
 * Transforms an Ethereum JSON ABI encoded string into a ML string
 *
 * Raises `EthereumExn` when the encoding does not start with `"0x"`. Raises
 * a `Word8Extra.InvalidHex` exception if length or data parameters cannot be
 * parsed from the input. Raises an exception through `BString.substring` if
 * the length parameter is too short.
 *)
fun decodeBytes enc =
    let
        val length = decodeInt (String.substring enc 0 66)
    in
        BString.unshow (String.substring enc 66 (2 * length))
    end

(* encodeIntBytes: int -> BString.bstring -> string
 * Transforms a tuple of type `(int, BString.bstring)` into an Ethereum
 * JSON ABI encoded `(uint256, bytes)`.
 *
 * This tuple is encoded as a concatenation of bytestring encodings: the
 * encoding of the integer, encoding the size of the integer in bytes (32),
 * and encoding the bytestring.
 *)
fun encodeIntBytes n bs =
    let
        val encInt = encodeInt n
        val widthEnc = encodeInt 32
        val encBytes = encodeBytes bs
    in
        String.concat [encInt, widthEnc, encBytes]
    end
    
(* encodeAddress: BString.bstring -> string
 * Transforms an Ethereum address (20 bytes) into its Ethereum JSON ABI
 * format (32 bytes, zero-padded on the left/high-end)
 *)
fun encodeAddress bs =
    BString.show (BString.concat (BString.nulls 12) bs)

(******************* Communicating with the Smart Contract *******************)
local
    (* Unlocked blockchain user *)
    val sender = "0x55500e2c661b9b703421b92d15e15d292a9df669"
    (* processResponse: Http.Response -> int -> (string -> 'a) -> 'a option  *)
    fun processResponse (Http.Response _ _ _ _ message) jsonId func =
        let
            val jsonResp = List.hd (fst (Json.parse ([], message)))
            val respId = Option.getOpt (Option.mapPartial Json.toInt (Json.lookup "id" jsonResp)) ~1
        in
            if jsonId = respId
            then Option.mapPartial
                    func
                    (Option.mapPartial
                        Json.toString
                        (Json.lookup "result" jsonResp))
            else None
        end
in
    (* getHash: string -> int -> int -> string -> int -> BString.bstring option
     * `getHash host port jsonId recipient hashId`
     *
     * Queries Ethereum client located at host `host` and port number `port`,
     * calling the `getHash` method of our smart contract, located at
     * `recipient`, using the parameter `hashId`. The `jsonId` parameter is an
     * arbitrary integer used to identify the response to this particular
     * request.
     *)
    fun getHash host port jsonId recipient hashId =
        let
            val funSig = "0x6b2fafa9"
            val data = String.concat [funSig, encodeInt hashId]
            val jsonMsg = formEthCallLatest jsonId sender recipient data
            val hostPair = ("Host", String.concatWith ":" [host, Int.toString port])
            val contentType = ("Content-Type", "application/json")
            val httpReq = Http.Request "POST" "/" "HTTP/1.1"
                            [hostPair, contentType]
                            (Some (Json.convertToString jsonMsg))
            val httpStr = Http.requestToString httpReq
            val socket = Socket.connect host port
            val _ = Socket.output socket httpStr
            val httpRespo = Http.responseFromString (Socket.inputAll socket)
            val _ = Socket.close socket
            fun respFunc result = Some (decodeBytes result)
        in
            Option.mapPartial
                (fn resp => processResponse resp jsonId respFunc)
                httpRespo
        end
    
    (* setHash: string -> int -> int -> string -> int -> BString.bstring option
     * `setHash host port jsonId recipient hashId hashValue`
     *
     * Queries Ethereum client located at host `host` and port number `port`,
     * calling the `setHash` method of our smart contract, located at
     * `recipient`, using the parameters `hashId` and `hashValue`. The `jsonId`
     * parameter is an arbitrary integer used to identify the response to this
     * particular request.
     *)
    fun setHash host port jsonId recipient hashId hashValue =
        let
            val funSig = "0x6a7fd925"
            val data = String.concat [funSig, encodeIntBytes hashId hashValue]
            val jsonMsg = formEthSendTransaction jsonId sender recipient data
            val hostPair = ("Host", String.concatWith ":" [host, Int.toString port])
            val contentType = ("Content-Type", "application/json")
            val httpReq = Http.Request "POST" "/" "HTTP/1.1"
                            [hostPair, contentType]
                            (Some (Json.convertToString jsonMsg))
            val httpStr = Http.requestToString httpReq
            val socket = Socket.connect host port
            val _ = Socket.output socket httpStr
            val httpRespo = Http.responseFromString (Socket.inputAll socket)
            val _ = Socket.close socket
            fun respFunc result =
                Some (BString.unshow (String.extract result 2 None))
        in
            Option.mapPartial
                (fn resp => processResponse resp jsonId respFunc)
                httpRespo
        end
    
    (* addAuthorizedUser: string -> int -> int -> string -> BString.bstring option
     * `addAuthorizedUser host port jsonId recipient address`
     *
     * Queries Ethereum client located at host `host` and port number `port`,
     * calling the `addAuthorizedUser` method of our smart contract, located at
     * `recipient`, using the parameter `address`. The `jsonId` parameter is an
     * arbitrary integer used to identify the response to this particular
     * request.
     *)
    fun addAuthorizedUser host port jsonId recipient address =
        let
            val funSig = "0x177d2a74"
            val data = String.concat [funSig, encodeAddress address]
            val jsonMsg = formEthSendTransaction jsonId sender recipient data
            val hostPair = ("Host", String.concatWith ":" [host, Int.toString port])
            val contentType = ("Content-Type", "application/json")
            val httpReq = Http.Request "POST" "/" "HTTP/1.1"
                            [hostPair, contentType]
                            (Some (Json.convertToString jsonMsg))
            val httpStr = Http.requestToString httpReq
            val socket = Socket.connect host port
            val _ = Socket.output socket httpStr
            val httpRespo = Http.responseFromString (Socket.inputAll socket)
            val _ = Socket.close socket
            fun respFunc result =
                Some (BString.unshow (String.extract result 2 None))
        in
            Option.mapPartial
                (fn resp => processResponse resp jsonId respFunc)
                httpRespo
        end
    
    (* removeAuthorizedUser: string -> int -> int -> string -> BString.bstring option
     * `removeAuthorizedUser host port jsonId recipient address`
     *
     * Queries Ethereum client located at host `host` and port number `port`,
     * calling the `removeAuthorizedUser` method of our smart contract, located
     * at `recipient`, using the parameter `address`. The `jsonId` parameter is
     * an arbitrary integer used to identify the response to this particular
     * request.
     *)
    fun removeAuthorizedUser host port jsonId recipient address =
        let
            val funSig = "0x89fabc80"
            val data = String.concat [funSig, encodeAddress address]
            val jsonMsg = formEthSendTransaction jsonId sender recipient data
            val hostPair = ("Host", String.concatWith ":" [host, Int.toString port])
            val contentType = ("Content-Type", "application/json")
            val httpReq = Http.Request "POST" "/" "HTTP/1.1"
                            [hostPair, contentType]
                            (Some (Json.convertToString jsonMsg))
            val httpStr = Http.requestToString httpReq
            val socket = Socket.connect host port
            val _ = Socket.output socket httpStr
            val httpRespo = Http.responseFromString (Socket.inputAll socket)
            val _ = Socket.close socket
            fun respFunc result =
                Some (BString.unshow (String.extract result 2 None))
        in
            Option.mapPartial
                (fn resp => processResponse resp jsonId respFunc)
                httpRespo
        end
end
