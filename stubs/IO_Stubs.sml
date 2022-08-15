(** val do_asp : coq_ASP_PARAMS -> coq_RawEv -> coq_BS **)

fun do_asp ps e =
    let val res = empty_bs in
    print ("Running ASP with params: \n" ^ (aspParamsToString ps) ^ "\n");
    empty_bs
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
