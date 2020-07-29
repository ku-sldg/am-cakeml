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

        (* fun hashDir path exclPath =
            let val buffer = Word8Array.array 65 (Word8.fromInt 0)
                val result = Word8Array.array 64 (Word8.fromInt 0)
                val input = path ^ nullStr ^ exclPath ^ nullStr
             in #(dirHash) input buffer;
                if Word8Array.sub buffer 0 = ffiFailure
                    then raise (Err ("hadhDir FFI Failure, perhaps could not find directory: " ^ path))
                    else (Word8Array.copy buffer 1 64 result 0; result)
            end *)
        
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
            val unknown = Word8.fromInt 0
            val reg     = Word8.fromInt 1
            val dir     = Word8.fromInt 2
            val fifo    = Word8.fromInt 3
            val sock    = Word8.fromInt 4
            val chr     = Word8.fromInt 5
            val blk     = Word8.fromInt 6
            val lnk     = Word8.fromInt 7
            val parseResult = 
                let fun toEntryType enc = case enc of
                          unknown => Unknown
                        | reg     => Reg 
                        | dir     => Dir 
                        | fifo    => Fifo 
                        | sock    => Sock 
                        | chr     => Chr 
                        | blk     => Blk 
                        | lnk     => Lnk 
                        | _ => raise (Err "readDir FFI failure, unrecognized entry type") 
                    fun decodeEntry str = (String.extract str 1 None, toEntryType (String.sub str 0))
                 in List.map decodeEntry o String.tokens (op = null)
                end
        in 
            (* readDir : string -> (string * entryType) list *)
            fun readDir dirName = 
                let fun go bufLen = 
                        let val buffer = Word8Array.array bufLen (Word8.fromInt 0)
                         in #(readDir) dirName buffer;
                            case Word8Array.sub buffer 0 of
                                  ffiSuccess => parseResult (Word8Array.substring buffer 1 (bufLen-1))
                                | ffiFailure => raise (Err "readDir FFI failure, perhaps not a directory")
                                | ffiBufferTooSmall => go (bufLen * 2)
                        end
                 in go 256
                end
        end

        (* version of readDir that filters out the "." and ".." entries *)
        val readDirNoDot = List.filter (fn (n,t) => n = "." orelse n = "..") o readDir
    end
end
