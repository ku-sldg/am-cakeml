(* Depends on Copland *)

(* val protocol = Lseq
    (Asp (Aspc (Id (S (S (S O)))) []))
    (Asp Sig) *)

val pythonPath = "/usr/bin/python3"
val dtuDir = "/media/vclient/dtu-soldier-client"
val dtuFiles = pythonPath :: (List.map (fn file => dtuDir ^ "/" ^ file)
               ["dtu_soldier_client.py", "dtu_soldier_client_constants.py",
                 "https_client.py", "https_server_handler.py", "ndo_client.py"])

(* Assume non-empty list! *)
fun lseqList l = case l of 
      x :: [] => x
    | x :: y :: [] => Lseq x y
    | x :: y :: z  => Lseq x (Lseq y (lseqList z))

fun hashFileProtocol arg   = Asp (Aspc (Id O) [arg])
fun hashFilesProtocol args = lseqList (List.map hashFileProtocol args)

val dtuFileHashProtocol = hashFilesProtocol dtuFiles
val pythonDynamicHashProtocol = Asp (Aspc (Id (S (S O))) ["python3"])

val protocol =
    Lseq
        (Bseq (NONE, ALL)
            (Lseq (Lseq dtuFileHashProtocol pythonDynamicHashProtocol) (Asp Hsh))
            (Asp Cpy))
        (Asp Sig)