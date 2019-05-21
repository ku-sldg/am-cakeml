val jsonTerm = "{\"data\":[[\"ALL\",\"NONE\"],{\"name\":\"NONCE\"},{\"name\":\"NONCE\"}],\"name\":\"BRS\"}"

fun main () =
    let val serverfd = Socket.connect "127.0.0.1" 50000
     in Socket.output serverfd jsonTerm;
        print ((Socket.inputAll serverfd) ^ "\n");
        Socket.close serverfd
    end

val _ = main ()
