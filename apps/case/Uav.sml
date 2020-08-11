(* Depends on util, copland, dataports, and timer *)

(* Config - ideally these things would be loaded in separately, either in a configuration file at 
       compile time, or read from a file at runtime *)
val pub = (ByteString.toRawString o ByteString.fromHexString) "490E2422528F14AC6A48DDB9D72CB30B8345AF2E939003BC7A33A6057F2FFB0101000000000000002DD0B7F53A560000A049D882A37F00000000000000000000"

val goldenUxasHashes = 
    let val hash_gs_step2 = "DA6E955AC98F83C65806E2B45A6E6D58BD570930F07E957E7B0ADF0EA09B2E1DB18780897B596B97A20D429638C7E163CDAF9B594201D57689DF4D1B385DFAC4"
        val hash_gs_threat_3A1 = "20C78BA379D880C192691431A704D5F4A96AD76470D6F9E1D576640CD43A5516A38B53E740F9C77ABAC4DB53AB336B34F8F9330EAE43A43E5CCC8B45CA5D6837"
        val hash_gs_threat_3A2 = "7312F44ED8761A21F4C3597E45B8774277B73DDF4EA0133E9FAFE11912B19EC71441E05DB3EEB5D58C0C1D3E7ABE4ED70BF99AFCF39E0081AEE42F3028CAB8F1"
     in [hash_gs_step2, hash_gs_threat_3A1, hash_gs_threat_3A2]
    end

val goldenDirHashes = 
    let val hash_gs_step2 = "1A02BD2959EBDD7371803A2D8D2FEA6BC1D119D8C7F3DB053A3A2C13960CD1B698DAB0ED87FC73E34350C84534BC0CADEEF909A4BF451E85A9E42E9BEA01E9F8"
        val hash_gs_threat_3A1 = "B94950EB5CBFB74E5EE4285F980BCF470D0F2391DDD2DA33BBB68CB7F918ED054BED85B638B799FD2D268F83AAA943A93C760F43823736D53719D363AAA880E9"
        val hash_gs_threat_3A2 = "F5E7C64E438243431DA725995C708F25FE9969071066ACD3E120AE9F5FB4C3735A0CE4AB2C77B5641AECB0AEAD98C283E831DF13D2E10BC5943E6BA93C09F093"
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
fun appraise nonce ev = case ev of
      G evSign
      (U (Id (S (S O))) uxasArgs uxasHash 
      (U (Id (S O)) dirHashArgs dirHash
      (N i evNonce Mt))) =>
          if not (ByteString.deepEq evNonce nonce) then 
              (log "Bad nonce"; False)
          else if not (List.exists (op = (ByteString.toHexString uxasHash)) goldenUxasHashes) then 
              (log "Bad uxas hash"; False)
          else if not (List.exists (op = (ByteString.toHexString dirHash)) goldenDirHashes) then 
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