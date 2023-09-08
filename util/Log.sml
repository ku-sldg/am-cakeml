(* Depends on Extra *)

datatype logType =
      Info
    | Warning
    | Error
    | Debug

structure Log = struct 
    (* string -> () *)
    val noLog : string -> unit = const ()

    (* string -> () *)
    fun logInfoDefault    msg = TextIOExtra.printLn     ("INFO: "    ^ msg)
    fun logWarningDefault msg = TextIOExtra.printLn     ("WARNING: " ^ msg)
    fun logErrorDefault   msg = TextIOExtra.printLn_err ("ERROR: "   ^ msg)
    fun logDebugDefault   msg = TextIOExtra.printLn     ("DEBUG: "   ^ msg)

    (* TODO: add file log functions *)

    (* TODO: add optional timestamps *)

    local 
        (* (string -> ()) ref *)
        val logInfo    = Ref logInfoDefault
        val logWarning = Ref logWarningDefault
        val logError   = Ref logErrorDefault
        val logDebug   = Ref logDebugDefault
    in 
        (* logType -> string -> () *)
        (* Note, log implementation not resolved until full application *)
        fun log ltype msg = case ltype of 
              Info    => !logInfo    msg
            | Warning => !logWarning msg
            | Error   => !logError   msg
            | Debug   => !logDebug   msg

        (* (string -> ()) -> () *)
        fun setLogInfo    f = logInfo    := f
        fun setLogWarning f = logWarning := f
        fun setLogError   f = logError   := f
        fun setLogDebug   f = logDebug   := f
    end
end

val log = Log.log