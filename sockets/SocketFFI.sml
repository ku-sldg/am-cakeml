(* Depends on: ByteString.sml *)

(* Safe(ish) wrappers to FFI socket functions *)

(* TODO: create a Socket structure? *)
(* File descriptors (fd) are in the same format as used by the basis library,
   i.e. strings derived from 8 byte encodings of integers.
   Use TextIO's functions to read/write/close sockets. *)

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
