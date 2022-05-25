(* Depends upon: util, posix, ./Blockchain.sml *)
(* This will clear all the health records for a given appraiser and a given
 * client.
 *)
fun clearHealthRecordsDemo globalConfig =
    let
        val recipientr =
            Result.fromOption
                (Map.lookup globalConfig "blockchain.healthRecordContract")
                "error looking up health record contract address"
        val senderr =
            Result.fromOption
                (Map.lookup globalConfig "blockchain.userAddress")
                "error looking up blockchain user address"
        val hostr =
            Result.fromOption
                (Map.lookup globalConfig "blockchain.ip")
                "error looking up blockchain IP address"
        val portr =
            Result.fromOption
                (Option.mapPartial
                    Int.fromString
                    (Map.lookup globalConfig "blockchain.port"))
                "error looking up blockchain port number"
        val privateKeyo = Option.map BString.unshow (Map.lookup globalConfig "place.1.privateKey")
        val appraiserIdr =
            Result.fromOption
                (Option.map
                    (fn key =>
                        Crypto.hash (Crypto.generateEncryptionPublicKey key))
                    privateKeyo)
                "error looking up appraiser id"
        val signingKeyo =
            Option.map
                BString.unshow
                (Map.lookup globalConfig "place.1.signingKey")
        val targetIdr = appraiserIdr
        val jsonId = 4
        val hashId = 1
        val resultr =
            Result.bind hostr
                (fn host =>
                    Result.bind portr
                        (fn port =>
                            Result.bind recipientr
                                (fn recipient =>
                                    Result.bind senderr
                                        (fn sender =>
                                            Result.bind appraiserIdr
                                                (fn appraiserId =>
                                                    Result.bind targetIdr
                                                        (fn targetId =>
                                                            HealthRecord.clearRecords
                                                                host port
                                                                jsonId
                                                                recipient
                                                                sender
                                                                appraiserId
                                                                targetId))))))
    in
        case resultr of
          Err msg => TextIO.print_err (String.concat [msg, "\n"])
        | Ok _ => print "Cleared health records.\n"
    end
    handle Socket.Err _ =>
            TextIO.print_err "Socket error when trying to add authorized user.\n"
        | Socket.InvalidFD =>
            TextIO.print_err "Socket file descriptor error when trying to add authorized user.\n"
        | _ =>
            TextIO.print_err "Unknown error when trying to add authorized user.\n"

fun main () =
    let
        val errorMsg = String.concat ["usage: ", CommandLine.name (),
                                        " <ini config file>\n"]
    in
        case CommandLine.arguments () of
          [iniFilename] =>
            (case parseIniFile iniFilename of
              Ok config => clearHealthRecordsDemo config
            | Err msg => TextIO.print_err (String.concat ["Error parsing ini file: ", msg, "\n"]))
        | _ =>
            TextIO.print_err errorMsg
    end
val _ = main ()
