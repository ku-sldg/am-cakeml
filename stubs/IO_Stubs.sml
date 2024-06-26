

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

val make_JSON_Network_Request : (coq_UUID -> coq_JSON -> (coq_JSON, string)
                                coq_ResultT) =
  (let val (ip, port) = decodeUUID u
      val fd = Socket.connect ip port
      val _ = print ("Connected to " ^ ip ^ ":" ^ (Int.toString port) ^ "\n")
      val sendReq = Socket.output fd (coq_JSON_to_string js)
      val resp = Socket.inputAll fd
  in
    string_to_JSON resp
  end) : (coq_JSON, string) coq_ResultT 

(** val make_JSON_FS_Location_Request :
    coq_FS_Location -> coq_JSON -> (coq_JSON, string) coq_ResultT **)

val make_JSON_FS_Location_Request : (coq_FS_Location -> coq_JSON ->
                                    (coq_JSON, string) coq_ResultT) =
  (let val _ = print ("Sending a request to the FS: " ^ loc ^ "\n")
      val resp = c_popen_string (loc ^ " " ^ (coq_JSON_to_string js))
      val _ = print ("Got back a response from the ASP: " ^ resp ^ "\n")
      val _ = print ("String Length is: " ^ Int.toString (String.size resp) ^ "\n")
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
  ret ()

(** val do_wait_par_thread : coq_Loc -> coq_EvC coq_IO **)

fun do_wait_par_thread loc =
  ret (parallel_vm_thread loc)

(** val requester_bound : coq_Term -> coq_Plc -> coq_ReqAuthTok -> bool **)

fun requester_bound t p tok = True
 (* failwith "AXIOM TO BE REALIZED" *)

(** val appraise_auth_tok : coq_AppResultC -> bool **)

fun appraise_auth_tok appres = True
  (* failwith "AXIOM TO BE REALIZED" *)



(** val is_local_appraisal : coq_AM_Library -> bool **)
fun is_local_appraisal amLib =
  (* Basically if we dont have a clone its local *)
  case amLib of 
    Build_AM_Library clone_uuid _ _ _ _ => clone_uuid = ""


(** val lib_supports_manifest_bool :
    coq_AM_Library -> coq_Manifest -> bool **)


fun plc_aspid_pair_toString ((a,b): (coq_Plc * coq_ASP_ID)) = 
    "(" ^ (plToString a) ^ ", " ^ (aspIdToString b) ^ ")"
      : string

(** val pretty_print_manifest : coq_Manifest -> coq_StringT **)

fun pretty_print_manifest (m:coq_Manifest) (* : coq_StringT *) = 
  "\nAM Library does NOT support Manifest.\nHere is a Manifest that captures the offending fields (omitted by the AM Library): \n\n" ^
  (case m of 
    Build_Manifest p asp_ls appraisal_ls uuid_ls pubkey_ls targ_ls pol => 
    (* )"\tmy_plc: " ^ (plToString p) ^ *)
    "\n\tasps: " ^ (ListExtra.listToString asp_ls aspIdToString) ^
    "\n\tappraisal_asps: " ^ (ListExtra.listToString appraisal_ls plc_aspid_pair_toString) ^
    "\n\tuuidPlcs: " ^ (ListExtra.listToString uuid_ls plToString) ^
    "\n\tpubkeyPlcs: " ^ (ListExtra.listToString pubkey_ls plToString) ^
    "\n\ttargPlcs: " ^ (ListExtra.listToString targ_ls plToString) (* ^
    "\n\tpolicy: " ^ "True" *) 
    )

(** val pretty_print_manifest : coq_Manifest -> coq_StringT **)

fun pretty_print_manifest_simple (m:coq_Manifest) (* : coq_StringT *) = 
  (case m of 
    Build_Manifest p asp_ls appraisal_ls uuid_ls pubkey_ls targ_ls pol => 
    (* )"\tmy_plc: " ^ (plToString p) ^ *)
    "\n\tasps: " ^ (ListExtra.listToString asp_ls aspIdToString) ^
    "\n\tappraisal_asps: " ^ (ListExtra.listToString appraisal_ls plc_aspid_pair_toString) ^
    "\n\tuuidPlcs: " ^ (ListExtra.listToString uuid_ls plToString) ^
    "\n\tpubkeyPlcs: " ^ (ListExtra.listToString pubkey_ls plToString) ^
    "\n\ttargPlcs: " ^ (ListExtra.listToString targ_ls plToString) (* ^
    "\n\tpolicy: " ^ "True" *) 
    )
