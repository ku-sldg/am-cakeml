
exception DispatchErr string
(* coq_Plc -> nsMap -> coq_Plc -> (bs list) -> coq_Term -> (bs list) *)
fun socketDispatch fromPl nsMap toPl ev t =
    let val addr = case Map.lookup nsMap toPl of
              Some a => a
            | None => raise DispatchErr ("Place "^ plToString toPl ^" not in nameserver map")
        val req  = (REQ fromPl toPl nsMap t ev)
        val port =
            case toPl of
                (S O) => 5000
              | (S (S O)) => 5002
              | _ => 5000 (* TODO: fix this hard-coding... *)
        val fd   = Socket.connect addr port
        val (RES _ _ resev) = (serverSend fd req; serverRcv fd)
     in Socket.close fd;
        resev
    end

(* coq_Term -> coq_Plc -> nsMap -> (bs list) -> (bs list) *)
fun sendReq t toPl nsMap evv (* am key *) =
    let val fromPl = O
        val resev = socketDispatch fromPl nsMap toPl evv t
    in
        (print ("Sent term:\n" ^ termToString t ^
                "\n\nInitial raw evidence:\n" ^
                rawEvToString evv ^ "\nRaw evidence received:\n" ^
                rawEvToString resev ^ "\n\n"));
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
                          print "Parsed INI OK\n";
                          case (iniServerAm ini) of
                              Err e => let val _ = O in
                                           TextIOExtra.printLn_err e; []
                                       end
                            | Ok nsMap =>
                              let val _ = O in
                                  print "Parsed nsMap of INI OK\n\n";
                                  print "\nSending Request in senReq_ocal_ini\n\n"; 
                                  sendReq t pl nsMap ev
                              end
                      end )
           | _ =>  let val _ = O in
                       TextIOExtra.printLn_err usage; []
                   end
    end
