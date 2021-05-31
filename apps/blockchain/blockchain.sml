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

(* **WARNING**: Int.fmt does not return twos-complement representation *)
(* encodeInt : int -> string
 * Transforms a ML integer into Ethereum JSON ABI
 *)
fun encodeInt n =
    if n < 0 then raise Domain else ();
    let
        val hexStr = Int.fmt StringCvt.HEX n;
        val hexStrLen = String.size hexStr;
    in
        StringCvt.padLeft #"0" 64 hexStr
    end

(* encodeString : string -> string
 * Transforms a ML string into Ethereum JSON ABI
 *)
fun encodeString str =
    let
        val strLen = String.size str;
        val strLenEnc = encodeInt strLen;
    in
        ""
    end

(* decodeString : string -> string
 * Transforms an Ethereum JSON ABI encoded string into a ML string
 *)
fun decodeString enc = ""
