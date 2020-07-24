(* Depends on: ByteString.sml *)

(* Safe wrappers to FFI meas functions *)
structure Meas = struct
    exception Err string

    local
        val ffiSuccess = Word8.fromInt 0
        val ffiFailure = Word8.fromInt 1
    in
        fun hashFile filename =
            let val buffer = Word8Array.array 65 (Word8.fromInt 0)
                val result = Word8Array.array 64 (Word8.fromInt 0)
             in #(fileHash) filename buffer;
                if Word8Array.sub buffer 0 = ffiFailure
                    then raise (Err ("hashFile FFI Failure, perhaps could not find file: " ^ filename))
                    else (Word8Array.copy buffer 1 64 result 0; result)
            end

        fun hashDir path exclPath =
            let val buffer = Word8Array.array 65 (Word8.fromInt 0)
                val result = Word8Array.array 64 (Word8.fromInt 0)
                val null_byte_s = String.str (Char.chr 0)
                val input = path ^ null_byte_s ^ exclPath ^ null_byte_s
             in #(dirHash) input buffer;
                if Word8Array.sub buffer 0 = ffiFailure
                    then raise (Err ("hadhDir FFI Failure, perhaps could not find directory: " ^ path))
                    else (Word8Array.copy buffer 1 64 result 0; result)
            end

        (* pid in decimal, addr and len in hex *)
        (* string -> string -> string -> ByteString.bs *)
        fun hashRegion pid addr len =
            let val buffer = Word8Array.array 65 (Word8.fromInt 0)
                val result = Word8Array.array 64 (Word8.fromInt 0)
                val null   = String.str (Char.chr 0)
                val input  = pid ^ null ^ addr ^ null ^ len
             in #(hashRegion) input buffer;
                if Word8Array.sub buffer 0 = ffiFailure
                    then raise (Err ("hashRegion FFI Failure, perhaps did not have privileges"))
                    else (Word8Array.copy buffer 1 64 result 0; result)
            end
    end
end
