(* Depends on: Util/Misc for the FFI structure *)

exception RPCCallErr string

structure FileServer = struct
    local 
        fun ffi_readFile x y = #(readFile) x y
    in 

        (* string -> string *)
        fun readFile filepath =
            case FFI.callOpt ffi_readFile 4096 (BString.fromString filepath) of
            Some contents => BString.toCString contents
            | None => raise RPCCallErr ("RPC Call for ReadFile Failed. Tried to read file" ^ filepath)

    end
end
