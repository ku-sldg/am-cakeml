(* Depends on: Util *)

(* Safe wrappers to FFI crypto functions *)
structure Crypto = struct
    exception Err string
    local
        fun ffi_sha512          x y = #(sha512)             x y 
        fun ffi_signMsg         x y = #(signMsg)            x y
        fun ffi_sigCheck        x y = #(sigCheck)           x y
        fun ffi_randomBytes     x y = #(randomBytes)        x y
        fun ffi_tpmSetup        x y = #(tpmSetup)           x y 
        fun ffi_tpmCreateSigKey x y = #(tpmCreateSigKey)    x y    
        fun ffi_getData         x y = #(getData)            x y 
        fun ffi_tpmSign         x y = #(tpmSign)            x y 
        val pubkeyLen = 270
        val signLen = 256
        val dataLen = 50   (* overestimated length in bytes of data.txt *)
        val tpmSigLen = 262 (* length in bytes of tpm signature *)
    in



    (* setup tpm for attestation *)
    val tpmSetup =
        FFI.callBool ffi_tpmSetup (BString.nulls 0)

    (* create_and_load_ak *) 
    val tpmCreateSigKey =
        FFI.callBool ffi_tpmCreateSigKey (BString.nulls 0)

    (* get_data *)
    val getData =
        FFI.call ffi_getData dataLen (BString.nulls 0)

    (* tpm_sig *)
    fun tpmSign data = 
        FFI.call ffi_tpmSign tpmSigLen data









    val hash = FFI.call ffi_sha512 64

    fun signMsg priv msg =
        let
            val privKeyLen =
                BString.fromIntLength
                    2
                    BString.BigEndian
                    (BString.length priv)
        in
            FFI.call ffi_signMsg signLen (BString.concatList [privKeyLen, priv, msg])
        end

    fun sigCheck pub sign msg = 
        if BString.length pub <> pubkeyLen then
            raise (Err "Wrong public key size, Error in sigCheck FFI")
        else
            FFI.callBool ffi_sigCheck (BString.concatList [pub, sign, msg])

    fun randomBytes len =
        FFI.call ffi_randomBytes len (BString.nulls len)

    end
end