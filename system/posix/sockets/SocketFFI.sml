(* Depends on: Util *)

(* Safe(ish) wrapper to FFI socket functions *)
structure Socket = struct
    (* Generic socket exception *)
    exception Err string

    local
        datatype sockfd = Fd BString.bstring
        fun getFd (Fd s) = s
        fun getFdString (Fd s) = (BString.toString s)

        fun ffi_listen  x y = #(listen)  x y
        fun ffi_accept  x y = #(accept)  x y
        fun ffi_connect x y = #(connect) x y
    in
        type sockfd = sockfd

        fun write fd n i =
          if n = 0 then () else
          let val nw = writei fd n i 
          in
            if nw < n then write fd (n-nw) (i+nw) else ()
          end
      in
        fun output fd s =
          if s = "" then () else
          let val z = String.size s
              val n = if z <= 2048 then z else 2048
              val fl = Word8Array.copyVec s 0 n iobuff 4
              val a = write (getFdString fd) n 0 
          in
            output fd (String.substring s n (z-n))
          end
      end

      (* Read functions *)
      local
        fun read fd n =
          let 
            val _ = print ("Listening for bytes (in read) with n = " ^ (Int.toString n) ^ "\n")
            (* val _ = print ("FD: " ^ (getFdString fd) ^ "\n") *)
            (* val _ = print ("Read pre marshal: " ^ (Word8Array.substring iobuff 0 n) ^ "\n") *)
            val a = Marshalling.n2w2 n iobuff 0 
            (* val _ = print ("Read post marshal: " ^ (Word8Array.substring iobuff 0 n) ^ "\n") *)
          in
            (#(read) fd iobuff;
            (let val _ = print ("Read post read: " ^ (Word8Array.substring iobuff 0 n) ^ "\n")
            in
            if Word8.toInt (Word8Array.sub iobuff 0) <> 1
            then 
              let val _ = print ("Listening for bytes (in read) with non error\n")
              in
              Marshalling.w22n iobuff 1
              end
            else 
              let val _ = print ("Listening for bytes (in read) with error\n")
              in
                raise InvalidFD
              end
            end))
          end

          fun input fd buff off len =
            let fun input0 off len count =
              let val _ = print ("Listening for bytes (in input0) with off = " ^ (Int.toString off) ^ "\n")
                  val nwant = min len 2048
                  val _ = print ("input0: NWANT: " ^ (Int.toString nwant) ^ "\n")
                  val nread = read fd nwant
                  val _ = print ("input0: NREAD: " ^ (Int.toString nread) ^ "\n")
              in
                if nread = 0 
                then 
                  let val _ = print ("Listening for bytes (in input0) with nread = 0\n")
                  in
                  count 
                  end
                else
                  let val _ = print ("Listening for bytes (in input0) with nread > 0\n")
                  in
                  (Word8Array.copy iobuff 4 nread buff off;
                    let val _ = print ("Listening for bytes (in input0) with nread > 0 and copied bytes\n")
                        val _ = print ("BUFF: " ^ (Word8Array.substring buff off nread) ^ "\n")
                        val _ = print ("OFF: " ^ (Int.toString off) ^ "\n")
                        val _ = print ("NREAD: " ^ (Int.toString nread) ^ "\n")
                        val _ = print ("NWANT: " ^ (Int.toString nwant) ^ "\n")
                    in
                    if nread < nwant 
                    then 
                      let val _ = print ("Listening for bytes (in input0) with nread < nwant\n")
                      in count+nread 
                      end
                    else 
                      let val _ = print ("Listening for bytes (in input0) with nread >= nwant\n")
                      in
                      input0 (off + nread) (len - nread) (count + nread)
                      end
                    end
                  )
                  end
              end
            in input0 off len 0 
            end

          fun extend_array arr =
              let val len = Word8Array.length arr
                  val arr' = Word8Array.array (2*len) (Word8.fromInt 0)
              in 
                (Word8Array.copy arr 0 len arr' 0; arr') 
              end
      in
        fun inputAll fd =
          let fun inputAll_aux arr i =
            let 
                val len = Word8Array.length arr 
                val _ = print ("Current Length of array: " ^ (Int.toString len) ^ "\n")
                val _ = print ("Listening for bytes (in inputAll_aux) with i = " ^ (Int.toString i) ^ "\n")
            in
              if i < len then
                let val _ = print ("Listening for bytes (in inputAll_aux) with i < len\n")
                    val nwant = len - i
                    val _ = print ("NWANT: " ^ (Int.toString nwant) ^ "\n")
                    val _ = print ("I: " ^ (Int.toString i) ^ "\n")
                    val _ = print ("LEN: " ^ (Int.toString len) ^ "\n")
                    val _ = print ("FD: " ^ (getFdString fd) ^ "\n")
                    val _ = print ("ARR: " ^ (Word8Array.substring arr 0 len) ^ "\n")
                    val nread = input (getFdString fd) arr i nwant
                    val _ = print ("NREAD: " ^ (Int.toString nread) ^ "\n")
                in
                  if nread < nwant 
                  then 
                    let val _ = print ("Listening for bytes (in inputAll_aux) with nread < nwant\n")
                    in
                      Word8Array.substring arr 0 (i+nread)
                    end
                  else 
                    let val _ = print ("Listening for bytes (in inputAll_aux) with nread >= nwant\n")
                    in 
                      inputAll_aux arr (i + nread)
                    end
                end
              else 
                let val _ = print ("Listening for bytes (in inputAll_aux) with i >= len\n")
                in
                  inputAll_aux (extend_array arr) i
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
                        let val nwant = min len 2048
                            val nread = read fd nwant
                        in
                            if nread = 0 then count else
                            (Word8Array.copy iobuff 4 nread buff off;
                                if nread < nwant then count+nread else
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
                    let fun inputAll_aux arr i =
                            let val len = Word8Array.length arr in
                                if i < len then
                                    let
                                        val nwant = len - i
                                        val nread = input (getFdString fd) arr i nwant
                                    in
                                        if nread < nwant then Word8Array.substring arr 0 (i+nread)
                                        else inputAll_aux arr (i + nread)
                                    end
                                else inputAll_aux (extend_array arr) i
                            end
                    in inputAll_aux (Word8Array.array 127 (Word8.fromInt 0)) 0 end
            end

            (* Close function *)
            fun close fd =
                let val a = #(close) (getFdString fd) iobuff in
                if Word8Array.sub iobuff 0 = Word8.fromInt 0
                then () else raise InvalidFD
            end
        end
    end
end
