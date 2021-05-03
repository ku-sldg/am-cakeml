(* Depends on ByteString *)

datatype logType = Info | Debug | Error

structure Api = struct 
    local
        val nullByte  = Word8.fromInt 0
        val emptyBuf  = Word8Array.array 0 nullByte
        val singleBuf = Word8Array.array 1 nullByte
        val c_false   = nullByte

        (* (string -> Word8Array.Array -> ()) -> int -> string -> string option *)
        fun getDataEvent ffi data_len arg = 
            let val out_buf = Word8Array.array (1 + data_len) nullByte
             in ffi arg out_buf;
                if Word8Array.sub out_buf 0 = c_false then
                    None
                else 
                    Some (Word8Array.substring out_buf 1 data_len)
            end

        (* (string -> Word8Array.Array -> ()) -> string -> bool *)
        fun getEvent ffi arg = (
            ffi arg singleBuf;
            Word8Array.sub singleBuf 0 <> c_false
        )

        (* first-class function wrappers *)
        fun att_resp_ffi   arg out = #(api_get_AttestationResponse) arg out
        fun init_att_ffi   arg out = #(api_get_InitiateAttestation) arg out
        fun pacer_emit_ffi arg out = #(sb_pacer_notification_emit)  arg out
        fun pacer_wait_ffi arg out = #(sb_pacer_notification_wait)  arg out
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
            fun getLeadingStr buf = case Word8Array.findi ((op =) nullByte) buf of
                  Some (i, _) =>  Word8Array.substring buf 0 i
                | _ => ByteString.toRawString buf
        in 
            fun getResponse () = 
                Option.map (getLeadingStr o ByteString.fromRawString)
                  (getDataEvent att_resp_ffi 2048 "")
        end

        (* string -> () *)
        (* TODO: Add safety rails to limit size of req *)
        fun sendTrustedIds trustedIds = #(api_send_TrustedIds) trustedIds emptyBuf

        (* () -> string option *)
        (* ip address as raw string *)
        fun getConnection () = getDataEvent init_att_ffi 4 ""
        
        (* () -> () *)
        fun closeConnection () = #(api_send_TerminateAttestation) "" emptyBuf

        (* () -> Bool *)
        fun pacer_emit () = getEvent pacer_emit_ffi ""

        (* () -> Bool *)
        fun pacer_wait () = getEvent pacer_wait_ffi ""
    end
end
