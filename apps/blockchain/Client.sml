(* Depends on: util, copland, posix, am/Measurements, am/ServerAm, ./Blockchain.sml *)

(*val term  = Att (S O) (Lseq (Asp (Aspc (Id O) ["hashTest.txt"])) (Asp Sig))*)

val dir = "testDir" 

val subterm = (Asp (Aspc (Id (S O)) [dir]))
val term = Att (S O) (Lseq subterm (Asp Sig))

(* val goldenHash = BString.unshow "7BE9FDA48F4179E611C698A73CFF09FAF72869431EFEE6EAAD14DE0CB44BBF66503F752B7A8EB17083355F3CE6EB7D2806F236B25AF96A24E22B887405C20081" *)
val signPub = BString.unshow "490E2422528F14AC6A48DDB9D72CB30B8345AF2E939003BC7A33A6057F2FFB0101000000000000002DD0B7F53A560000A049D882A37F00000000000000000000"
val privKey = BString.unshow "9FF1145A05AB74B449F39D9A505CB2A4706597C214C23562544F33C9A5FD6106"
val sender = "0xdE497f77e0e2Ae24D27B6108f9400e95A18392B0"
val blockchainHost = "127.0.0.1"
val blockchainPort = 8543
val freshnessLimit = 5000

fun getHashDemo goldenHashRecipient =
    let
        val jsonId = 2
        val hashId = 1
    in
        Blockchain.getHash blockchainHost blockchainPort jsonId
            goldenHashRecipient sender hashId
    end
    handle Socket.Err _ => Err "Socket error in retrieving golden hash."
        | _ => Err "Unknown error in retrieving golden hash."

fun appraise nonce ev goldenHashRecipient =
    case ev of
      G evSign (U (Id (S O)) [dir] evHash (N (Id O) evNonce Mt)) =>
        if evNonce <> nonce
        then Err "Bad nonce value"
        else
            (case getHashDemo goldenHashRecipient of
              Ok goldenHash =>
                if evHash <> goldenHash then
                    Err "Bad hash value"
                else if not (Option.valOf (verifySig ev signPub)) then
                    Err "Bad signature"
                else Ok ()
            | Err msg => Err msg)
    | _ => Err "Unexpected shape of evidence"

fun sendReq addr goldenHashRecipient =
    let val am    = serverAm BString.empty (Map.insert emptyNsMap (S O) addr)
        val nonce = Random.random (Random.seed (Meas.urand 32)) 16
        val ev    = evalTerm am (N (Id O) nonce Mt) term
        val prefix = String.concat ["Evaluating term:\n", termToString term,
                "\n\nNonce:\n", BString.show nonce, "\n\nEvidence received:\n",
                evToString ev, "\n\nAppraisal "]
    in
        case appraise nonce ev goldenHashRecipient of
          Ok ()   => Ok (prefix ^ "succeeded (expected nonce and hash value; signature verified).\n")
        | Err msg => Err (String.concat [prefix, "failed: ", msg, "\n"])
    end
    handle Socket.Err s     => Err ("Socket failure on connection: " ^ s ^ "\n")
         | Socket.InvalidFD => Err "Invalid file descriptor\n"
         | DispatchErr s    => Err ("Dispatch error: "^s^"\n")
         | _                => Err "Fatal: unknown error\n"

fun filterHealthRecords records =
    let
        fun filter record =
            case record of
              Err _ => False
            | Ok hr => HealthRecord.getPhrase hr = term andalso
                HealthRecord.checkFreshness hr < freshnessLimit
    in
        List.map Result.okValOf (List.filter filter records)
    end

fun healthRecordDemo addr goldenHashRecipient healthRecordRecipient =
    let
        val jsonId = 3
        val id = Crypto.hash (Crypto.generateEncryptionPublicKey privKey)
        val serverId = Crypto.hash signPub
        val allRecords =
            HealthRecord.getAllRecords blockchainHost blockchainPort jsonId
                healthRecordRecipient sender id serverId
    in
        case allRecords of
          Err msg =>
            TextIO.print_err (String.concat ["Error getting health records: ", msg])
        | Ok records =>
            case filterHealthRecords records of
              _::_ =>
                TextIO.print_list ["Found a record with freshness at most ",
                    Int.toString freshnessLimit, " ms."]
            | [] =>
                case sendReq addr goldenHashRecipient of
                  Err msg => TextIO.print_err msg
                | Ok msg =>
                    let
                        val healthRecordNotSigned =
                            HealthRecord.healthRecord id term
                                (Json.fromBool True) None serverId
                                (timestamp ())
                        val healthRecordSignedJSON =
                            HealthRecord.signAndToJson
                                privKey
                                healthRecordNotSigned
                        val addRecordResult =
                            HealthRecord.addRecord blockchainHost blockchainPort
                                jsonId healthRecordRecipient sender id serverId
                                healthRecordSignedJSON
                    in
                        case addRecordResult of
                          Ok _ =>
                            print "Added health record successfully.\n"
                        | Err _ =>
                            TextIO.print_err "Error adding new health record.\n"
                    end
    end

fun main () =
    let
        val name  = CommandLine.name ()
        val usage = String.concat
                    ["Usage: ", name, " <server ip> <smart contract address> <smart contract address>\n"]
    in
        case CommandLine.arguments () of
          [addr, goldenHashRecipient, healthRecordRecipient] =>
            healthRecordDemo addr goldenHashRecipient healthRecordRecipient
        | _ => TextIO.print_err usage
        end

val _ = main ()
