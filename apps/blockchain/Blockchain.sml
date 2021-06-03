(* Dependencies:
 * ../../util/Bytestring.sml
 *   ../../util/Extra.sml
 * ../../util/Json.sml
 *)

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
local

    (* encodeIntHelper : int -> string
    * Transforms a ML integer into Ethereum JSON ABI int256.
    *)
    fun encodeIntHelper n =
        BString.show (BString.fromIntLength 32 BString.BigEndian n)

    (* decodeIntHelper : string -> int
    * Transforms an Ethereum JSON ABI int256 into an ML integer.
    * 
    * Raises a `Word8Extra.InvalidHex` exception when `BString.unshow` cannot
    * parse the input.
    *)
    fun decodeIntHelper enc =
        BString.toInt BString.BigEndian (BString.unshow enc)
in
    (* encodeInt : int -> string
     * Transforms a ML integer into Ethereum JSON ABI uint256.
     *
     * 256-bit integers in Ethereum are encoded in their hexidecimal form (64
     * hexits or 32 bytes).
     *)
    fun encodeInt n =
        if n >= 0
        then String.concat ["0x", encodeIntHelper n]
        else raise EthereumExn "Can only encode non-negative integers."

    (* decodeInt : string -> int
    * Transforms an Ethereum JSON ABI int256 into an ML integer.
    * 
    * Raises a `Word8Extra.InvalidHex` exception when `BString.unshow` cannot
    * parse the input. Raises `EthereumExn` when the encoding does not start
    * with `"0x"`. Raises an exception through String.substring if input is too
    * short.
    *)
    fun decodeInt enc =
        if String.substring enc 0 2 = "0x"
        then decodeIntHelper (String.substring enc 2 64)
        else raise EthereumExn "Hex string did not start with \"0x\"."
    
    (* encodeBytes : BString.bstring -> string
    * Transforms a ML byte string into Ethereum JSON ABI.
    * 
    * Bytes are encoded by first encoding the length as a 256-bit unsigned
    * integer, then representing the byte string as a sequence of hexits, and
    * then padding with zeros at the end so the final result consists of a
    * multiple of 32-bytes.
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
            String.concat ["0x", encodeIntHelper bsLen, BString.show bs, suffix]
        end

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
end
