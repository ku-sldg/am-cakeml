(* Depends on: Util/Misc for the FFI structure *)

exception RPCCallErr string

local 

    fun ffi_sendCoplandReq x y = #(sendCoplandRequest) x y
    fun ffi_sendCoplandAppReq x y = #(sendCoplandAppRequest) x y
    (*
    fun composeInputs    req ip port = BString.fromString (ip ^ "\0" ^ (String.fromInt port) ^ "\0" ^ (jsonToStr (requestToJson req)))
    fun composeInputsApp req ip port = BString.fromString (ip ^ "\0" ^ (String.fromInt port) ^ "\0" ^ (jsonToStr (appRequestToJson req)))
    *)

in 

    (* req -> resp *)
    fun sendCoplandReq req ip port =
        case FFI.callOpt ffi_sendCoplandReq 4096 (BString.fromString "hello") of
        Some response => jsonToResponse ( strToJson ( BString.toCString response))
        | None => raise RPCCallErr ("RPC Call for sendCoplandReq Failed. Tried to send req: " ^ "hello")

    (* req -> resp *)
    fun sendCoplandAppReq req ip port =
        case FFI.callOpt ffi_sendCoplandAppReq 4096 (BString.fromString "hello") of
        Some response => jsonToAppResponse ( strToJson ( BString.toCString response))
        | None => raise RPCCallErr ("RPC Call for sendCoplandAppReq Failed. Tried to send req: " ^ "hello")

end
