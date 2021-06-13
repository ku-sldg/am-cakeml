(* Depends upon: util, posix, ./Blockchain.sml *)
fun setHashDemo recipient goldenHash =
    let
        val sender = "0x55500e2c661b9b703421b92d15e15d292a9df669"
        val host = "127.0.0.1"
        val port = 8543
        val jsonId = 1
        val hashId = 1
        val resultr =
            Blockchain.setHash host port jsonId recipient sender hashId goldenHash
    in
        case resultr of
          Err msg => TextIO.print_err (String.concat [msg, "\n"])
        | Ok _ => print "Set hash succeeded.\n"
    end
    handle Socket.Err _ =>
            TextIO.print_err "Socket error when trying to set golden hash.\n"
        | Socket.InvalidFD =>
            TextIO.print_err "Socket file descriptor error when trying to set golden hash.\n"
        | Blockchain.Exn msg =>
            TextIO.print_err (String.concat ["Blockchain error: ", msg])
        | _ =>
            TextIO.print_err "Unknown error when trying to set golden hash.\n"

fun main () =
    let
        val errorMsg = String.concat ["usage: ", CommandLine.name (),
                                        " <dest address> <golden hash>\n"]
    in
        case CommandLine.arguments () of
          [recipient, goldenHash] =>
            setHashDemo recipient (BString.unshow goldenHash)
        | _ =>
            TextIO.print_err errorMsg
    end

val _ = main ()
