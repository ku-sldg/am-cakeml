val clientfd = accept (listen 3000 1)
val message = TextIO.inputAll clientfd
val _ = TextIO.close clientfd
val _ = print (message ^ "\n")
