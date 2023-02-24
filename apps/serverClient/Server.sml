(* Depends on: util, copland, system/sockets, am/Measurementsm am/CommTypes,
   am/ServerAm *)

(* When things go well, this returns a JSON evidence string. When they go wrong,
   it returns a raw error message string. In the future, we may want to wrap
   said error messages in JSON as well to make it easier on the client. *)
fun evalJson s =
    let val (REQ pl1 pl2 pMap t ev) = jsonToRequest (strToJson s)
        val me = O (* TODO: hardcode ok? *)
        val ev' = run_cvm_rawEv t me ev
     in jsonToStr (responseToJson (RES pl2 pl1 ev'))
    end
    handle Json.Exn s1 s2 =>
            (TextIO.print_err (String.concat ["JSON error", s1, ": ", s2, "\n"]);
             "Invalid JSON/Copland term")
                (*
         | USMexpn s =>
            (TextIO.print_err (String.concat ["USM error: ", s, "\n"]);
            "USM failure")   *)



              

fun respondToMsg client = Socket.output client (evalJson (Socket.inputAll client))
                                           

fun handleIncoming listener =
    let val client = Socket.accept listener
     in respondToMsg client;
        Socket.close client
    end
    handle Socket.Err s     => TextIOExtra.printLn_err ("Socket failure: " ^ s)
         | Socket.InvalidFD => TextIOExtra.printLn_err "Invalid file descriptor"


                                                       

(* (string, string) map -> (string -> 'a option) -> ('a -> string) -> string -> 'a -> 'a *)
fun lookupOrDefault ini read write k default =
    case Map.lookup ini k of
      None => (
          TextIOExtra.printLn ("No field \"" ^ k ^ "\", defaulting to " ^ write default ^ ".");
          default
      )
    | Some v => (
        case read v of
          None => (
              TextIOExtra.printLn ("Cannot read \"" ^ k ^ "\", defaulting to " ^ write default ^ ".");
              default
          )
        | Some r => r
      )

(* (string, string) map -> () *)
fun startServer ini =
    let val port = lookupOrDefault ini Int.fromString Int.toString "port" 5000
        val qLen = lookupOrDefault ini Int.fromString Int.toString "queueLength" 5
     in case iniServerAm ini of 
          Err e => TextIOExtra.printLn_err e
        | Ok _ => loop handleIncoming (Socket.listen port qLen)
    end
    handle Socket.Err s => TextIO.print_err ("Socket failure on listener instantiation: " ^ s ^ "\n")
         | Crypto.Err s => TextIO.print_err ("Crypto error: " ^ s ^ "\n")
         | _          => TextIO.print_err "Fatal: unknown error\n"

(* () -> () *)
fun main () =
    let val name  = CommandLine.name ()
        val usage = "Usage: " ^ name ^ " configurationFile\n"
                  ^ "e.g.   " ^ name ^ " config.ini\n"
     in case CommandLine.arguments () of
              [fileName] => (
                  case parseIniFile fileName of
                    Err e  => TextIOExtra.printLn_err e
                  | Ok ini => startServer ini
              )
           | _ => TextIO.print_err usage
    end
val () = main ()
