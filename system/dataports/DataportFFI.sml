(* Depends on: ByteString.sml *)

exception DataportErr

(* writeDataport : String -> String -> () *)
local
    val null = String.str (Char.chr 0)
in
    fun writeDataport name msg =
        let val result = Word8Array.array 1 (Word8.fromInt 0)
         in #(writeDataport) (name ^ null ^ msg) result;
            if Word8Array.sub result 0 = Word8.fromInt 1
                then raise DataportErr
                else ()
        end
end

(* writeDataportBS : String -> ByteString.BS -> () *)
val writeDataportBS = writeDataport o ByteString.toRawString


fun emitEvent dummy =
    let
        val result = Word8Array.array 1 (Word8.fromInt 0)
    in
        #(emit_event) dummy result
    end

fun dataportWrite msg =
    let
        val result = Word8Array.array 1 (Word8.fromInt 0)
        val dummy = "test"
    in 
        #(dataport_write) msg result;
        if Word8Array.sub result 0 = Word8.fromInt 1
        then raise DataportErr
        else emitEvent dummy; ()
    end
fun dataportRead msg =
    let
        val result = Word8Array.array 1 (Word8.fromInt 0)
    in
        #(dataport_read) msg result;
        if Word8Array.sub result 0 = Word8.fromInt 1
        then raise DataportErr
        else ()
    end
val dataportReadBS = writeDataport o ByteString.toRawString
val dataportWriteBS = writeDataport o ByteString.toRawString

