(* Depends on: Util/Misc for the FFI structure *)

exception RPCCallErr string

local 
    fun ffi_measurementRequest  x y = #(measurementRequest)  x y
in 
    (* int -> () *)
    fun kernelMeasurement id =
        if FFI.callBool ffi_measurementRequest (FFI.n2w2 id) then
            ()
        else
            raise RPCCallErr ("RPC Call for Kernel Measurement Failed. Tried to invoke measurement #" ^ (Int.toString id))
end
