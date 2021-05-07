(* Depends on copland, sockets, am, protocol *)

(* loop : ('a -> 'b) -> 'a -> 'c *)
fun loop f x = (f x; loop f x)

datatype logType = Info | Debug | Error

(* logType -> String -> () *)
(* Add timestamp? *)
fun log lType msg = case lType of
      Info  => TextIO.print (msg ^ "\n")
    | Debug => TextIO.print (msg ^ "\n")
    | Error => TextIO.print_err (msg ^ "\n")

(* 'b -> ('a -> 'b) 'a option -> 'b *)
fun option b f opt = case opt of 
      Some a => f a 
    | None   => b

(* 'a option -> ('a -> ()) -> () *)
fun whenSome opt io = option () io opt
(* val whenSome = flip (option ())  *)

local
    (* Placeholder value. *)
    val priv = (ByteString.toRawString o ByteString.fromHexString)
               "2E5773B2A19A2CB05FEE44650D8DC877B3D806F74C199043657C805288CD119B"
    val am = serverAm priv emptyNsMap
in
    (* attest : Socket.fd -> () *)
    (* loops unless timeout *)
    fun attestLoop heliAM = whenSome (Socket.inputAllTimeout heliAM) (fn input => (
        let val nonce  = N (Id O) (ByteString.fromRawString input) Mt
            val _      = checkRestartVdtu ()
            val ev     = (evalTerm am nonce protocol) handle _ => (log Error "Protocol evaluation failed"; Mt)
            val jsonEv = jsonToStr (evToJson ev)
                       ^ (String.str (Char.chr 0)) (* append explicit null-byte *)
         in log Info ("Sending evidence: " ^ evToString ev);
            Socket.output heliAM jsonEv;
            attestLoop heliAM
        end
    ))
end

(* mainLoop : string -> int -> () *)
fun mainLoop addr port = (
    checkRestartVdtu ();
    whenSome (Socket.connect addr port) (fn heliAM => (
        log Info "Connected to HeliAM";
        attestLoop heliAM;
        log Info "HeliAM timeout, closing connection.";
        Socket.close heliAM
    ));
    mainLoop addr port
) handle 
      Socket.Err err => (log Error ("Socket error: " ^ err); mainLoop addr port)
    | Socket.InvalidFD => (log Error ("Socket error: invalid file descriptor"); mainLoop addr port)
    | _ => log Error "Fatal: unknown error"

fun init addr port = (
    startVdtu;
    mainLoop addr port
)

fun main () =
    let val name  = CommandLine.name ()
        val usage = "Usage: " ^ name ^ " address port\n"
                  ^ "e.g.   " ^ name ^ " 192.168.2.7 5000\n"
     in (case CommandLine.arguments () of
              [addr, portStr] => case Int.fromNatString portStr of
                Some port => init addr port
              | None      => TextIO.print usage
            | _ => TextIO.print usage
        ) handle _ => TextIO.print usage
    end
val _ = main ()

(*
fun waitForTerminate pid = if Meas.childTerminated pid then () else waitForTerminate pid

val () = 
    let val pid = Meas.newProc "/mnt/c/Users/Grant/linux/lab/am-cakeml-case2/apps/case2/spin"
     in print (pid ^ "\n");
        waitForTerminate pid;
        print "Child terminated\n"
    end
*)