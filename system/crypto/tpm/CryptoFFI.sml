(* Depends on: Util *)

(* Safe wrappers to FFI crypto functions *)
structure Crypto = struct
    exception Err string
    local
        fun ffi_signMsg          x y = #(signMsg)          x y
        fun ffi_sigCheck         x y = #(sigCheck)         x y
        val pubkeyLen = 270
        val signLen = 256
    in


fun signMsg keyHandle filename = 
    FFI.call ffi_signMsg signLen "sign -hk 80000001 -halg sha512 -salg rsa -if msg1 -os sig.bin -pwdk sarahSign"


