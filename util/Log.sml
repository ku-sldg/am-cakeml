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

    (* string -> string -> () *)
    fun logInfoFile    file msg = TextIOExtra.printLn_file file ("WARNING: " ^ msg)
    fun logWarningFile file msg = TextIOExtra.printLn_file file ("WARNING: " ^ msg)
    fun logErrorFile   file msg = TextIOExtra.printLn_file file ("ERROR: "   ^ msg)
    fun logDebugFile   file msg = TextIOExtra.printLn_file file ("DEBUG: "   ^ msg)

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
        fun setLogInfo    (f: string -> unit) = logInfo    := f
        fun setLogWarning f = logWarning := f
        fun setLogError   f = logError   := f
        fun setLogDebug   f = logDebug   := f
    end

    fun setLogDefault () = (
        setLogInfo    logInfoDefault;
        setLogWarning logWarningDefault;
        setLogError   logErrorDefault;
        setLogDebug   logDebugDefault
    )

    fun setLogFile file = (
        setLogInfo    (logInfoFile    file);
        setLogWarning (logWarningFile file);
        setLogError   (logErrorFile   file);
        setLogDebug   (logDebugFile   file)
    )
end

val log = Log.log