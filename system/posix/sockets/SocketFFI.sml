(* ZeroMQ FFI interface for CakeML *)

structure SocketFFI = struct
  exception Exception string

  local
    fun ffi_zmq_init x y = #(zmq_init) x y
    fun ffi_zmq_listen x y = #(zmq_listen) x y  
    fun ffi_zmq_connect x y = #(zmq_connect) x y
    fun ffi_zmq_send x y = #(zmq_send) x y
    fun ffi_zmq_recv x y = #(zmq_recv) x y
    fun ffi_zmq_close x y = #(zmq_close) x y
    fun ffi_zmq_cleanup x y = #(zmq_cleanup) x y

    datatype socket = Socket int
    
    fun getSocketId (Socket id) = id
    
    (* Track initialization state to avoid multiple init calls *)
    val zmq_initialized = Ref False
    
    (* Internal function to ensure ZMQ is initialized *)
    fun ensureInit () = 
      if not (!zmq_initialized) then
        (case FFI.callOpt ffi_zmq_init 0 BString.empty of
           Some _ => zmq_initialized := True
         | None => raise (Exception "Failed to initialize ZeroMQ"))
      else ()
  in
    type socket = socket

    (* Initialize ZeroMQ - call once at startup (now optional - auto-called) *)
    fun init () = ensureInit ()

    (* Create a server socket listening on port *)
    fun listen port = 
      let val _ = ensureInit ()
          val payload = BString.int_to_qword port
      in 
        case FFI.callOpt ffi_zmq_listen 4 payload of
          Some bsv => Socket (BString.qword_to_int bsv)
        | None => raise (Exception "Failed to create listening socket")
      end

    (* Connect to a server *)
    fun connect host port = 
      let val _ = ensureInit ()
          val payload = BString.concat (BString.int_to_qword port) (BString.fromString host)
      in 
        case FFI.callOpt ffi_zmq_connect 4 payload of
          Some bsv => Socket (BString.qword_to_int bsv)
        | None => raise (Exception ("Failed to connect to " ^ host ^ ":" ^ Int.toString port))
      end

    (* Send a message - much simpler than raw sockets! *)
    fun send socket msg = 
      let val socket_id = getSocketId socket
          val payload = BString.concat (BString.int_to_qword socket_id) (BString.fromString msg)
      in
        case FFI.callOpt ffi_zmq_send 0 payload of
          Some _ => ()
        | None => raise (Exception "Failed to send message")
      end

    (* Receive a message - ZeroMQ handles message boundaries automatically *)
    fun recv socket = 
      let val socket_id = getSocketId socket
          val payload = BString.int_to_qword socket_id
      in
        let val result = FFI.buffered_call ffi_zmq_recv payload
        in BString.toString result
        end
        handle _ => raise (Exception "Failed to receive message")
      end

    (* Close socket *)
    fun close socket = 
      let val socket_id = getSocketId socket
          val payload = BString.int_to_qword socket_id
      in
        case FFI.callOpt ffi_zmq_close 0 payload of
          Some _ => ()
        | None => raise (Exception "Failed to close socket")
      end

    (* Cleanup ZeroMQ - call at program exit *)
    fun cleanup () = 
      case FFI.callOpt ffi_zmq_cleanup 0 BString.empty of
        Some _ => ()
      | None => raise (Exception "Failed to cleanup ZeroMQ")

  end

end
