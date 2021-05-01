(* Depends on ByteString *)

datatype logType = Info | Debug | Error

structure Api = struct 
    local
        val nullByte  = Word8.fromInt 0
        val emptyBuf  = Word8Array.array 0 nullByte
        val singleBuf = Word8Array.array 1 nullByte
        val c_false   = nullByte
    in

        (* () -> () *)
        fun receiveInput () = #(api_receiveInput) "" emptyBuf

        (* () -> () *)
        fun sendOutput () = #(api_sendOutput) "" emptyBuf

        (* logType -> string -> () *)
        fun log lType msg = case lType of
              Info  => #(api_logInfo)  msg emptyBuf
            | Debug => #(api_logDebug) msg emptyBuf
            | Error => #(api_logError) msg emptyBuf

        (* string -> () *)
        (* TODO: Add safety rails to limit size of req *)
        fun sendRequest req = #(api_send_AttestationRequest) req emptyBuf

        (* () -> string option *)
        local
            val respMaxLen = 2048
            fun getLeadingStr buf = case Word8Array.findi ((op =) nullByte) buf of
                  Some (i, _) =>  Word8Array.substring buf 0 i
                | _ => ByteString.toRawString buf
        in 
            fun getResponse () = 
                let val in_buf = Word8Array.array (respMaxLen + 1) nullByte in
                    #(api_get_AttestationResponse) "" in_buf;
                    if Word8Array.sub in_buf 0 = c_false then
                        None
                    else 
                        Some (getLeadingStr (ByteString.fromRawString (Word8Array.substring in_buf 1 respMaxLen)))
                end
        end

        (* string -> () *)
        (* TODO: Add safety rails to limit size of req *)
        fun sendTrustedIds trustedIds = #(api_send_TrustedIds) trustedIds emptyBuf

        (* () -> Bool *)
        fun getConnection () = (
            #(api_get_InitiateAttestation) "" singleBuf;
            Word8Array.sub singleBuf 0 <> c_false
        )
        
        (* () -> () *)
        fun closeConnection () = #(api_send_TerminateAttestation) "" emptyBuf

        (* () -> Bool *)
        fun pacer_emit() = (
            #(sb_pacer_notification_emit) "" singleBuf;
            Word8Array.sub singleBuf 0 <> c_false
        )

        (* () -> Bool *)
        fun pacer_wait() = (
            #(sb_pacer_notification_wait) "" singleBuf;
            Word8Array.sub singleBuf 0 <> c_false
        )
    end
end
