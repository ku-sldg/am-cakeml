val serverfd = connect "127.0.0.1" 3000
val _ = TextIO.output serverfd "Hello World"
val _ = TextIO.close serverfd
