val _ = print "Establishing listening socket...\n"
val listeningfd = Socket.listen 50000 5
val _ = print "Done.\n"

val _ = print "Waiting for incoming connection...\n"
val clientfd = Socket.accept listeningfd
val _ = print "Connection established.\n"

val msg = Socket.inputAll clientfd
val _ = print ("Client message: " ^ msg ^ "\n")

val _ = Socket.output clientfd "Goodbye."

val _ = Socket.close clientfd
val _ = Socket.close listeningfd
val _ = print "Sockets closed.\n"
