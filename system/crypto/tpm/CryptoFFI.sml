(* Depends on: Util *)

(* Safe wrappers to FFI crypto functions *)
structure Crypto = struct
    exception Err string
    local
        fun ffi_sha512          x y = #(sha512)         x y
        fun ffi_signMsg         x y = #(signMsg)        x y
        fun ffi_sigCheck        x y = #(sigCheck)       x y
        fun ffi_randomBytes     x y = #(randomBytes)    x y
        val pubkeyLen = 270
        val signLen = 256
    in

    val hash = FFI.call ffi_sha512 64

    fun signMsg keyHandle filename = 
        FFI.call ffi_signMsg signLen (BString.concatList [keyHandle, filename])


    fun sigCheck pub sign msg = 
        if BString.length pub <> pubkeyLen then
            raise (Err "Wrong public key size, Error in sigCheck FFI")
        else
            FFI.callBool ffi_sigCheck (BString.concatList [pub, sign, msg])

    fun randomBytes len =
        FFI.call ffi_randomBytes len (BString.nulls len)

    end
end