(* Depends on: util, copland, posix, am/Measurements, am/ServerAm, ./Blockchain.sml *)

(* Copland term used for appraisal *)
val dir = "testDir" 
val subterm = (Asp (Aspc (Id (S O)) [dir]))
val term = Att (S O) (Lseq subterm (Asp Sig))

(* maximum staleness for a blockchain health record *)
val freshnessLimit = 3600000000 (* 3600_000000 microseconds = 1 hour *)

(* getHashDemo: (string, int, string, string) -> (BString.bstring, string) result
 * `getHashDemo (blockchainIP, blockchainPort, goldenHashContractAddress, userAddress)`
 * Get the golden hash from the blockchain at `blockchainIP` with port number
 * `blockchainPort`. Specifically, talk to the contract at
 * `goldenHashContractAddress` from the `userAddress`.
 *)
fun getHashDemo (blockchainIP, blockchainPort, goldenHashContractAddress, userAddress) =
    let
        val jsonId = 2
        val hashId = 1
    in
        Blockchain.getHash blockchainIP blockchainPort jsonId
            goldenHashContractAddress userAddress hashId
    end
    handle Socket.Err _ => Err "Socket error in retrieving golden hash."
        | _ => Err "Unknown error in retrieving golden hash."

(* appraise: BString.bstring -> ev -> string -> BString.bstring -> (string, int, string string) -> (unit, string) result
 * `appraise nonce evidence signingKey goldenHashContract`
 * Appraises the evidence received against the hash stored on the blockchain.
 *)
fun appraise nonce ev signingKey goldenHashContract =
    case ev of
      G evSign (U (Id (S O)) [dir] evHash (N (Id O) evNonce Mt)) =>
        if evNonce <> nonce
        then Err "Bad nonce value"
        else
            (case getHashDemo goldenHashContract of
              Ok goldenHash =>
                if evHash <> goldenHash then
                    Err "Bad hash value"
                else if not (Option.valOf (verifySig ev signingKey)) then
                    Err "Bad signature"
                else Ok ()
            | Err msg => Err msg)
    | _ => Err "Unexpected shape of evidence"

(* sendReq: am -> BString.bstring -> (string, int, string, string) -> (string, string) result
 * `sendReq attestMangr signingKey goldenHashContract`
 * Sends an appraisal request to the given attestation manager `attestMangr`,
 * looking up the golden hash value using the smart contract at
 * `goldenHashContract`, and checking the signature with the `signatureKey`.
 *)
fun sendReq am signingKey goldenHashContract =
    let
        val nonce = Random.random (Random.seed (Meas.urand 32)) 16
        val ev    = evalTerm am (N (Id O) nonce Mt) term
        val prefix = String.concat ["Evaluating term:\n", termToString term,
                "\n\nNonce:\n", BString.show nonce, "\n\nEvidence received:\n",
                evToString ev, "\n\nAppraisal "]
    in
        case appraise nonce ev signingKey goldenHashContract of
          Ok ()   => Ok (prefix ^ "succeeded (expected nonce and hash value; signature verified).\n")
        | Err msg => Err (String.concat [prefix, "failed: ", msg, "\n"])
    end
    handle Socket.Err s     => Err ("Socket failure on connection: " ^ s ^ "\n")
         | Socket.InvalidFD => Err "Invalid file descriptor\n"
         | DispatchErr s    => Err ("Dispatch error: "^s^"\n")
         | _                => Err "Fatal: unknown error\n"

