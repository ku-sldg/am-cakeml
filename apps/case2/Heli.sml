(* Depends on util, copland *)

val log = Api.log

exception Undef
(* () -> 'a *)
fun undefined () = raise Undef

(* string -> string *)
val hexToRaw = ByteString.toRawString o ByteString.fromHexString
val rawToHex = ByteString.toHexString o ByteString.fromRawString

val pub = hexToRaw "490E2422528F14AC6A48DDB9D72CB30B8345AF2E939003BC7A33A6057F2FFB0101000000000000002DD0B7F53A560000A049D882A37F00000000000000000000"

local
    val connId = "ABCD" (* arbitrary placeholder id *)
    val emptyId = ByteString.toRawString (Word8Array.array 4 (Word8.fromInt 0))
    val trusted_ids = Array.array 4 emptyId
    val flatten_ids = Array.foldl (op String.^) ""
in
    (* () -> () *)
    (* idempotent *)
    fun addToWhitelist () = (
        log Info ("Adding 0x" ^ (rawToHex connId) ^ " to the whitelist");
        if Array.exists ((op =) connId) trusted_ids then
            log Info ("0x" ^ (rawToHex connId) ^ " already in the whitelist")
        else case Array.findi (const ((op =) emptyId)) trusted_ids of
              Some (i, _) => Array.update trusted_ids i connId
            | None => (
                log Error "No room in the whitelist, overwriting first entry";
                Array.update trusted_ids 0 connId
            );
        Api.sendTrustedIds (flatten_ids trusted_ids)
    )

    (* () -> () *)
    (* idempotent *)
    fun removeFromWhitelist () = (
        log Info ("Removing 0x" ^ (rawToHex connId) ^ " from the whitelist");
        case Array.findi (const ((op =) connId)) trusted_ids of
              Some (i, _) => Array.update trusted_ids i emptyId
            | None => log Info "Connection not in the whitelist";
        Api.sendTrustedIds (flatten_ids trusted_ids)
    )
end

(* string -> ev option *)
fun parseResp resp = 
    let fun strToJson str = List.hd (fst (Json.parse ([], str)))
     in Some (jsonToEv (strToJson resp))
    end
    handle _ => None

(* Definition taken from am/measurements. That file is mostly linux-specific. Long-term, this function should be moved somewhere else *)
fun verifySig g pub = 
    case g of
          G bs ev => Some (Crypto.sigCheck pub bs (encodeEv ev))
        | _ => None

(* bytestring -> ev -> bool *)
(* true if appraisal succeeds *)
fun appraise nonce ev = case ev of
      G evSign (N _ evNonce Mt) => 
          if not (ByteString.deepEq evNonce nonce) then
              (log Info "Appraisal failed, bad nonce"; False)
          else if not (Option.valOf (verifySig ev pub)) then
              (log Info "Appraisal failed, bad signature"; False)
          else
              (log Info "Appraisal succeeded"; True)
    | _ => (log Info "Unexpected evidence structure"; False)

(* () -> ByteString *)
(* Placeholder *)
fun genNonce () = Word8Array.array 16 (Word8.fromInt 0)

(* () -> ByteString.bs *)
fun sendRequest () =
    let val nonce = genNonce ()
     in Api.sendRequest (ByteString.toRawString nonce);
        log Info ("Sending request: 0x" ^ (ByteString.toHexString nonce));
        nonce
    end

fun getResponse () = case Api.getResponse () of
      Some resp => (
          log Info ("Received response: " ^ resp);
          case parseResp resp of 
                Some ev => Some ev
              | _ => (log Info "Evidence failed to parse"; None)
      )
    | None => (log Info "No Response Received"; None)

datatype am_state =
      NoConnection
    | SendingRequest
    | GettingResponse ByteString.bs (* argument is the nonce *)

local
    val curr_state = Ref NoConnection
    fun rmAndClose () = (
        removeFromWhitelist ();
        Api.closeConnection ();
        log Info "Closing conection";
        curr_state := NoConnection
    )
in 
    (* () -> () *)
    fun attestation_step () = case !curr_state of
          NoConnection =>
              if Api.getConnection () then (
                  log Info "Connection received";
                  curr_state := SendingRequest;
                  attestation_step()
              ) else 
                  log Info "No connection"
        | SendingRequest => (
              curr_state := GettingResponse (sendRequest ())
          )
        | GettingResponse nonce => 
              case getResponse () of 
                    Some ev => 
                        if appraise nonce ev then (
                            addToWhitelist ();
                            curr_state := SendingRequest
                        ) else rmAndClose ()
                  | _ => rmAndClose ()
end

(* () -> 'a *)
(* Infinite loop *)
fun loop () =
    if Api.pacer_wait () then (
        log Info "Pacer-cycle start";
        Api.receiveInput ();
        attestation_step ();
        Api.sendOutput ();
        Api.pacer_emit ();
        loop ()
    )
    else
        loop ()

fun start () = (
    Api.pacer_emit ();
    loop ()
)
val () = start ()