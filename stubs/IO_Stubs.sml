(* Dependencies:  extracted/Term_Defs_Core.cml, extracted/Term_Defs.cml, 
     stubs/BS.sml, am/CoplandCommUtil.sml, ... (TODO: more IO dependencies?) *)


(** val do_asp : coq_ASP_PARAMS -> coq_RawEv -> coq_BS **)


fun do_asp ps e =
    case ps of
        Coq_asp_paramsC aspid args tpl tid =>
        let val res =
                case (aspid = get_data_aspid) of
                    True =>
                    let val _ = () in
                        print ("Matched aspid:  " ^ aspid ^ "\n");
                        BString.fromString "data"
                    end
                  | _ =>
                    case (aspid = tpm_sig_aspid) of
                        True =>
                        let val _ = () in
                            print ("Matched aspid:  " ^ aspid ^ "\n");
                            let val msg = encode_RawEv e
                                val prikey = privGood
                                val sigRes = Crypto.signMsg prikey msg in
                                sigRes
                            end

                            (*
                            BString.fromString ("sig( " ^
                                                    (rawEvToString e)
                                                    ^ " )") *)
                        end
                      | _ =>
                        case (aspid = ssl_enc_aspid) of
                            True =>
                            let val _ = () in
                                print ("Matched aspid:  " ^ aspid ^ "\n");
                                let val plaintext =
                                        (*
                                        "The quick brown fox jumped over the lazy dog." *)
                                        
                                        BString.toString (encode_RawEv e) 
                                    val ciphertext = Crypto.encryptOneShot
                                                         priv1 pub2 plaintext in
                                    ciphertext
                                end
                                (*
                                BString.fromString ("enc( " ^
                                                        (rawEvToString e)
                                                        ^ " )")
                                *)
                            end
                          | _ =>
                            let val _ = () in
                                print ("Matched OTHER aspid:  " ^ aspid ^ "\n");
                                BString.fromString "v"
                            end
                                                           
                                         

        in
            print ("Running ASP with params: \n" ^ (aspParamsToString ps) ^ "\n");
            res
        end
(* failwith "AXIOM TO BE REALIZED" *)

(** val doRemote_session : coq_Term -> coq_Plc -> coq_EvC -> coq_EvC **)

fun doRemote_session t p e =
    let val _ = empty_bs in
        print ("Running doRemote_session\n");
        Coq_evc (sendReq_local_ini t p (get_bits e)) Coq_mt
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
