(* Depends on: Util *)

exception DataportErr

local 
    fun ffi_writeDataport x y = #(writeDataport) x y
    fun ffi_emit_event    x y = #(emit_event)    x y
in 
    (* string -> bstring -> () *)
    fun writeDataport name msg =
        let val payload = FFI.nullSeparated [BString.fromString name, msg]
         in if FFI.callBool ffi_writeDataport payload then () else raise DataportErr
        end

    (* () -> () *)
    fun emitEvent () = (FFI.call ffi_emit_event BString.empty; ())
end

===================


(* Depends on: Util *)

exception DataportErr string

local 
    fun ffi_writeDataport x y = #(writeDataport) x y
    fun ffi_readDataport  x y = #(readDataport)  x y
    fun ffi_waitDataport  x y = #(waitDataport)  x y
    fun ffi_emitDataport  x y = #(emitDataport)  x y
in 
    (* string -> bstring -> () *)
    fun writeDataport name msg =
        let val payload = BString.concatList
                  [BString.fromString name, BString.nullByte, msg]
         in if FFI.callBool ffi_writeDataport payload then () else raise DataportErr "write failure"
        end

    (* string -> int -> bstring *)
    fun readDataport name len =
        case FFI.callOpt ffi_readDataport len (BString.fromString name) of 
              Some bs => bs
            | None => raise DataportErr "read failure"

    (* string -> bstring *)
    fun waitDataport name = 
        case FFI.callOpt ffi_waitDataport 4 (BString.fromString name) of 
              Some bs => bs
            | None => raise DataportErr "wait failure"

    (* string -> () *)
    fun emitDataport name =
        if FFI.callBool ffi_emitDataport (BString.fromString name) then
            ()
        else
            raise DataportErr "emit failure"
end
