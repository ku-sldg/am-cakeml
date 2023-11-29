(* Depends on: Util/Misc for the FFI structure *)

exception RPCCallErr string

local 

    fun ffi_sendCoplandReq x y = #(sendCoplandRequest) x y
    fun ffi_sendCoplandAppReq x y = #(sendCoplandAppRequest) x y
    (*
    fun composeInputs    req ip port = BString.fromString (ip ^ "\0" ^ (String.fromInt port) ^ "\0" ^ (jsonToStr (requestToJson req)))
    fun composeInputsApp req ip port = BString.fromString (ip ^ "\0" ^ (String.fromInt port) ^ "\0" ^ (jsonToStr (appRequestToJson req)))
    *)
    fun ffi_recvCoplandReqFromLinux x y = #(recvCoplandRequestFromLinux) x y
    fun ffi_recvCoplandAppReqFromLinux x y = #(recvCoplandAppRequestFromLinux) x y

    fun ffi_respondToLinux x y = #(respondToLinux) x y

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

    (* int -> resp *)
    fun recvCoplandReqFromLinux () =
        case FFI.callOpt ffi_recvCoplandReqFromLinux 4096 (FFI.n2w2 0) of
        Some response => BString.toCString response
        | None => raise RPCCallErr ("RPC Call for recvCoplandReqFromLinux Failed. Tried to recv req: " ^ "hello")

    (* int -> resp *)
    fun recvCoplandAppReqFromLinux () =
        case FFI.callOpt ffi_recvCoplandAppReqFromLinux 4096 (FFI.n2w2 0) of
        Some response => BString.toCString response
        | None => raise RPCCallErr ("RPC Call for recvCoplandAppReqFromLinux Failed. Tried to recv req: " ^ "hello")

    (* resp -> () *)
    fun respondToLinux response =
        if FFI.callBool ffi_respondToLinux (BString.fromString response) then
            ()
        else
            raise RPCCallErr "respondToLinux FFI Failure"

end
