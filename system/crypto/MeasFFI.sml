(* Depends on: ByteString.sml *)

(* Safe wrappers to FFI meas functions *)
structure Meas = struct
    exception Err string

    local
        val ffiSuccess = Word8.fromInt 0
        val ffiFailure = Word8.fromInt 1
        val ffiBufferTooSmall = Word8.fromInt 2

        val null = Char.chr 0
        val nullStr = String.str null
    in
        fun hashFile filename =
            let val buffer = Word8Array.array 65 (Word8.fromInt 0)
                val result = Word8Array.array 64 (Word8.fromInt 0)
             in #(fileHash) filename buffer;
                if Word8Array.sub buffer 0 = ffiFailure
                    then raise (Err ("hashFile FFI Failure, perhaps could not find file: " ^ filename))
                    else (Word8Array.copy buffer 1 64 result 0; result)
            end
       
        (* pid in decimal, start and end in hex *)
        (* string -> string -> string -> ByteString.bs *)
        fun hashRegion pid startAddr endAddr =
            let val buffer = Word8Array.array 65 (Word8.fromInt 0)
                val result = Word8Array.array 64 (Word8.fromInt 0)
                val input  = pid ^ nullStr ^ startAddr ^ nullStr ^ endAddr
             in #(hashRegion) input buffer;
                if Word8Array.sub buffer 0 = ffiFailure
                    then raise (Err "hashRegion FFI Failure, perhaps did not have privileges")
                    else (Word8Array.copy buffer 1 64 result 0; result)
            end

        datatype entryType =
              Unknown
            | Reg 
            | Dir 
            | Fifo 
            | Sock 
            | Chr 
            | Blk 
            | Lnk

        local 
            val unknown = Char.chr 1
            val reg     = Char.chr 2
            val dir     = Char.chr 3
            val fifo    = Char.chr 4
            val sock    = Char.chr 5
            val chr     = Char.chr 6
            val blk     = Char.chr 7
            val lnk     = Char.chr 8
            val parseResult = 
                let fun toEntryType enc =
                        if enc = unknown   then Unknown
                        else if enc = reg  then Reg
                        else if enc = dir  then Dir
                        else if enc = fifo then Fifo
                        else if enc = sock then Sock
                        else if enc = chr  then Chr
                        else if enc = blk  then Blk
                        else if enc = lnk  then Lnk
                        else raise (Err "readDir FFI failure, unrecognized entry type")
                    fun decodeEntry str = (String.extract str 1 None, toEntryType (String.sub str 0))
                 in List.map decodeEntry o String.tokens (op = null)
                end
        in 
            (* readDir : string -> (string * entryType) list *)
            fun readDir dirName = 
                let fun go bufLen = 
                        let val buffer = Word8Array.array bufLen (Word8.fromInt 0)
                            val _ = #(readDir) dirName buffer;
                            val ffiResult = Word8Array.sub buffer 0 
                         in if ffiResult = ffiSuccess then 
                                parseResult (Word8Array.substring buffer 1 (bufLen-1))
                            else if ffiResult = ffiBufferTooSmall then 
                                go (bufLen * 2)
                            else
                                raise (Err "readDir FFI failure, perhaps not a directory")
                        end
                 in go 256
                end
        end

        (* version of readDir that filters out the "." and ".." entries *)
        val readDirNoDot = List.filter (fn (n,t) => n <> "." andalso n <> "..") o readDir
    end
end
