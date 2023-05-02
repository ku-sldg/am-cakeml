local 
    fun ffi_system x y = #(system) x y
in
    (* () -> int *)
    fun c_system (com) = 
      let val bs = BString.fromString com 
      in
        BString.toInt BString.LittleEndian (FFI.call ffi_system (BString.length bs) bs)
      end
end
