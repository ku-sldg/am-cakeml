(* Dependencies:  extracted/Term_Defs_Core.cml, extracted/Term_Defs.cml, 
     stubs/BS.sml, stubs, Example_Phrases_Demo_Admits.sml, 
     am/CoplandCommUtil.sml, ... (TODO: more IO dependencies?) *)


(** val do_asp : coq_ASP_PARAMS -> coq_RawEv -> coq_BS **)


fun do_asp ps e =
    case ps of Coq_asp_paramsC aspid args tpl tid =>
      let val res =
              case (aspid = cal_ak_aspid) of    
                  True => 
                    let val _ = () in
                          print ("Matched aspid:  " ^ aspid ^ "\n");
                          let val setupSuccess = Crypto.tpmSetup ()
                              val cal_akSuccess = Crypto.tpmCreateSigKey () in
                                if cal_akSuccess then BString.fromString "0" else BString.fromString "1"
                          end
                    end
                    
                | _ => 
                  case (aspid = get_data_aspid) of
                      True => 
                        let val _ = () in
                              print ("Matched aspid:  " ^ aspid ^ "\n");
                              let val dataRes = Crypto.getData () in
                                    dataRes
                              end
                        end
                      
                    | _ =>
                      case (aspid = tpm_sig_aspid) of
                          True =>
                            let val _ = () in
                                  print ("Matched aspid:  " ^ aspid ^ "\n");
                                  let val data = encode_RawEv e
                                      val sigRes = Crypto.tpmSign data in
                                        sigRes
                                  end
                            end

                        | _ =>
                          case (aspid = ssl_enc_aspid) of
                              True =>
                              let val _ = () in
                                  print ("Matched aspid:  " ^ aspid ^ "\n");
                                  let val plaintext =
                                          BString.toString (encode_RawEv e) 
                                      val ciphertext =
                                          Crypto.encryptOneShot
                                              priv1 pub2 plaintext in
                                      ciphertext
                                  end
                              end
                            | _ =>
                              case (aspid = pub_bc_aspid) of
                                  True => 
                              (* if aspid = pub_bc_aspid
                              then *)
                                  let
                                      (* FIX IDs *)
                                      val attestId = BString.unshow "deadbeef"
                                      val targetId = BString.unshow "facefeed"
                                      (* FIX change to target IP info *)
                                      val blockchainIp =
                                          HealthRecord.TcpIp blockchainIpAddr
                                                             blockchainIpPort
				      val pubkey_src_file = "src-pub.pem" (* "src-pub-temp.pem" *)
                                      val signingKeyNull =
                                          String.concat
                                              (Option.getOpt
                                                   (TextIO.b_inputLinesFrom pubkey_src_file)
                                                   [])
				      val _=(print ("\nRead Bytes from file '" ^ pubkey_src_file ^ "' :\n" ^ signingKeyNull))
                                      val signingKeyNullSize =
                                          String.size signingKeyNull
                                      val signingKeyNullEnd =
                                          if signingKeyNullSize > 1
                                          then signingKeyNullSize - 1
                                          else signingKeyNullSize
                                      val signingKey =
                                          BString.fromString
                                              ((String.substring
                                                    signingKeyNull
                                                    0
                                                    signingKeyNullEnd) ^ "\n")
				      (* val signingKey = signingKey' ^ "\n" *)
                                      (* val _ = print (String.concat ["\nSigning key size: ", Int.toString (BString.length signingKey), "\n"]) *)
                                      val phrase = Coq_asp NULL
                                      val hr = HealthRecord.healthRecord
                                                   targetId phrase (Json.fromBool True) None
                                                   attestId blockchainIp pub1 signingKey
                                                   (timestamp ())
                                      val hrAddResult = HealthRecord.addRecord
                                                            blockchainIpAddr blockchainIpPort jsonId
                                                            healthRecordContract userAddress attestId
                                                            targetId (HealthRecord.toJson hr)
                                  in
                                      case hrAddResult of
                                          Ok bstring => bstring
                                        | Err str =>
                                          (print (String.concat [str, "\n"]);
                                           BString.nulls 1)
                                  end
                                | _ => 
                                  case (aspid = store_clientData_aspid) of
                                      True => let val _ = (print ("\nRunning store_clientData asp here...\n"))
                                                  val outfile = "client_data.txt"
                                                  val ostream = TextIO.openOut outfile
                                                  val client_data = encode_RawEv e
                                                  val _ = TextIO.output ostream (BString.toString client_data)
                                                  val _ = TextIO.closeOut ostream
                                                  


                                              in 
                                                  BString.empty
                                              end
                                    | _ =>                     
                              (* else *)
                                      (print ("Matched OTHER aspid:  " ^ aspid ^ "\n");
                                       BString.fromString "v")
      in
          print ("Running ASP with params: \n" ^ (aspParamsToString ps) ^ "\n");
          res
      end
(* failwith "AXIOM TO BE REALIZED" *)

(** val doRemote_session : coq_Term -> coq_Plc -> coq_EvC -> coq_EvC **)

fun doRemote_session t toPl e =
    let val _ = empty_bs
    	val fromPl = O (* TODO: make param *) in
        print ("Running doRemote_session\n");
        Coq_evc (sendReq_local_ini t fromPl toPl (get_bits e)) Coq_mt
    end
  (* TODO:  Is the dummy Evidence Type value (Coq_mt) ok here? *)
  (* failwith "AXIOM TO BE REALIZED" *)

(** val parallel_vm_thread : coq_Loc -> coq_EvC **)

fun parallel_vm_thread loc = mt_evc
  (* failwith "AXIOM TO BE REALIZED" *)

(** val do_asp' : coq_ASP_PARAMS -> coq_RawEv -> coq_BS coq_IO **)

fun do_asp' params e =
  ret (do_asp params e)

(** val doRemote_session' :
    coq_Term -> coq_Plc -> coq_EvC -> coq_EvC coq_IO **)

fun doRemote_session' t pTo e =
  ret (doRemote_session t pTo e)

(** val do_start_par_thread :
    coq_Loc -> coq_Core_Term -> coq_RawEv -> unit coq_IO **)

fun do_start_par_thread _ _ _ =
  ret ()

(** val do_wait_par_thread : coq_Loc -> coq_EvC coq_IO **)

fun do_wait_par_thread loc =
  ret (parallel_vm_thread loc)
