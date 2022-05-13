(* Depends upon: util, posix, ./Blockchain.sml *)
fun setHashDemo globalConfig =
    let
        val recipientr =
            Result.fromOption
                (Map.lookup globalConfig "blockchain.goldenHashContract")
                "error looking up golden hash contract address"
        val goldenHashValuer =
            Result.fromOption
                (Option.map
                    BString.unshow
                    (Map.lookup globalConfig "blockchain.goldenHashValue"))
                "error looking up golden hash value"
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
        val jsonId = 1
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
                                            Result.bind goldenHashValuer
                                                (fn goldenHashValue =>
                                                    Blockchain.setHash
                                                        host port jsonId
                                                        recipient sender hashId
                                                        goldenHashValue)))))
    in
        case resultr of
          Err msg => TextIO.print_err (String.concat [msg, "\n"])
        | Ok _ => print "Set hash succeeded.\n"
    end
    handle Socket.Err _ =>
            TextIO.print_err "Socket error when trying to set golden hash.\n"
        | Socket.InvalidFD =>
            TextIO.print_err "Socket file descriptor error when trying to set golden hash.\n"
        | _ =>
            TextIO.print_err "Unknown error when trying to set golden hash.\n"

fun main () =
    let
        val errorMsg = String.concat ["usage: ", CommandLine.name (),
                                        " <ini config file>\n"]
    in
        case CommandLine.arguments () of
          [iniFilename] =>
            (case parseIniFile iniFilename of
              Ok config =>
                setHashDemo config
            | Err msg =>
                TextIO.print_err (String.concat ["Error parsing ini file: ", msg, "\n"]))
        | _ =>
            TextIO.print_err errorMsg
    end

val _ = main ()
