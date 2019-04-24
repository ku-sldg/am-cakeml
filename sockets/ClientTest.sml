val _ = print "Connecting to server...\n"
val serverfd = Socket.connect "127.0.0.1" 50000
val _ = print "Connection established.\n"

val _ = Socket.output serverfd "Hello!"

val msg = Socket.inputAll serverfd
val _ = print ("Server message: " ^ msg ^ "\n")

val _ = Socket.close serverfd
val _ = print "Socket closed.\n"
