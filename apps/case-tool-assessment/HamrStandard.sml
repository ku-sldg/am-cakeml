(* Depends on util *)

datatype logType = Info | Debug | Error

(* logType -> string -> () *)
fun log lType msg = case lType of
      Info  => #(api_logInfo)  msg Word8ArrayExtra.empty
    | Debug => #(api_logDebug) msg Word8ArrayExtra.empty
    | Error => #(api_logError) msg Word8ArrayExtra.empty

structure Control = struct 
    (* ffi -> int -> bstring -> bstring option *)
    val getDataEvent = FFI.callOpt

    (* ffi -> bstring -> bool *)
    val getEvent = FFI.callBool

    local 
        fun receiveInput_ffi arg out = #(api_receiveInput)           arg out
        fun sendOutput_ffi   arg out = #(api_sendOutput)             arg out
        fun pacer_emit_ffi   arg out = #(sb_pacer_notification_emit) arg out
        fun pacer_wait_ffi   arg out = #(sb_pacer_notification_wait) arg out

        (* () -> () *)
        fun receiveInput () = FFI.callNoOut receiveInput_ffi BString.empty

        (* () -> () *)
        fun sendOutput () = FFI.callNoOut sendOutput_ffi BString.empty

        (* () -> bool *)
        fun pacer_emit () = getEvent pacer_emit_ffi BString.empty

        (* () -> bool *)
        fun pacer_wait () = getEvent pacer_wait_ffi BString.empty

        (* (() -> ()) -> 'a *)
        fun controlLoop doStep = 
            if pacer_wait () then (
                receiveInput ();
                doStep ();
                sendOutput ();
                pacer_emit ();
                controlLoop doStep
            ) else controlLoop doStep
    in
        (* TODO: rewrite to add to list of functions called in controlLoop? *)

        (* Do not call more than once! *)
        (* (() -> ()) -> 'a *)
        fun entry doStep = (
            pacer_emit ();
            controlLoop doStep
        )
	end
end
