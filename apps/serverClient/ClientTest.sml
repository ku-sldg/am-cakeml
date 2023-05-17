(* Depends on: util, copland, am/Measurements, am/ServerAm *)

val dir = "testDir"

val subterm = demo_phrase (* (Asp (Aspc (Id (S O)) [dir])) *)
val term = subterm (* Coq_att (S (S O)) subterm *) (* Att (S O) (Lseq subterm (Asp Sig)) *)


                   (*

val goldenHash = BString.unshow "7BE9FDA48F4179E611C698A73CFF09FAF72869431EFEE6EAAD14DE0CB44BBF66503F752B7A8EB17083355F3CE6EB7D2806F236B25AF96A24E22B887405C20081"

fun appraise nonce pub ev = case ev of
      G evSign (U (Id (S O)) [dir] evHash (N (Id O) evNonce Mt)) =>
          if evNonce <> nonce then
              Err "Bad nonce value"
          else if evHash <> goldenHash then
              Err "Bad hash value"
          else if not (Option.valOf (verifySig ev pub)) then
              Err "Bad signature"
          else Ok ()
    | _ => Err "Unexpected shape of evidence"
                   *)


(*                   
exception DispatchErr string
(* coq_Plc -> nsMap -> coq_Plc -> (bs list) -> coq_Term -> (bs list) *)
fun socketDispatch me nsMap pl ev t =
    let val addr = case Map.lookup nsMap pl of
              Some a => a
            | None => raise DispatchErr ("Place "^ plToString pl ^" not in nameserver map")
        val req  = (REQ me pl nsMap t ev)
        val fd   = Socket.connect addr 5000
        val (RES _ _ ev) = (serverSend fd req; serverRcv fd)
     in Socket.close fd;
        ev
    end
*)


(*              

(* coq_Term -> () *)
fun sendReq t pl nsMap (* am key *) = 
    let val nonce = Random.random (Random.seed (Meas.urand 32)) 16
        val me = S O
        val ev    = socketDispatch me nsMap pl [nonce] t (*run_cvm_rawEv t me [nonce]*) (* evalTerm am (N (Id O) nonce Mt) term *)
     in print ("Sent term:\n" ^ termToString term ^ "\n\nNonce:\n" ^
               BString.show nonce ^ "\n\nEvidence recieved:\n" ^
               (rawEvToString ev) )  (*  ^ "\n\nAppraisal " ^ (
               case appraise nonce key ev of
                      Ok ()   => "succeeded (expected nonce and hash value; signature verified).\n"
                    | Err msg => "failed: " ^ msg ^ "\n")
              ) *)
    end
    handle Socket.Err s     => TextIOExtra.printLn_err ("Socket failure on connection: " ^ s)
         | Socket.InvalidFD => TextIOExtra.printLn_err "Invalid file descriptor"
         | DispatchErr s    => TextIOExtra.printLn_err ("Dispatch error: " ^ s)
         | _                => TextIOExtra.printLn_err "Fatal: unknown error"


*)
                                                       

(*
(* (string, string) map -> () *)
fun sendReqIni ini =
    case Option.map BString.unshow (Map.lookup ini "place.1.publicKey") of
      None => TextIOExtra.printLn_err "No public key found for place 1"
    | Some key => (
        case iniServerAm ini of
          Err e => TextIOExtra.printLn_err e
        | Ok am => sendReq am key
      )
    handle Word8Extra.InvalidHex => TextIOExtra.printLn_err "place.1.publicKey not in valid hex format"
*)

(* () -> () *)

                                                       
                                                       
fun main () = (* sendReq term *)

    let val name  = CommandLine.name ()
        val usage = ("Usage: " ^ name ^ " configurationFile\n"
                    ^ "e.g.   " ^ name ^ " config.ini\n")
        val toPl = S O
        val myPl = O
        val enc_test = decode_RawEv (encode_RawEv [(BString.fromString "one"),
                                                   (BString.fromString "two"),
                                                   (BString.fromString "three")])
        (* val dec_test = decode_RawEv enc_test *)
     in case CommandLine.arguments () of
              [fileName] => (
                  case parseIniFile fileName of
                    Err e  =>  let val _ = O in
                                    TextIOExtra.printLn_err e
                               end
                   | Ok ini =>
                     case (iniServerAm ini) of
                         Err e => let val _ = O in
                                       TextIOExtra.printLn_err e
                                  end
                       | Ok nsMap => let val _ = O in
                                         (* print ("Enc test: " ^ (BString.toString enc_test)); *)
                                         print ("Dec test: " ^ (rawEvToString enc_test));
                                         print "\nSending Request in ClientTest\n\n";
                                         let val rawev_res = sendReq term toPl nsMap []
                                             val et_computed = eval term myPl Coq_mt
                                             val appraise_res = run_gen_appraise term myPl Coq_mt rawev_res in
                                             print ("Evidence Type computed: \n" ^
                                                    (evToString et_computed) ^ "\n\n");
                                             print ("Appraisal EvidenceC computed: \n" ^
                                                    evidenceCToString appraise_res ^ "\n\n")
                                         end
                                        
                                     end
              )
           | _ => let val _ = O in
                       TextIOExtra.printLn_err usage
                  end
    end

        
val _ = main ()      
