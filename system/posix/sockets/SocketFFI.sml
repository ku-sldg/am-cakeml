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
    fun ffi_socket_close   x y = #(socket_close)   x y
    fun ffi_connect x y = #(connect) x y
    fun ffi_get_message_length x y = #(socket_get_message_length) x y
    fun ffi_socket_write x y = #(socket_write) x y
    fun ffi_socket_read x y = #(socket_read) x y
  in
    type sockfd = sockfd

    (* int -> int -> sockfd *)
    (* Takes a port number and maximum queue length, and returns the fd of a new actively listening socket *)
    fun listen port qLen = 
      let val payload = BString.concat (BString.int_to_qword qLen) (BString.int_to_qword port)
      in 
        case FFI.callOpt ffi_listen 4 payload of 
          Some bsv => Fd bsv
        | None => raise (Err "Error in listen()")
      end

    (* sockfd -> sockfd *)
    (* Takes the fd of an actively listening socket, returns the fd of a connection *)
    (* Blocks until there is an incoming connection *)
    fun accept sockfd = 
      case FFI.callOpt ffi_accept 4 (getFd sockfd) of 
        Some bsv => Fd bsv
      | None => raise (Err "Error in accept()")

    (* string -> int -> sockfd *)
    (* Takes the host in the format of a domain name or IPv4 address,
        and port, an integer corresponding to a port number. Returns a fd. *)
    fun connect host port = 
      let 
        val payload = BString.concat (BString.int_to_qword port) (BString.concat (BString.fromString host) BString.nullByte)
      in 
        case FFI.callOpt ffi_connect 4 payload of 
          Some bsv => Fd bsv
        | None => raise (Err "Error in connect()")
      end

    (* sockfd -> int *)
    (* Take in a socket FD and return the size of the message that is pending read in the FD *)
    fun get_message_length fd = 
      case FFI.callOpt ffi_get_message_length 4 (getFd fd) of 
        Some bsv => BString.qword_to_int bsv
      | None => raise (Err "Error in get_message_length()")

    (* sockfd -> string -> int (# bytes written) *)
    (* Takes a socket fd and a string to write the socket
       should always return `n` s.t. `n` = length s
       Unless an error occured *)
    fun write fd s = 
      let 
        val payload = BString.concat (getFd fd) (BString.fromString s)
      in
        case FFI.callOpt ffi_socket_write 4 payload of 
          Some bsv => BString.qword_to_int bsv
        | None => raise (Err "Error in write()")
      end

    (* sockfd -> string *)
    fun read fd = 
      let 
        (* first we want to see the incoming msg size *)
        val msg_size = get_message_length fd
        val payload = BString.concat (getFd fd) (BString.int_to_qword msg_size)
      in
        case FFI.callOpt ffi_socket_read msg_size payload of
          Some bsv => 
          (* bsv contains how much was read, which should = msg_size *)
          if BString.length bsv = msg_size
          then (BString.toString bsv)
          else raise (Err "Error in read(), we did not read all the bytes")
        | None => raise (Err "Error in read()")
      end

    (* sockfd -> unit *)
    fun close fd = 
      let 
        val payload = getFd fd
      in
        case FFI.callOpt ffi_socket_close 0 payload of 
          Some bsv => ()
        | None => raise (Err "Error in close()")
      end

  end 
end
