(* Depends on ByteString *)


val nullByte = Word8.fromInt 0
val emptyBuf = Word8Array.array 0 nullByte
val unitBuf  = Word8Array.array 1 nullByte

val ffi_err = nullByte

datatype logType = Info | Debug | Error

structure Api = struct 
    (* logType -> string -> () *)
    fun log lType msg = case lType of
          Info  => #(api_logInfo)  msg emptyBuf
        | Debug => #(api_logDebug) msg emptyBuf
        | Error => #(api_logError) msg emptyBuf

    (* string -> () *)
    (* TODO: Add safety rails to limit size of req *)
    fun sendRequest req = #(api_send_attestationRequest) req emptyBuf

    (* () -> string *)
    (* TODO *)
    fun getResponse () = ""

    (* string -> () *)
    (* TODO: Add safety rails to limit size of req *)
    fun sendTrustedIds trustedIds = #(api_send_TrustedIds) trustedIds emptyBuf

    (* () -> connection Option *)
    (* Seems to be blocking? *)
    fun getConnection () = 
        let val conn_len = 8 (* random placeholder val *)
            val out_buf = Word8Array.array (conn_len + 1) nullByte
         in #(api_get_InitiateAttestation) "" out_buf;
            if Word8Array.sub out_buf 0 = ffi_err then
                (log Error "api_get_InitiateAttestation error"; None)
            else
                Some (Word8Array.substring out_buf 1 conn_len)
        end
    
    (* connection -> () *)
    fun closeConnection conn = #(api_send_TerminateAttestation) conn emptyBuf

    fun pacerWait () = #(sb_pacer_notification_wait) "" unitBuf

    (* What does pacer emit do? *)
end
