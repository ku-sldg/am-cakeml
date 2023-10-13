(* Depends on: Util/Misc for the FFI structure *)

exception RPCCallErr string

local 
    fun ffi_measurementRequest x y = #(measurementRequest) x y
    fun ffi_measurementAppraise x y = #(measurementAppraise) x y
in 

    (* int -> () *)
    fun kernelMeasurement id =
        case FFI.callOpt ffi_measurementRequest 4096 (FFI.n2w2 id) of
          Some bs => bs
        | None => raise RPCCallErr ("RPC Call for Kernel Measurement Failed. Tried to invoke measurement #" ^ (Int.toString id))

    (* int -> () *)
    fun kernelAppraisal id =
        case FFI.callOpt ffi_measurementAppraise 4096 (FFI.n2w2 id) of
          Some bs => bs
        | None => raise RPCCallErr ("RPC Call for Kernel Measurement Appraisal Failed. Tried to invoke appraisal #" ^ (Int.toString id))

end
