(* Depends on: util, copland, am/Measurements, am/ServerAm *)

val pub = (ByteString.toRawString o ByteString.fromHexString) "490E2422528F14AC6A48DDB9D72CB30B8345AF2E939003BC7A33A6057F2FFB0101000000000000002DD0B7F53A560000A049D882A37F00000000000000000000"

val file = "hashTest.txt"
val fileHashId = Id O
val copMeasFile =
    Att (S O) (Lseq
        (Asp (Aspc fileHashId [file]))
        (Asp Sig)
    )
val goldenHashFile = "DDAF35A193617ABACC417349AE20413112E6FA4E89A97EA20A9EEEE64B55D39A2192992A274FC1A836BA3C23A3FEEBBD454D4423643CE80E2A9AC94FA54CA49F"

val dir = "testDir" 
val dirHashId = Id (S O)
val copMeasDir = 
    Att (S O) (Lseq
        (Asp (Aspc dirHashId [dir]))
        (Asp Sig)
    )
val goldenHashDir = "A4EA2BB49B0FF60D240FC17C63548892EF3A3BB618718FB562FE603916EF1211EC51BB59CA137782F277450016EDEA9E33CE30B08538AA5A306933920CE272C6"

val proc = "foo"
val procHashId = Id (S (S O))
val copMeasProc = 
    Att (S O) (Lseq
        (Asp (Aspc procHashId [proc]))
        (Asp Sig)
    )
val goldenHashProc = ""

datatype ('t, 'e) result = Ok 't
                         | Err 'e

fun appraiseFile nonce ev = case ev of
    G evSign (U (Id O) ["hashTest.txt"] evHash (N (Id O) evNonce Mt)) =>
        if not (ByteString.deepEq evNonce nonce) then
            Err "Bad nonce value"
        else if ByteString.toHexString evHash <> goldenHashFile then
            Err "Bad hash value"
        else if not (Option.valOf (verifySig ev pub)) then
            Err "Bad signature"
        else Ok ()
    | _ => Err "Unexpected shape of evidence"
fun doMeasFile am = 
    let val nonce = genNonce ()
        val ev = evalTerm am (N (Id O) nonce Mt) copMeasFile 
     in print (
            "Evaluating term:\n" ^ termToString copMeasFile ^ "\n\n" ^
            "Nonce: " ^ ByteString.show nonce ^ "\n\n" ^ 
            "Evidence: " ^ evToString ev ^ "\n\n" ^
            "Appraisal " ^ (case appraiseFile nonce ev of 
                  Ok ()   => "succeeded"
                | Err msg => "failed: " ^ msg 
            )
        )
    end

fun appraiseDir nonce ev = case ev of
    G evSign (U (Id (S O)) ["testDir"] evHash (N (Id O) evNonce Mt)) =>
        if not (ByteString.deepEq evNonce nonce) then
            Err "Bad nonce value"
        else if ByteString.toHexString evHash <> goldenHashDir then
            Err "Bad hash value"
        else if not (Option.valOf (verifySig ev pub)) then
            Err "Bad signature"
        else Ok ()
    | _ => Err "Unexpected shape of evidence"
fun doMeasDir am = 
    let val nonce = genNonce ()
        val ev = evalTerm am (N (Id O) nonce Mt) copMeasDir
     in print (
            "Evaluating term:\n" ^ termToString copMeasDir ^ "\n\n" ^
            "Nonce: " ^ ByteString.show nonce ^ "\n\n" ^ 
            "Evidence: " ^ evToString ev ^ "\n\n" ^
            "Appraisal " ^ (case appraiseDir nonce ev of 
                  Ok ()   => "succeeded"
                | Err msg => "failed: " ^ msg 
            )
        )
    end

fun appraiseProc nonce ev = case ev of
    G evSign (U (Id (S (S O))) ["foo"] evHash (N (Id O) evNonce Mt)) =>
        if not (ByteString.deepEq evNonce nonce) then
            Err "Bad nonce value"
        else if ByteString.toHexString evHash <> goldenHashProc then
            Err "Bad hash value"
        else if not (Option.valOf (verifySig ev pub)) then
            Err "Bad signature"
        else Ok ()
    | _ => Err "Unexpected shape of evidence"
fun doMeasProc am = 
    let val nonce = genNonce ()
        val ev = evalTerm am (N (Id O) nonce Mt) copMeasProc
     in print (
            "Evaluating term:\n" ^ termToString copMeasProc ^ "\n\n" ^
            "Nonce: " ^ ByteString.show nonce ^ "\n\n" ^ 
            "Evidence: " ^ evToString ev ^ "\n\n" ^
            "Appraisal " ^ (case appraiseProc nonce ev of 
                  Ok ()   => "succeeded"
                | Err msg => "failed: " ^ msg 
            )
        )
    end

fun sendReqs addr =
    let val am = serverAm "" (Map.insert emptyNsMap (S O) addr)
     in doMeasFile am; print "\n\n";
        doMeasDir  am; print "\n"
    end
    handle Socket.Err s     => TextIO.print_err ("Socket failure on connection: " ^ s ^ "\n")
         | Socket.InvalidFD => TextIO.print_err "Invalid file descriptor\n"
         | DispatchErr s    => TextIO.print_err ("Dispatch error: "^s^"\n")
         | _                => TextIO.print_err "Fatal: unknown error\n"

fun main () =
    let val name  = CommandLine.name ()
        val usage = "Usage: " ^ name ^ " address\n"
                  ^ "e.g.   " ^ name ^ " 127.0.0.1\n"
     in case CommandLine.arguments () of
              [addr] => sendReqs addr
            | _ => TextIO.print_err usage
     end

val _ = main ()
