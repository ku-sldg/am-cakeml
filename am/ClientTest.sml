(* Depends on: CoplandLang.sml, Eval.sml, and SocketFFI.sml *)

val map   = Map.insert emptyNsMap (S O) "127.0.0.1"
val term  = AT (S O) (LN (USM (Id O) ["hashTest.txt"]) SIG)
val nonce = genNonce ()

val goldenHash = "DDAF35A193617ABACC417349AE20413112E6FA4E89A97EA20A9EEEE64B55D39A2192992A274FC1A836BA3C23A3FEEBBD454D4423643CE80E2A9AC94FA54CA49F"
val pub = (ByteString.toRawString o ByteString.fromHexString) "490E2422528F14AC6A48DDB9D72CB30B8345AF2E939003BC7A33A6057F2FFB0101000000000000002DD0B7F53A560000A049D882A37F00000000000000000000"

(* Like an option, but the error case is also parameterized, typically to carry
   error messages *)
datatype ('t, 'e) result = Ok 't
                         | Err 'e

fun appraise ev =
    case ev
      of G (S O) (U (Id O) ["hashTest.txt"] (S O) evHash (N O 0 evNonce Mt)) evSign =>
         if not (ByteString.deepEq evNonce nonce)
         then Err "Bad nonce value"
         else if ByteString.toHexString evHash <> goldenHash
              then Err "Bad hash value"
              else if Option.valOf (verifySig ev pub)
                   then Ok ()
                   else Err "Bad signature"
       | _ => Err "Unexpected shape of evidence"

fun main () =
    let val ev = eval O map "" (N O 0 nonce Mt) term
     in print ("Evaluating term:\n" ^ tToString term ^ "\n\nNonce:\n" ^
               ByteString.show nonce ^ "\n\nEvidence recieved:\n" ^
               evToString ev ^ "\n\nAppraisal " ^ (
               case appraise ev
                 of Ok ()   => "succeeded (expected nonce and hash value; signature verified).\n"
                  | Err msg => "failed: " ^ msg ^ "\n")
              )
    end
    handle Socket.Err       => TextIO.print_err "Socket failure on connection\n"
         | Socket.InvalidFD => TextIO.print_err "Invalid file descriptor\n"
         | _                => TextIO.print_err "Fatal: unknown error\n"

val _ = main ()
