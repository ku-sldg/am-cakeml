(* Depends on ByteString *)
(*
  Stray thoughts: 
  - do these ffi calls have any error code reporting?
  - what is purpose of initialize, sendOutput, recieveInput?
*)

val nullByte = Word8.fromInt 0
val emptyBuf = Word8Array.array 0 nullByte
val unitBuf  = Word8Array.array 1 nullByte

(* Necessary? *)
(* val _ = #(initializeComponent) "" emptyBuf *)

datatype logType = Info | Debug | Error

structure Api = struct 

    (*
    (* String -> () *)
    fun sendOutput out = #(api_sendOutput) out emptyBuf

    (* () -> String *)
    local
        (* val inBuf = Word8Array.array 2048 nullByte *)
        fun getLeadingStr buf = case Word8Array.findi ((op =) nullByte) buf of
              Some (i, _) =>  Word8Array.substring buf 0 i
            | _ => ByteString.toRawString buf
    in 
        fun receiveInput () = 
        let val inBuf = Word8Array.array 2048 nullByte in
            #(api_receiveInput) "" inBuf;
            getLeadingStr inBuf
        end
    end
    *)

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
    (* Don't we also need a getTrustedIds function, so that we can just update one? I suppose we can maintain that internally *)

    (* What do these do? *)
    (* fun getInitiateAttestation *)
    (* fun sendTerminateAttestation *)

    fun pacerWait () = #(sb_pacer_notification_wait) "" unitBuf

    (* What does pacer emit do? *)
end
