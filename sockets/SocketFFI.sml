(* Depends on: ByteString.sml *)

(* Safe(ish) wrappers to FFI socket functions *)

(* File descriptors (fd) are in the same format as used by the basis library,
   i.e. strings derived from 8 byte encodings of integers. Unfortunately, it is
   not possible to use TextIO's functions, since they use types whose
   constructors are defined locally. So, we will have to redefine file
   operations here. *)
structure Socket = struct
    (* Takes a port number and maximum queue length, and returns the fd of a new
       actively listening socket *)
    fun listen port qLen =
        let
            val fdbuf = Word8Array.array 8 (Word8.fromInt 0)
            val cbuf = Word8Array.array 2 (Word8.fromInt 0)
            val _ = Marshalling.n2w2 qLen cbuf 0
            val c = (ByteString.toRawString cbuf) ^ (Int.toString port)
            val _ = #(listen) c fdbuf
        in
            ByteString.toRawString fdbuf
        end

    (* Takes the fd of an actively listening socket, returns the fd of a connection *)
    (* Blocks until there is an incoming connection *)
    fun accept sockfd =
        let
            val fdbuf = Word8Array.array 8 (Word8.fromInt 0)
            val _ = #(accept) sockfd fdbuf
        in
            ByteString.toRawString fdbuf
        end

    (* Takes the host as a string, in the format of a domain name or IPv4 address,
       and port, and integer corresponding to a port number. Returns a fd. *)
    fun connect host port =
        let
            val fdbuf = Word8Array.array 8 (Word8.fromInt 0)
            val null = String.str (Char.chr 0)
            val c = host ^ null ^ (Int.toString port) ^ null
            val _ = #(connect) c fdbuf
        in
            ByteString.toRawString fdbuf
        end

    (* Returns a pretty string for debug printing file descriptors *)
    val fdToString = ByteString.toString o ByteString.fromRawString

    (* The following code is taken almost verbatim from the basis library, but
       stripped of the instream/outstream constructors. Specifically, taken
       from the follwing commit:
https://github.com/CakeML/cakeml/commit/b2076e74977d96b0734bd1ab2ae59ef1f91c3004 *)

    exception InvalidFD

    local
        val iobuff = Word8Array.array 2052 (Word8.fromInt 0)
    in
        (* Write functions *)
        local
            fun writei fd n i =
                let val a = Marshalling.n2w2 n iobuff 0
                    val a = Marshalling.n2w2 i iobuff 2
                    val a = #(write) fd iobuff in
                    if Word8Array.sub iobuff 0 = Word8.fromInt 1
                    then raise InvalidFD
                    else
                      let val nw = Marshalling.w22n iobuff 1 in
                        if nw = 0 then writei fd n i
                        else nw
                      end
                end
            fun write fd n i =
              if n = 0 then () else
                let val nw = writei fd n i in
                    if nw < n then write fd (n-nw) (i+nw) else () end
        in
            fun output fd s =
                if s = "" then () else
                let val z = String.size s
                    val n = if z <= 2048 then z else 2048
                    val fl = Word8Array.copyVec s 0 n iobuff 4
                    val a = write fd n 0 in
                        output fd (String.substring s n (z-n))
                end
        end

        (* Read functions *)
        local
            fun read fd n =
                let val a = Marshalling.n2w2 n iobuff 0 in
                      (#(read) fd iobuff;
                      if Word8.toInt (Word8Array.sub iobuff 0) <> 1
                      then Marshalling.w22n iobuff 1
                      else raise InvalidFD)
                end

            fun input fd buff off len =
                let fun input0 off len count =
                    let val nread = read fd (min len 2048) in
                        if nread = 0 then count else
                          (Word8Array.copy iobuff 4 nread buff off;
                           input0 (off + nread) (len - nread) (count + nread))
                    end
                in input0 off len 0 end

            fun extend_array arr =
                let
                    val len = Word8Array.length arr
                    val arr' = Word8Array.array (2*len) (Word8.fromInt 0)
                in (Word8Array.copy arr 0 len arr' 0; arr') end
        in
            fun inputAll fd =
                let
                    fun inputAll_aux arr i =
                        let val len = Word8Array.length arr in
                            if i < len then
                                let
                                    val n = input fd arr i (len - i)
                                in
                                    if n = 0 then Word8Array.substring arr 0 i
                                    else inputAll_aux arr (i + n)
                                end
                            else inputAll_aux (extend_array arr) i
                        end
                in inputAll_aux (Word8Array.array 127 (Word8.fromInt 0)) 0 end
        end

        (* Close function *)
        fun close fd =
            let val a = #(close) fd iobuff in
            if Word8Array.sub iobuff 0 = Word8.fromInt 0
            then () else raise InvalidFD
        end
    end
end
