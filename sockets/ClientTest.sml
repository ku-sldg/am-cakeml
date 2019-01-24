val _ = print "Connecting to server...\n"
val serverfd = Socket.connect "127.0.0.1" 5000
val _ = print ("Connection established with file descriptor: " ^
               (Socket.fdToString serverfd) ^ "\n")

val _ = print "Sending message...\n"
val _ = Socket.output serverfd "Hello Socket World"

val _ = print "Closing socket...\n"
val _ = Socket.close serverfd

val _ = print "Done\n"
