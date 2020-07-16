(* Depends on: util, copland, am/Measurements, am/ServerAm *)

(*val term  = Att (S O) (Lseq (Asp (Aspc (Id O) ["hashTest.txt"])) (Asp Sig))*)

val dir = "/home/grant/lab/cakeml-am/test_dir2" (*"/Users/adampetz/Documents/Summer_2019/cakeml-am/copland"*)

val subterm = (Asp (Aspc (Id (S O)) [dir]))
val term = Att (S O) (Lseq subterm (Asp Sig))

val goldenHash = "DDAF35A193617ABACC417349AE20413112E6FA4E89A97EA20A9EEEE64B55D39A2192992A274FC1A836BA3C23A3FEEBBD454D4423643CE80E2A9AC94FA54CA49F"
val pub = (ByteString.toRawString o ByteString.fromHexString) "490E2422528F14AC6A48DDB9D72CB30B8345AF2E939003BC7A33A6057F2FFB0101000000000000002DD0B7F53A560000A049D882A37F00000000000000000000"

(* TODO: move to util *)
datatype ('t, 'e) result = Ok 't
                         | Err 'e

fun appraise nonce ev =
    case ev
      of G evSign (U (Id O) ["hashTest.txt"] evHash (N (Id O) evNonce Mt)) =>
         if not (ByteString.deepEq evNonce nonce)
         then Err "Bad nonce value"
         else if ByteString.toHexString evHash <> goldenHash
              then Err "Bad hash value"
              else if Option.valOf (verifySig ev pub)
                   then Ok ()
                   else Err "Bad signature"
       | _ => Err "Unexpected shape of evidence"

fun sendReq addr =
    let val am = serverAm "" (Map.insert emptyNsMap (S O) addr)
        val nonce = genNonce ()
        val ev = evalTerm am (N (Id O) nonce Mt) term
     in print ("Evaluating term:\n" ^ termToString term ^ "\n\nNonce:\n" ^
               ByteString.show nonce ^ "\n\nEvidence recieved:\n" ^
               evToString ev ^ "\n\nAppraisal " ^ (
               case appraise nonce ev of
                      Ok ()   => "succeeded (expected nonce and hash value; signature verified).\n"
                    | Err msg => "failed: " ^ msg ^ "\n")
              )
    end
    handle Socket.Err       => TextIO.print_err "Socket failure on connection\n"
         | Socket.InvalidFD => TextIO.print_err "Invalid file descriptor\n"
         | DispatchErr s    => TextIO.print_err ("Dispatch error: "^s^"\n")
         | _                => TextIO.print_err "Fatal: unknown error\n"

fun main () =
    let val usage = "Usage: ./client address\ne.g.   ./client 127.0.0.1\n"
     in case CommandLine.arguments () of
              [addr] => sendReq addr
            | _ => TextIO.print_err usage
     end

val _ = main ()