(* filterHealthRecords: ((HealthRecord.healthRecord, 'a) result) list -> 
 *  HealthRecord.healthRecord list
 * `filterHealthRecords records`
 * Filters out all health records returned from the blockchain which are for
 * different Copland terms or are too stale.
 *)
fun filterHealthRecords signingKey records =
    let
        fun filter record =
            case record of
              Err _ => False
            | Ok hr => 
                let val freshness = HealthRecord.checkFreshness hr val _ = (print (Int.toString freshness); print "\n") in
                    (* if HealthRecord.getPhrase hr <> term
                    then (print "Term didn't match.\n"; False)
                    else if HealthRecord.checkSignature signingKey hr = False
                        then (print "Signature didn't match.\n"; False)
                        else if 0 <= freshness andalso freshness < freshnessLimit
                            then True
                            else (print "Record wasn't fresh enough.\n"; False) *)
                    HealthRecord.getPhrase hr = term andalso
                    freshness < freshnessLimit andalso 0 <= freshness andalso
                    HealthRecord.checkSignature signingKey hr
                end
    in
        List.map Result.okValOf (List.filter filter records)
    end

(* healthRecordDemo: (string, string) map -> unit
 * `healthRecordDemo ipAddr goldenHashContractAddr healthRecordContractAddr`
 * Appraise target at `ipAddr` retreiving the golden hash value on from the
 * blockchain along with any previous appraisal health records.
 *)
fun healthRecordDemo globalMap =
    let
        val jsonId = 3
        val blockchainIPo = Map.lookup globalMap "blockchain.ip"
        val blockchainPorto = Option.mapPartial Int.fromString (Map.lookup globalMap "blockchain.port")
        val place1hosto = Map.lookup globalMap "place.1.host"
        val place1porto = Option.mapPartial Int.fromString (Map.lookup globalMap "place.1.port")
        val privateKeyo = Option.map BString.unshow (Map.lookup globalMap "place.1.privateKey")
        (* Evercrypt
        val ido =
            Option.map
                (fn key => Crypto.hash (Crypto.generateEncryptionPublicKey key))
                privateKeyo
         *)
        val signingKeyo = Option.map BString.unshow (Map.lookup globalMap "place.1.signingKey")
        val ido =
            Option.map Crypto.hash signingKeyo
        val serverIdo = ido
        val goldenHashContracto =
            Map.lookup globalMap "blockchain.goldenHashContract"
        val healthRecordContracto =
            Map.lookup globalMap "blockchain.healthRecordContract"
        val userAddresso =
            Map.lookup globalMap "blockchain.userAddress"
        val allRecords =
            case (blockchainIPo, blockchainPorto, userAddresso, ido, serverIdo, healthRecordContracto, place1hosto, place1porto) of
              (None, _, _, _, _, _, _, _) => Err "error looking up blockchain's ip address"
            | (_, None, _, _, _, _, _, _) => Err "error looking up blockchain's port number"
            | (_, _, None, _, _, _, _, _) => Err "error looking up blockchain user address"
            | (_, _, _, None, _, _, _, _) => Err "error looking up client's private key"
            | (_, _, _, _, None, _, _, _) => Err "error looking up server's key"
            | (_, _, _, _, _, None, _, _) => Err "error looking up health record contract address"
            | (_, _, _, _, _, _, None, _) => Err "error looking up place.1's host address"
            | (_, _, _, _, _, _, _, None) => Err "error looking up place.1's port number"
            | (Some blockchainIP, Some blockchainPort, Some userAddress, Some id, Some serverId, Some healthRecordContract, Some _, Some _) =>
                HealthRecord.getAllRecords blockchainIP blockchainPort jsonId
                    healthRecordContract userAddress id serverId
        val amr = iniServerAm globalMap
    in
        case (allRecords, goldenHashContracto, amr) of
          (Err msg, _, _) =>
            TextIO.print_err
                (String.concat ["Error getting health records: ", msg, "\n"])
        | (_, None, _) =>
            TextIO.print_err "Error getting health records: error looking up golden hash contract address.\n"
        | (_, _, Err msg) =>
            TextIO.print_err "Error getting health records: error creating attestation managaer object.\n"
        | (Ok records, Some goldenHashContractAddress, Ok am) =>
            let
                val blockchainIP = Option.valOf blockchainIPo
                val blockchainPort = Option.valOf blockchainPorto
                val userAddress = Option.valOf userAddresso
                val privateKey = Option.valOf privateKeyo
                val id = Option.valOf ido
                val serverId = Option.valOf serverIdo
                val signingKey = Option.valOf signingKeyo
                val healthRecordContract = Option.valOf healthRecordContracto
                val host = Option.valOf place1hosto
                val port = Option.valOf place1porto
                val goldenHashContract =
                    (blockchainIP, blockchainPort,
                        goldenHashContractAddress,
                        userAddress)
            in
                case filterHealthRecords signingKey records of
                  _::_ =>
                    TextIO.print_list ["Found a record with freshness at most ",
                        Int.toString freshnessLimit, " µs.\n"]
                | [] =>
                    case sendReq am signingKey goldenHashContract of
                    Err msg => TextIO.print_err msg
                    | Ok msg =>
                        let
                            val healthRecordNotSigned =
                                HealthRecord.healthRecord
                                    id
                                    term
                                    (Json.fromBool True)
                                    None
                                    serverId
                                    (HealthRecord.TcpIp host port)
                                    signingKey
                                    (timestamp ())
                            val healthRecordSignedJSON =
                                HealthRecord.signAndToJson
                                    privateKey
                                    healthRecordNotSigned
                            val addRecordResult =
                                HealthRecord.addRecord blockchainIP
                                    blockchainPort
                                    jsonId
                                    healthRecordContract
                                    userAddress
                                    id
                                    serverId
                                    healthRecordSignedJSON
                        in
                            case addRecordResult of
                              Ok _ =>
                                print "Added health record successfully.\n"
                            | Err msg =>
                                TextIO.print_err
                                    (String.concat ["Error adding new health record: ", msg, "\n"])
                        end
            end
    end

fun main () =
    let
        val name  = CommandLine.name ()
        val usage =
            String.concat
                ["Usage: ", name, " <ini config file>\n",
                    "e.g. ", name, " config.ini\n"]
    in
        case CommandLine.arguments () of
          [iniFilename] =>
            (case parseIniFile iniFilename of
              Ok config => healthRecordDemo config
            | Err msg =>
                TextIO.print_err (String.concat ["Error parsing ini file: ", msg, "\n"]))
        | _ => TextIO.print_err usage
        end
val _ = main ()
