(* Depends on util, copland *)


val log = Api.log

exception Undef
(* () -> 'a *)
fun undefined () = raise Undef


(* string -> string *)
val hexToRaw = ByteString.toRawString o ByteString.fromHexString
val rawToHex = ByteString.toHexString o ByteString.fromRawString

val pub = hexToRaw "490E2422528F14AC6A48DDB9D72CB30B8345AF2E939003BC7A33A6057F2FFB0101000000000000002DD0B7F53A560000A049D882A37F00000000000000000000"

(* connection -> string *)
val connectionToAddr = rawToHex

(* () -> connection *)
(* Blocking/waiting. *)
(* connection type includes relevant info like ip address, whatever we need to send requests and add to whitelist *)
fun waitGetConnection () = (
    log Info "Waiting for connection";
    case Api.getConnection () of
          Some conn => conn
        | None => waitGetConnection ()
)

(* () -> string option *)
(* returns Nothing in the case of a timeout. *)
fun waitGetResponse conn = (
   log Info "Waiting for response";
   Some (Api.getResponse ())
)

(* connection -> string -> () *)
fun sendReq conn req = (
   log Info ("Sending request " ^ (rawToHex req));
   Api.sendRequest req
)

local
    val emptyId = ByteString.toRawString (Word8Array.array 4 (Word8.fromInt 0))
    val trusted_ids = Array.array 4 emptyId
    val flatten_ids = Array.foldl (op String.^) ""
in
    (* connection -> () *)
    (* idempotent *)
    fun addToWhitelist conn = 
        let val addr = connectionToAddr conn
         in log Info ("Adding " ^ (rawToHex addr) ^ " to the whitelist");
            if Array.exists ((op =) addr) trusted_ids then
                log Info ((rawToHex addr) ^ " already in the whitelist")
            (* else (case Array.findi (fn i => (op =) emptyId) trusted_ids *)
            else case Array.findi (const ((op =) emptyId)) trusted_ids of
                  Some (i, _) => Array.update trusted_ids i addr
                | None => (
                      log Error "No room in the whitelist, overwriting first entry";
                      Array.update trusted_ids 0 addr
                 );
            Api.sendTrustedIds (flatten_ids trusted_ids)
        end

    (* connection -> () *)
    (* idempotent *)
    fun removeFromWhitelist conn = 
        let val addr = connectionToAddr conn
         in log Info ("Removing " ^ (rawToHex addr) ^ " from the whitelist");
            case Array.findi (const ((op =) addr)) trusted_ids of
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

(* true if appraisal succeeds *)
(* might need to be refactored to differentiate bad appraisal from timeout and misc. errors (the former might warrant a permanent blacklisting, while the latter would not) *)
fun attest conn = 
    let val nonce = genNonce ()
        val _ = sendReq conn (ByteString.toRawString nonce)
     in case waitGetResponse () of
              Some resp => case parseResp resp of
                    Some ev =>
                        if appraise nonce ev then
                            (addToWhitelist conn; True) 
                        else
                            (removeFromWhitelist conn; False)
                  | _ => (log Info "Evidence failed to parse";
                          removeFromWhitelist conn;
                          False)
            | _ => (log Info "Request timed-out";
                    removeFromWhitelist conn;
                    False)
    end

(* () -> () *)
(* blocks/waits until start of next period *)
fun waitForNextTick () = (
    log Info "Waiting for the start of the next period";
    Api.pacerWait ()
)

(* connection -> () *)
fun closeConnection conn = (
    log Info "Closing conection";
    Api.closeConnection conn
)

(* conn -> () *)
(* Loops infinitely unless appraisal fails, or timeout *)
fun attestLoop conn = (
    if attest conn
        then (waitForNextTick (); attestLoop conn)
        else closeConnection conn
)

(* () -> 'a *)
(* Infinite loop *)
fun mainLoop () = (
    attestLoop (waitGetConnection ());
    mainLoop ()
)
val () = mainLoop ()
