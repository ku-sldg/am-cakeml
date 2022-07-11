(* Depends on: util, copland, am/Measurements, am/ServerAm *)

val dir = "testDir"

val subterm = (Asp (Aspc (Id (S O)) [dir]))
val term = Att (S O) (Lseq subterm (Asp Sig))

val goldenHash = BString.unshow "7BE9FDA48F4179E611C698A73CFF09FAF72869431EFEE6EAAD14DE0CB44BBF66503F752B7A8EB17083355F3CE6EB7D2806F236B25AF96A24E22B887405C20081"

fun appraise nonce pub ev = case ev of
      G evSign (U (Id (S O)) [dir] evHash (N (Id O) evNonce Mt)) =>
          if evNonce <> nonce then
              Err "Bad nonce value"
          else if evHash <> goldenHash then
              Err "Bad hash value"
          else if not (Option.valOf (verifySig ev pub)) then
              Err "Bad signature"
          else Ok ()
    | _ => Err "Unexpected shape of evidence"

(* am -> BString.bstring -> () *)
fun sendReq am key = 
    let val nonce = Random.random (Random.seed (Meas.urand 32)) 16
        val ev    = evalTerm am (N (Id O) nonce Mt) term
     in print ("Evaluating term:\n" ^ termToString term ^ "\n\nNonce:\n" ^
               BString.show nonce ^ "\n\nEvidence recieved:\n" ^
               evToString ev ^ "\n\nAppraisal " ^ (
               case appraise nonce key ev of
                      Ok ()   => "succeeded (expected nonce and hash value; signature verified).\n"
                    | Err msg => "failed: " ^ msg ^ "\n")
              )
    end
    handle Socket.Err s     => TextIOExtra.printLn_err ("Socket failure on connection: " ^ s)
         | Socket.InvalidFD => TextIOExtra.printLn_err "Invalid file descriptor"
         | DispatchErr s    => TextIOExtra.printLn_err ("Dispatch error: " ^ s)
         | _                => TextIOExtra.printLn_err "Fatal: unknown error"

(* (string, string) map -> () *)
fun sendReqIni ini =
    case Option.map BString.unshow (Map.lookup ini "place.1.publicKey") of
      None => TextIOExtra.printLn_err "No public key found for place 1"
    | Some key => (
        case iniServerAm ini of
          Err e => TextIOExtra.printLn_err e
        | Ok am => sendReq am key
      )
    handle Word8Extra.InvalidHex => TextIOExtra.printLn_err "place.1.publicKey not in valid hex format"

(* () -> () *)
fun main () =
    let val name  = CommandLine.name ()
        val usage = "Usage: " ^ name ^ " configurationFile\n"
                  ^ "e.g.   " ^ name ^ " config.ini\n"
     in case CommandLine.arguments () of
              [fileName] => (
                  case parseIniFile fileName of
                    Err e  => TextIOExtra.printLn_err e
                  | Ok ini => sendReqIni ini
              )
           | _ => TextIO.print_err usage
    end
val () = main ()