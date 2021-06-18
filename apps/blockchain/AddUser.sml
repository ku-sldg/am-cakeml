(* Depends upon: util, posix, ./Blockchain.sml *)
fun addUserDemo recipient address =
    let
        val sender = "0xdE497f77e0e2Ae24D27B6108f9400e95A18392B0"
        val host = "127.0.0.1"
        val port = 8543
        val jsonId = 3
        val hashId = 1
        val resultr =
            Blockchain.addAuthorizedUser host port jsonId recipient sender address
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
                                        " <contract address> <user address>\n"]
    in
        case CommandLine.arguments () of
          [recipient, address] =>
            addUserDemo recipient address
        | _ =>
            TextIO.print_err errorMsg
    end

val _ = main ()
