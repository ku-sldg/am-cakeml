(* Depends upon: util, posix, ./Blockchain.sml *)
fun addUserDemo globalConfig address =
    let
        val recipientr =
            Result.fromOption
                (Map.lookup globalConfig "blockchain.goldenHashContract")
                "error looking up golden hash contract address"
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
                                            Blockchain.addAuthorizedUser
                                                host port jsonId recipient
                                                sender address))))
    in
        case resultr of
          Err msg => TextIO.print_err (String.concat [msg, "\n"])
        | Ok _ => print "Add user succeeded.\n"
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
                                        " <ini config file> <user address>\n"]
    in
        case CommandLine.arguments () of
          [iniFilename, address] =>
            (case parseIniFile iniFilename of
              Ok config => addUserDemo config address
            | Err msg => TextIO.print_err (String.concat ["Error parsing ini file: ", msg, "\n"]))
        | _ =>
            TextIO.print_err errorMsg
    end
val _ = main ()
