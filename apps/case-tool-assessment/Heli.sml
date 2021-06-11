(* Depends on util, copland, HamrStandard *)

val pub = BString.unshow "490E2422528F14AC6A48DDB9D72CB30B8345AF2E939003BC7A33A6057F2FFB0101000000000000002DD0B7F53A560000A049D882A37F00000000000000000000"

(* Hamr app-specific FFI functions *)
local 
    fun sendRequest_ffi     arg out = #(api_send_AttestationRequest)   arg out
    fun getResponse_ffi     arg out = #(api_get_AttestationResponse)   arg out
    fun sendTrustedIds_ffi  arg out = #(api_send_TrustedIds)           arg out
    fun getConnection_ffi   arg out = #(api_get_InitiateAttestation)   arg out
    fun closeConnection_ffi arg out = #(api_send_TerminateAttestation) arg out
in
    (* bstring -> () *)
    fun sendRequest req = FFI.callNoOut sendRequest_ffi req

    (* () -> bstring *)
    fun getResponse () = Control.getDataEvent getResponse_ffi 2048 BString.empty

    (* bstring -> () *)
    fun sendTrustedIds trustedIds = 
        let val length = BString.length trustedIds
         in if length = 32 then
                FFI.callNoOut sendTrustedIds_ffi trustedIds
            else
                log Error ("sendTrustedIds called with a " ^
                           Int.toString length ^
                           "-byte argument, but expected 32 bytes.")
        end
    (* () -> bstring option *)
    fun getConnection () = Control.getDataEvent getConnection_ffi 4 BString.empty

    (* () -> () *)
    fun closeConnection () = FFI.callNoOut closeConnection_ffi BString.empty
end

local
    val emptyId = BString.nulls 8
    val trusted_ids = Array.array 4 emptyId
    val flatten_ids = Array.foldl BString.concat BString.empty
    
    val protocol_id = BString.fromIntLength 4 BString.LittleEndian 2
    fun getId ip = BString.concat protocol_id ip
in
    (* bstring -> () *)
    (* idempotent *)
    fun addToWhitelist ip =
        let val id = getId ip
         in log Info ("Adding 0x" ^ BString.show id ^ " to the whitelist");
            if Array.exists ((op =) id) trusted_ids then
                log Info ("0x" ^ BString.show id ^ " already in the whitelist")
            else case Array.findi (const ((op =) emptyId)) trusted_ids of
                  Some (i, _) => Array.update trusted_ids i id
                | None => (
                    log Error "No room in the whitelist, overwriting first entry";
                    Array.update trusted_ids 0 id
                );
            sendTrustedIds (flatten_ids trusted_ids)
        end

    (* bstring -> () *)
    (* idempotent *)
    fun removeFromWhitelist ip =
        let val id = getId ip
         in log Info ("Removing 0x" ^ BString.show id ^ " from the whitelist");
            case Array.findi (const ((op =) id)) trusted_ids of
                  Some (i, _) => Array.update trusted_ids i emptyId
                | None => log Info "Connection not in the whitelist";
            sendTrustedIds (flatten_ids trusted_ids)
        end
end

(* bstring -> ev option *)
fun parseResp resp = (
    log Info ("Received response: " ^ BString.toString resp);
    Some (jsonToEv (JsonExtra.parse (BString.toString resp)))
) handle _ => None

(* Stubbed out crypto. Signature always passes *)
fun verifySig g pub = 
    case g of
          G bs ev => Some True
        | _ => None

(* bstring -> ev -> bool *)
(* true if appraisal succeeds *)
fun appraise nonce ev = case ev of
      G evSign (SS (H evHash) (N _ evNonce Mt)) => 
          if evNonce <> nonce then
              (log Info "Appraisal failed, bad nonce"; False)
          else if not (List.member evHash goldenHashes) then
              (log Info "Appraisal failed, bad hash"; False)
          else if not (Option.valOf (verifySig ev pub)) then
              (log Info "Appraisal failed, bad signature"; False)
          else
              (log Info "Appraisal succeeded"; True)
    | _ => (log Info "Unexpected evidence structure"; False)

local 
    fun fakeRand_ffi arg out = #(fakeRand) arg out
in 
    (* () -> bstring *)
    fun genNonce () = FFI.call fakeRand_ffi 16 BString.empty
end

(* () -> bstring *)
fun sendAttRequest () =
    let val nonce = genNonce ()
     in sendRequest nonce;
        log Info ("Sending request: 0x" ^ BString.show nonce);
        nonce
    end

datatype am_state =
      NoConnection
    | SendingRequest  BString.bstring                 (* ip addr *)
    | GettingResponse BString.bstring BString.bstring (* ip addr, nonce *)

local
    (* attestation frequency = (att_len + 1) * pacer frequency *)
    (* att_len >= 1 *)
    val att_len = 9 (* ~5 second attestation period *)
    val pacer_count = Ref 0
    fun incr count = count := (!count + 1) mod att_len

    val curr_state = Ref NoConnection

    fun rmAndClose ip = (
        removeFromWhitelist ip;
        closeConnection ();
        log Info "Closing conection";
        curr_state := NoConnection;
        pacer_count := 0
    )
in 
    (* () -> () *)
    fun attestation_step () = (
        (* log Debug ("Pacer count: " ^ Int.toString (!pacer_count)); *)
        case !curr_state of
          NoConnection => (
              case getConnection () of
                    Some ip => (
                        log Info ("Connection received from: 0x" ^ BString.show ip);
                        curr_state := SendingRequest ip;
                        attestation_step ()
                  )
                  | None => log Info "No connection"
          )
        | SendingRequest ip => (
              if !pacer_count = 0 then 
                  curr_state := GettingResponse ip (sendAttRequest ())
              else ();
              incr pacer_count
          )
        | GettingResponse ip nonce =>
              case getResponse () of
                    Some resp => (
                        log Info ("Received response: " ^ BString.toString resp);
                        case parseResp resp of
                            Some ev =>
                                if appraise nonce ev then (
                                    addToWhitelist ip;
                                    curr_state := SendingRequest ip;
                                    incr pacer_count
                                ) else rmAndClose ip
                          | None => (
                                log Info "Evidence failed to parse";
                                rmAndClose ip
                          )
                    )
                  | None => 
                        if !pacer_count = 0 then
                            rmAndClose ip
                        else 
                            incr pacer_count
    )
end

(* Hamr entry point *)
val _ = Control.entry attestation_step