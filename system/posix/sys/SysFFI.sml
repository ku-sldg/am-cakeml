local 
    fun ffi_system x y = #(system) x y

    fun ffi_popen x y = #(popen) x y
in
    (* () -> int *)
    fun c_system (com) = 
      let val bs = BString.fromString com 
      in
        BString.toInt BString.LittleEndian (FFI.call ffi_system (BString.length bs) bs)
      end

    fun system_exec (com) =
      (let val bs = BString.fromString com
      in
        FFI.call ffi_popen (BString.length bs) bs
      end) : BString.bstring
end
