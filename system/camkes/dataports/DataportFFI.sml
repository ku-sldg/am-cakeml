(* Depends on: Util *)

exception DataportErr string

local 
    fun ffi_initDataports x y = #(initDataports) x y
    fun ffi_writeDataport x y = #(writeDataport) x y
    fun ffi_readDataport  x y = #(readDataport)  x y
    fun ffi_waitDataport  x y = #(waitDataport)  x y
    fun ffi_emitDataport  x y = #(emitDataport)  x y

    val connBiMap = Ref (BiMap.empty String.compare Int.compare : (string, int) BiMap.biMap)

    fun init () = FFI.call ffi_initDataports 0 BString.empty
in 
    (* initialize dataports on startup *)
    val _ = init ()

    (* () -> (string, int) BiMap.biMap *)
    fun getConns () = !connBiMap

    (* (string, int) BiMap.biMap -> () *)
    fun setConns bmap = connBiMap := bmap

    (* (string, int) list -> () *)
    val setConnsFromList = setConns o (BiMap.fromList String.compare Int.compare)

    (* string -> int -> bool *)
    fun addConn name id = 
        case BiMap.maybeInsert (!connBiMap) name id of 
          Some bmap => (
              connBiMap := bmap;
              True
          )
        | None => False

    (* int -> bstring -> () *)
    fun writeDataportId id msg =
        let val payload = BString.concat (FFI.n2w2 id) msg
         in if FFI.callBool ffi_writeDataport payload then () else raise DataportErr "write failure"
        end

    (* string -> bstring -> () *)
    fun writeDataport name msg =
        case BiMap.lookupl (!connBiMap) name of
          Some id => writeDataportId id msg
        | None => raise DataportErr "write failure"

    (* int -> int -> bstring *)
    fun readDataportId id len =
        case FFI.callOpt ffi_readDataport len (FFI.n2w2 id) of 
          Some bs => bs
        | None => raise DataportErr "read failure"

    (* string -> int -> bstring *)
    fun readDataport name len =
        case BiMap.lookupl (!connBiMap) name of
          Some id => readDataportId id len
        | None => raise DataportErr "read failure"
        
    (* int -> () *)
    fun waitDataportId id = 
        if FFI.callBool ffi_waitDataport (FFI.n2w2 id) then
            ()
        else
            raise DataportErr "wait failure"

    (* string -> () *)
    fun waitDataport name = 
        case BiMap.lookupl (!connBiMap) name of
          Some id => waitDataportId id
        | None => raise DataportErr "wait failure"

    (* int -> () *)
    fun emitDataportId id =
        if FFI.callBool ffi_emitDataport (FFI.n2w2 id) then
            ()
        else
            raise DataportErr "emit failure"

    (* string -> () *)
    fun emitDataport name =
        case BiMap.lookupl (!connBiMap) name of
          Some id => emitDataportId id
        | None => raise DataportErr "emit failure"
end
