structure FFI = struct 
    (* NOTE: This type is 
      string (input) -> byte_array (output storage) -> unit *)
    type ffi = string -> byte_array -> unit

    val success = Word8.fromInt 0
    val failure = Word8.fromInt 1
    val bufferTooSmall = Word8.fromInt 2

    val resp_code_SUCCESS = Word8.fromInt 0

    val resp_code_FAILED_TO_READ_FILE = Word8.fromInt 237
    val resp_code_FAILED_TO_REALLOC_BUFFER = Word8.fromInt 238
    val resp_code_FAILED_TO_ALLOCATE_BUFFER = Word8.fromInt 239
    val resp_code_INSUFFICIENT_OUTPUT = Word8.fromInt 240
    val resp_code_NEED_MORE_THAN_32_BITS_FOR_LENGTH = Word8.fromInt 241

    val resp_code_FILE_READ_ERROR = Word8.fromInt 254
    val resp_code_FILE_CLOSE_ERROR = Word8.fromInt 255

    val resp_CODE_START : int = 0
    val resp_CODE_LEN : int = 1
    val output_LEN_START : int = 1
    val output_LEN_LEN : int = 4
    val header_END = 5

    (* ffi -> int -> bstring -> bstring *)
    fun call ffi len input = 
        let val out = Word8ArrayExtra.nulls len 
        in ffi (BString.toString input) out;
            BString.fromByteArray out
        end

    (* ffi -> int -> bstring -> bstring option *)
    fun callOpt ffi len input = 
        let val result = call ffi (len+1) input
         in if BString.hd result = success then
                Some (BString.tl result)
            else
                None
        end

    fun buffered_call ffi input =
        let 
          val output_LEN_START = 1
          val output_LEN_LEN = 4
          val buffer_id_START = 5
          val buffer_id_LEN = 4
          fun ffi_get_buffer_by_id x y = #(get_buffer_by_id) x y
          val len = BString.length input
          val out_len = 9 (* 1 byte for status, 4 bytes for buffer length, 4 bytes for buffer id *)
          (* make ffi call *)
          val out = call ffi out_len input
          val status = BString.hd out
        in
          (* check status *)
          if status <> success then
            raise (Exception ("FFI call failed with status: " ^ (Int.toString (Word8.toInt status))))
          else
            let 
              val buffer_len = BString.qword_to_int (BString.substring out output_LEN_START output_LEN_LEN)
              val buffer_id_slice = BString.substring out buffer_id_START buffer_id_LEN
              val buffer_id = BString.qword_to_int buffer_id_slice
              val _ = print ("Buffer ID: " ^ Int.toString buffer_id ^ "\n")
              val _ = print ("Buffer Length: " ^ Int.toString buffer_len ^ "\n")
            in
              (* Now call the buffer FFI function to get the actual data *)
              call ffi_get_buffer_by_id buffer_len buffer_id_slice
            end
        end

    (* ffi -> int -> bstring -> bstring option *)
    fun callOptFlex ffi defaultLen input = 
        let fun callOptFlex_aux len = 
                let val result = call ffi len input
                    val status = BString.hd result
                 in if status = success then 
                        Some (BString.tl result)
                    else if status = failure then 
                        None
                    else 
                        callOptFlex_aux (len*2)
                end
         in callOptFlex_aux defaultLen
        end
    
    (* ffi -> bstring -> bool *)
    fun callBool ffi input = BString.hd (call ffi 1 input) = success

    local 
        val wbuf = Word8ArrayExtra.nulls 2
    in
        (* int -> bstring *)
        fun n2w2 i = (
            Marshalling.n2w2 i wbuf 0;
            BString.fromByteArray wbuf
        )
    end

    (* string list -> bstring *)
    val nullSeparated = BString.concatList
                      o ListExtra.intersperse BString.nullByte
                      o List.map BString.fromString
end
