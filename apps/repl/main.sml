(* am -> () *)
fun replPrompt am = (
    print "> ";
    case TextIO.inputLine TextIO.stdIn of
      None => TextIOExtra.printLn_err "Could not read line from stdin"
    | Some line => (
        (* case Parser.parse coplandP line of *)
        case parseTerm line of
          Err e => TextIOExtra.printLn_err ("Parsing failed with message: " ^ e)
        | Ok term => TextIOExtra.printLn (evToString (evalTerm am Mt term))
    ) handle USMexpn     s => TextIOExtra.printLn_err ("USM error: "^ s)
           | DispatchErr s => TextIOExtra.printLn_err ("Dispatch error: " ^ s)
           | Socket.Err  s => TextIOExtra.printLn_err ("Socket failure on connection: " ^ s)
           | Socket.InvalidFD => TextIOExtra.printLn_err "Invalid file descriptor"
           | _ => TextIOExtra.printLn_err "Fatal, unknown error"
)
(* am -> bot *)
fun repl am = loop replPrompt am

(* () -> () *)
fun main () =
    let val name  = CommandLine.name ()
        val usage = "Usage: " ^ name ^ " configurationFile\n"
                  ^ "e.g.   " ^ name ^ " config.ini\n"
     in case CommandLine.arguments () of
              [fileName] => (
                  case Result.bind (parseIniFile fileName) iniServerAm of
                    Err e => TextIOExtra.printLn_err e
                  | Ok am => repl am
              )
           | _ => TextIO.print_err usage
    end
val () = main ()
   