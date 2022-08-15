
exception DispatchErr string
(* coq_Plc -> nsMap -> coq_Plc -> (bs list) -> coq_Term -> (bs list) *)
fun socketDispatch me nsMap pl ev t =
    let val addr = case Map.lookup nsMap pl of
              Some a => a
            | None => raise DispatchErr ("Place "^ plToString pl ^" not in nameserver map")
        val req  = (REQ me pl nsMap t ev)
        val fd   = Socket.connect addr 5000
        val (RES _ _ resev) = (serverSend fd req; serverRcv fd)
     in Socket.close fd;
        resev
    end

(* coq_Term -> coq_Plc -> nsMap -> (bs list) -> (bs list) *)
fun sendReq t pl nsMap evv (* am key *) =
    let val me = O
        val resev = socketDispatch me nsMap pl evv t
    in
        (print ("Sent term:\n" ^ termToString t ^ "\n\nInitial raw evidence:\n" ^
                rawEvToString evv)); (* ^ "\n\nEvidence recieved:\n" ^
               (rawEvToString resev) )); *)
        resev
    end
(*
    handle Socket.Err s     => TextIOExtra.printLn_err ("Socket failure on connection: " ^ s)
         | Socket.InvalidFD => TextIOExtra.printLn_err "Invalid file descriptor"
         | DispatchErr s    => TextIOExtra.printLn_err ("Dispatch error: " ^ s)
         | _                => TextIOExtra.printLn_err "Fatal: unknown error" 
*)


                                                       
(* coq_Term -> coq_Plc -> nsMap -> (bs list) *)
fun sendReq_nonce t pl nsMap (* am key *) = 
    let val nonce = Random.random (Random.seed (Meas.urand 32)) 16 in
        sendReq t pl nsMap [nonce]
    end

(* coq_Term -> coq_Plc -> (bs list) -> (bs list) *)      
fun sendReq_local_ini t pl ev =
    let val name  = CommandLine.name ()
        val usage = ("Usage: " ^ name ^ " configurationFile\n"
                    ^ "e.g.   " ^ name ^ " config.ini\n") in
    case CommandLine.arguments () of
              [fileName] => (
                  case parseIniFile fileName of
                      Err e  => let val _ = O in
                                    TextIOExtra.printLn_err e; []
                                end
                    | Ok ini =>
                      let val _ = O in
                          print "Parsed ini OK\n";
                          case (iniServerAm ini) of
                              Err e => let val _ = O in
                                           TextIOExtra.printLn_err e; []
                                       end
                            | Ok nsMap =>
                              let val _ = O in
                                  print "Parsed INI Ok\n";
                                  sendReq t pl nsMap ev
                              end
                      end )
           | _ =>  let val _ = O in
                       TextIOExtra.printLn_err usage; []
                   end
    end
