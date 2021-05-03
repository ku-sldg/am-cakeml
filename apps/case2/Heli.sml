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
    val protocol_id = "ABCD" (* arbitrary placeholder id *)
    val emptyId = ByteString.toRawString (Word8Array.array 8 (Word8.fromInt 0))
    val trusted_ids = Array.array 4 emptyId
    val flatten_ids = Array.foldl (op String.^) ""
    
    fun getId ip = ip ^ protocol_id
in
    (* string -> () *)
    (* idempotent *)
    fun addToWhitelist ip =
        let val id = getId ip
         in log Info ("Adding 0x" ^ (rawToHex id) ^ " to the whitelist");
            if Array.exists ((op =) id) trusted_ids then
                log Info ("0x" ^ (rawToHex id) ^ " already in the whitelist")
            else case Array.findi (const ((op =) emptyId)) trusted_ids of
                  Some (i, _) => Array.update trusted_ids i id
                | None => (
                    log Error "No room in the whitelist, overwriting first entry";
                    Array.update trusted_ids 0 id
                );
            Api.sendTrustedIds (flatten_ids trusted_ids)
        end

    (* string -> () *)
    (* idempotent *)
    fun removeFromWhitelist ip =
        let val id = getId ip
         in log Info ("Removing 0x" ^ (rawToHex id) ^ " from the whitelist");
            case Array.findi (const ((op =) id)) trusted_ids of
                  Some (i, _) => Array.update trusted_ids i emptyId
                | None => log Info "Connection not in the whitelist";
            Api.sendTrustedIds (flatten_ids trusted_ids)
        end
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
    | SendingRequest  string               (* ip addr *)
    | GettingResponse string ByteString.bs (* ip addr, nonce *)

local
    val curr_state = Ref NoConnection
    fun rmAndClose ip = (
        removeFromWhitelist ip;
        Api.closeConnection ();
        log Info "Closing conection";
        curr_state := NoConnection
    )
in 
    (* () -> () *)
    fun attestation_step () = case (!curr_state) of
          NoConnection => (
              case Api.getConnection () of
                    Some ip => (
                        log Info ("Connection received from: 0x" ^ (rawToHex ip));
                        curr_state := SendingRequest ip;
                        attestation_step ()
                  )
                  | _ => log Info "No connection"
          )
        | (SendingRequest ip) => 
              curr_state := (GettingResponse ip (sendRequest ()))
        | (GettingResponse ip nonce) => 
              case getResponse () of 
                    Some ev => 
                        if appraise nonce ev then (
                            addToWhitelist ip;
                            curr_state := SendingRequest ip
                        ) else rmAndClose ip
                  | _ => rmAndClose ip
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
