(* Depends on util, copland, dataports, and timer *)

(* Config - ideally these things would be loaded in separately, either in a configuration file at 
       compile time, or read from a file at runtime *)
val pub = (ByteString.toRawString o ByteString.fromHexString) "490E2422528F14AC6A48DDB9D72CB30B8345AF2E939003BC7A33A6057F2FFB0101000000000000002DD0B7F53A560000A049D882A37F00000000000000000000"

val goldenHashes = 
    let val hash_gs_step2 = "540FD206F8B981BAE3EEB984F418ABE8B556CF63FE7A67EE8E1FEDB60780946EE6E235BFA439A924001E9676058245B70998A4749121994DAFE2C0CF6A154465"
        val hash_gs_threat_3A1 = "890F87D306C8201AE764FF91D116D413A8DAB71B5BF73370F35BCB24F9C38AB0720EA0E18C4C717D7782F818255DFA0D62D165E1DA2A705C71A260164BDEEDCB"
        val hash_gs_threat_3A2 = "E267FA81E1577C6373C84ECC6A5C5A364073D7DB2F3E5DCB44D7F93F9CF6F9F3D5C85C640140CF574DD31EFA2E16AA58FFC325397AE6753C503B058A0DFF3655"
     in [hash_gs_step2, hash_gs_threat_3A1, hash_gs_threat_3A2]
    end
(* End of config.  *)

(* loop : (() -> 'a) -> 'b *)
fun loop io = (io (); loop io)

(* when : bool -> ('a -> ()) -> 'a -> () *)
fun when b f x = if b then f x else ()

(* TODO: add timestamp *)
fun log s = print (s^"\n")

val idToBytes =
    let fun rightFourChars str =
        let val strSize = String.size str
         in case Int.compare strSize 4
            of Greater => String.extract str (strSize - 5) None
             | Equal   => str
             | Less    => rightFourChars ("0" ^ str)
         end
      in rightFourChars o Int.toString
    end


(* Truncates or appends a sequence of b *)
fun bsToLen len b bs =
    let val oldLen = ByteString.length bs
     in case Int.compare oldLen len
        of Greater => ByteString.fromRawString (String.substring (ByteString.toRawString bs) 0 len)
         | Equal   => bs
         | Less    => ByteString.append bs (Word8Array.array (len - oldLen) b)
    end

(* addToWhitelist : dataport -> id option -> () *)
(* Right now, this just writes over the first id, since we only have one groundstation *)
fun addToWhitelist dataport idOpt =
    let val id_list = case idOpt
            of Some id => idToBytes id
             | None    => "0"
        val zero = Word8.fromInt 48 (* ascii '0' char *)
        val content = bsToLen 12 zero (ByteString.fromRawString id_list)
     in log ("Writing " ^ ByteString.toRawString content ^ " to " ^ dataport);
        writeDataportBS dataport content
    end

(* pulse : int -> ('a -> 'b) -> 'a -> 'c *)
(* Takes a frequency (in microseconds), a function, and that function's argument.
   Repeatedly calls the function with the argument, on intervals defined by the
   frequency. *)
fun pulse freq f x =
    let val next = Ref (timestamp () + freq)
        fun spinUntil c = if c () then () else spinUntil c
     in loop (fn () => (
            f x;
            spinUntil (fn () => timestamp () >= !next);
            next := !next + freq
        ))
    end

(* parseEv : string -> ev *)
val parseEv =
    let fun strToJson str = List.hd (fst (Json.parse ([], str)))
     in jsonToEv o strToJson
    end

(* appraise : ByteString.bs -> ev -> bool *)
(* fun appraise nonce ev = case ev of
      G evSign (U (Id (S O)) args evHash (N i evNonce Mt)) =>
          ByteString.deepEq evNonce nonce andalso 
          List.exists (op = (ByteString.toHexString evHash)) goldenHashes andalso 
          Option.valOf (verifySig ev pub)
    | _ => False *)
fun appraise nonce ev = case ev of
      G evSign (U (Id (S O)) args evHash (N i evNonce Mt)) =>
          if not (ByteString.deepEq evNonce nonce) then 
              (log "Bad nonce"; False)
          else if not (List.exists (op = (ByteString.toHexString evHash)) goldenHashes) then 
              (log "Bad hash value"; False) 
          else if not (Option.valOf (verifySig ev pub)) then 
              (log "Bad signature"; False)
          else True
    | _ => (log "Bad evidence shape"; False)

(* reqAttest : dataport -> Socket.fd -> id -> () *)
fun reqAttest dataport gs id =
    let val nonce = genNonce ()
        val _ = Socket.output gs (ByteString.toRawString nonce)
        val ev = parseEv (Socket.inputAll gs)
        val spin = loop o const
     in if appraise nonce ev
          then (log "Appraisal succeeded"; addToWhitelist dataport (Some id))
          else (log "Appraisal failed"; addToWhitelist dataport None; spin ())
    end

(* mainLoop : string -> () *)
fun mainLoop dataport =
    let val _ = log ("Uav starting with dataport: " ^ dataport)
        val listener = Socket.listen 5000 5
        val _ = log "Listening on port 5000"
        val gs  = Socket.accept listener
        val _ = log "Accepting incoming connection"
        val msg = Socket.inputAll gs
        val id  = Option.valOf (Int.fromString msg) (* For now, we assume the initial message is just the id *)
        val _ = log ("Beginning appraisal loop with groundstation: " ^ msg)
     in pulse 10000 (fn () => reqAttest dataport gs id) ()
    end
    handle Socket.Err _ => TextIO.print_err "Socket error\n"
         | DataportErr  => TextIO.print_err "Dataport error\n"
         | Json.ERR _ _ => TextIO.print_err "Json error\n"
         | _            => TextIO.print_err "Fatal: unknown error\n"

fun main () =
    let val name  = CommandLine.name ()
        val usage = "Usage: " ^ name ^ " dataport\n"
                  ^ "e.g.   " ^ name ^ " /dev/uio4\n"
     in case CommandLine.arguments () of
              [dataport] => mainLoop dataport
            | _ => TextIO.print_err usage
    end
val () = main ()