

fun decodeUUID (u : coq_UUID) = 
  (* Splits at ":" character, into (ip, port) *)
  let val colonInt = 
        case (String.findi (fn c => (Char.chr 58) = c) 0 u) of
          None => raise Exception "Unable to decode UUID, no splitting ':' found"
          | Some v => v
      val ip = String.substring u 0 colonInt
      (* This is retrieving the rest of the string *)
      val port = String.extract u (colonInt + 1) None
      val port' = case Int.fromString port of
                    Some v => v
                    | None => raise Exception "Unable to decode UUID, port not integer"
  in
    (ip, port')
  end

(** val make_JSON_Network_Request :
    coq_UUID -> coq_JSON -> (coq_JSON, string) coq_ResultT **)

fun make_JSON_Network_Request (u : coq_UUID) (js : coq_JSON) =
  (let val (ip, port) = decodeUUID u
      val _ = print ("Decoded UUID to: " ^ ip ^ ":" ^ (Int.toString port) ^ "\n")
      val fd = Socket.connect ip port
      val _ = print ("Connected to " ^ ip ^ ":" ^ (Int.toString port) ^ "\n")
      val sendReq = Socket.output fd (coq_JSON_to_string js)
      val resp = Socket.inputAll fd
  in
    string_to_JSON resp
  end) : (coq_JSON, string) coq_ResultT 

(** val aspid_to_fs_location : coq_ASP_ID -> coq_FS_Location **)

fun aspid_to_fs_location (a : coq_ASP_ID) =
  a

(** val make_JSON_FS_Location_Request :
    coq_FS_Location -> coq_FS_Location -> coq_JSON -> (coq_JSON, string)
    coq_ResultT **)
fun make_JSON_FS_Location_Request (aspBin : coq_FS_Location) (conc_asp_loc : coq_FS_Location) (js : coq_JSON) = 
  (let val loc = aspBin ^ "/" ^ (conc_asp_loc)
      val _ = print ("Sending a request to the FS: " ^ loc ^ "\n")
      val req_str = loc ^ " \"" ^ (SysFFI.shellEscapeString (coq_JSON_to_string js)) ^ "\""
      val _ = print ("Request string: " ^ req_str ^ "\n")
      val resp = SysFFI.c_popen_string req_str
      val _ = print ("Got back a response from the ASP: \n" ^ resp ^ "\n")
  in
    string_to_JSON resp
  end) : (coq_JSON, string) coq_ResultT

(* NOTE: Deprecated Features 
(** val do_asp :
    coq_ASP_PARAMS -> coq_RawEv -> coq_Plc -> coq_Event_ID -> coq_AM_Config
    -> (coq_BS, coq_DispatcherErrors) coq_ResultT **)

fun do_asp params e mpl _ ac =
  let val Coq_mkAmConfig _ _ aspCb _ _ _ _ = ac in
  aspCb params mpl (encodeEvRaw e) e end

(** val doRemote_uuid :
    coq_Term -> coq_UUID -> coq_RawEv -> (coq_RawEv, coq_CallBackErrors)
    coq_ResultT **)

fun doRemote_uuid t uuid rawEv = 
    let val authEv = []
        val authEt = Coq_mt 
    in 
      Coq_resultC (am_sendReq' t uuid (Coq_evc authEv authEt) rawEv)
    end

  (* failwith "AXIOM TO BE REALIZED" 

  fun am_sendReq' (t : coq_Term) (targUUID : coq_UUID) 
                    (authTok : coq_ReqAuthTok) (ev : (bs list))  =
  
  *)

(** val do_remote :
    coq_Term -> coq_Plc -> coq_EvC -> coq_AM_Config -> (coq_RawEv,
    coq_DispatcherErrors) coq_ResultT **)

fun do_remote t pTo e ac =
  let val remote_uuid_res =
    let val Coq_mkAmConfig _ _ _ _ plcCb _ _ = ac in plcCb pTo end
  in
  (case remote_uuid_res of
     Coq_errC e0 => Coq_errC e0
   | Coq_resultC uuid =>
     (case doRemote_uuid t uuid (get_bits e) of
        Coq_errC _ => Coq_errC (Runtime errStr_doRemote_uuid)
      | Coq_resultC v => Coq_resultC v)) end
*)

(** val parallel_vm_thread : coq_Loc -> coq_EvC **)

fun parallel_vm_thread loc = mt_evc
  (* failwith "AXIOM TO BE REALIZED" *)



(*
(** val am_sendReq :
    coq_Term -> coq_Plc -> coq_ReqAuthTok -> coq_RawEv -> coq_RawEv **)

val am_sendReq =
  failwith "AXIOM TO BE REALIZED"

*)

(** val do_start_par_thread :
    coq_Loc -> coq_Core_Term -> coq_RawEv -> unit coq_IO **)

fun do_start_par_thread _ _ _ =
  err_ret ()

(** val do_wait_par_thread : coq_Loc -> coq_EvC coq_IO **)

fun do_wait_par_thread loc =
  err_ret (parallel_vm_thread loc)

(** val requester_bound : coq_Term -> coq_Plc -> coq_ReqAuthTok -> bool **)

fun requester_bound t p tok = True
 (* failwith "AXIOM TO BE REALIZED" *)

(** val appraise_auth_tok : coq_AppResultC -> bool **)

fun appraise_auth_tok appres = True
  (* failwith "AXIOM TO BE REALIZED" *)
