local 
    fun ffi_system x y = #(system) x y
    fun ffi_popen_string x y = #(popen_string) x y
in
    (* () -> int *)
    fun c_system (com) = 
      let val bs = BString.fromString com 
      in
        BString.toInt BString.LittleEndian (FFI.call ffi_system (BString.length bs) bs)
      end
    
    (* () -> string *)
    fun c_popen_string (com) = 
      let val command_bs = BString.fromString com
          val default_RESP_SIZE = 1024
          val resp_bs = FFI.callVariableResp ffi_popen_string default_RESP_SIZE command_bs
      in 
        BString.toString resp_bs
      end
      handle Undef => raise (Exception "UNDEF Error Stemming from c_popen_string")
          | Result.Exn => raise (Exception "Result.Exn Error Stemming from c_popen_string")
          | Word8Extra.InvalidHex => raise (Exception "InvalidHex Error Stemming from c_popen_string")
          | _ => raise (Exception "Unknown Error thrown from c_popen_string, likely check that the word8 array is right length that is expected and not accessing something outside of its bounds")

end
