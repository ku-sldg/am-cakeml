(* Depends on: util, copland, am/Measurements, am/ServerAm *)

val pub = (ByteString.toRawString o ByteString.fromHexString) "490E2422528F14AC6A48DDB9D72CB30B8345AF2E939003BC7A33A6057F2FFB0101000000000000002DD0B7F53A560000A049D882A37F00000000000000000000"

fun copMeasFileGen f =
    let val fileHashId = Id O in
    Att (S O) (Lseq
        (Asp (Aspc fileHashId [f]))
        (Asp Sig)
              )
    end
        

val file = "hashTest.txt"
val copMeasFile = copMeasFileGen file
val goldenHashFile = "E56B5C95EE35B7CC24FC6FE76A604A62ADD3A4A21759E33F08780B9BE79107EDB8CCB04A5214DCC51DDAF26884D7BD884D71E718EA9BD8064A0D02BBCCB2F08B"

val procFile = "testProc/good/testProc"
val copMeasFile2 = copMeasFileGen procFile
val goldenHashProcFile = "DAD3346C2B4B9DE2F34B738032F0BDF8DCB0A732493EF8F56FD8BBDAC572B66FDCFF36D86C390239BC87732E0D7149414F2AD0B2EDFEBB0ADB072667A131BEB8"

val dir = "testDir" 
val dirHashId = Id (S O)
val copMeasDir = 
    Att (S O) (Lseq
        (Asp (Aspc dirHashId [dir]))
        (Asp Sig)
    )
val goldenHashDir = "873B27E32B748D695A9934E14A4CFE995EC62C4AFEB50D85613D0C35D42D1A50302514C2E21DBD65A3148AF39E20554AA31C6274560EE9473CC734CE35F60E42"

val proc = "testProc"
val procHashId = Id (S (S O))
val copMeasProc = 
    Att (S O) (Lseq
        (Asp (Aspc procHashId [proc]))
        (Asp Sig)
    )
val goldenHashProc = "AF9F0EAD72487DCF7514D5825EE0D32FB1BBACB9CD17F4BC0B81DC43117BD55E8A4DFE4616710547843933451AAFAB2FD5ACD03E13E9D4701BD075338DA37B5E"

(*"BC6EB058F40400330ECB82CB4F9FDA032CAAD38A0FB5C7F5AC9E3C69F28698D4C3E5100DE88509AF70A05CA05A8125A1716D80252AB088CA440087C69021382D"*)

datatype ('t, 'e) result = Ok 't
       | Err 'e

fun doMeasFileGen am t f_app = 
    let val nonce = genNonce ()
        val ev = evalTerm am (N (Id O) nonce Mt) t 
     in print (
            "Evaluating term:\n" ^ termToString t ^ "\n\n" ^
            "Nonce: " ^ ByteString.show nonce ^ "\n\n" ^ 
            "Evidence: " ^ evToString ev ^ "\n\n" ^
            "Appraisal " ^ (case f_app nonce ev of 
                  Ok ()   => "succeeded"
                | Err msg => "failed: " ^ msg 
            )
        )
    end

fun appraiseFileGen nonce ev golden_hash = case ev of
    G evSign (U (Id O) _ evHash (N (Id O) evNonce Mt)) =>
        if not (ByteString.deepEq evNonce nonce) then
            Err "Bad nonce value"
        else if ByteString.toHexString evHash <> golden_hash then
            Err "Bad hash value"
        else if not (Option.valOf (verifySig ev pub)) then
            Err "Bad signature"
        else Ok ()
    | _ => Err "Unexpected shape of evidence"

fun appraiseFile nonce ev = appraiseFileGen nonce ev goldenHashFile
fun doMeasFile am = doMeasFileGen am copMeasFile appraiseFile

fun appraiseProcFile nonce ev = appraiseFileGen nonce ev goldenHashProcFile
fun doMeasProcFile am = doMeasFileGen am copMeasFile2 appraiseProcFile

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
    G evSign (U (Id (S (S O))) ["testProc"] evHash (N (Id O) evNonce Mt)) =>
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

fun sendReqs addr meas =
    let val am = serverAm "" (Map.insert emptyNsMap (S O) addr)
    in case meas of
           "fileMeas" => (doMeasFile am; print "\n\n")
         | "dirMeas" => (doMeasDir am; print "\n\n")
         | "procMeas" => (doMeasProc am; print "\n\n")
         | "procFileMeas" => (doMeasProcFile am; print "\n\n")
         | s => TextIO.print_err ("Measurement \"" ^ s ^ "\" unknown.\n Try one of:  \"fileMeas\", \"dirMeas\", \"procMeas\", \"procFileMeas\"\n")
    end
    handle Socket.Err s     => TextIO.print_err ("Socket failure on connection: " ^ s ^ "\n")
         | Socket.InvalidFD => TextIO.print_err "Invalid file descriptor\n"
         | DispatchErr s    => TextIO.print_err ("Dispatch error: "^s^"\n")
         | _                => TextIO.print_err "Fatal: unknown error\n"

fun main () =
    let val name  = CommandLine.name ()
        val usage = "Usage: " ^ name ^ " address" ^ " measurement\n"
                  ^ "e.g.   " ^ name ^ " 127.0.0.1" ^ " fileMeas\n"
     in case CommandLine.arguments () of
            [addr,meas] => sendReqs addr meas
          | _ => TextIO.print_err usage
     end

val _ = main ()
