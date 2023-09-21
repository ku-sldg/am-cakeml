(** val gen_nonce_if_none_local : coq_EvC option -> coq_EvC coq_AM **)

fun gen_nonce_if_none_local initEv = case initEv of
  Some _ => ret mt_evc
| None =>
  bind (am_newNonce gen_nonce_bits) (fn nid =>
    ret (Coq_evc (gen_nonce_bits :: []) (Coq_nn nid)))

(** val fromSomeOption : 'a1 -> 'a1 option -> 'a1 **)

fun fromSomeOption default opt = case opt of
  Some x => x
| None => default

(** val get_my_absman_generated : coq_Term -> coq_Plc -> coq_Manifest **)

fun get_my_absman_generated t myPlc =
  let val env = manifest_generator t myPlc in
  let val maybe_absMan = map_get coq_Eq_Class_ID_Type env myPlc in
  fromSomeOption empty_Manifest maybe_absMan end end

(** val run_cvm_local_am :
    coq_Term -> coq_Plc -> coq_RawEv -> coq_RawEv coq_AM **)

fun run_cvm_local_am t myPlc ls =
  bind get (fn st =>
    ret
      (run_cvm_rawEv t myPlc ls
        (let val Coq_mkAM_St _ _ amConfig = st in amConfig end)))

(** val config_AM_if_lib_supported :
    coq_Term -> coq_Plc -> coq_AM_Library -> unit coq_AM **)

fun config_AM_if_lib_supported t myPlc amLib =
  let val absMan = get_my_absman_generated t myPlc in
  let val supportsB = lib_supports_manifest_bool amLib absMan in
  (case supportsB of
     True =>
     let val amConf = manifest_compiler absMan amLib in
     put_amConfig amConf end
   | False => am_failm (Coq_am_dispatch_error Runtime)) end end

(** val config_AM_if_lib_supported_app :
    coq_Evidence -> coq_AM_Library -> unit coq_AM **)

fun config_AM_if_lib_supported_app et amLib =
  let val absMan = manifest_generator_app et in
  let val supportsB = lib_supports_manifest_app_bool amLib absMan in
  (case supportsB of
     True =>
     let val amConf = manifest_compiler absMan amLib in
     put_amConfig amConf end
   | False => am_failm (Coq_am_dispatch_error Runtime)) end end

(** val check_et_length : coq_Evidence -> coq_RawEv -> unit coq_AM **)

fun check_et_length et ls =
  case eqb nat_EqClass (et_size et) (length ls) of
    True => ret ()
  | False => am_failm (Coq_am_dispatch_error Runtime)

(** val get_am_policy : coq_PolicyT coq_AM **)

val get_am_policy : coq_PolicyT coq_AM =
  bind get (fn st =>
    ret
      (let val Build_ConcreteManifest _ concrete_policy _ _ _ _ _ _ _ _ =
         let val Coq_mkAmConfig concMan _ _ _ _ _ =
           let val Coq_mkAM_St _ _ amConfig = st in amConfig end
         in
         concMan end
       in
       concrete_policy end))

(** val check_disclosure_policy :
    coq_Term -> coq_Plc -> coq_Evidence -> unit coq_AM **)

fun check_disclosure_policy t p e =
  bind get_am_policy (fn policy =>
    case policy_list_not_disclosed t p e policy of
      True => ret ()
    | False => am_failm (Coq_am_dispatch_error Runtime))

(** val am_client_gen_local :
    coq_Term -> coq_Plc -> coq_EvC option -> coq_AM_Library -> coq_AM_Result
    coq_AM **)

fun am_client_gen_local t myPlc initEvOpt amLib =
  bind (gen_nonce_if_none_local initEvOpt) (fn evcIn =>
    let val Coq_evc init_ev init_et = evcIn in
    bind (config_AM_if_lib_supported t myPlc amLib) (fn _ =>
      bind (check_disclosure_policy t myPlc init_et) (fn _ =>
        bind (run_cvm_local_am t myPlc init_ev) (fn resev =>
          let val expected_et = eval t myPlc init_et in
          bind (check_et_length expected_et resev) (fn _ =>
            bind (config_AM_if_lib_supported_app expected_et amLib) (fn _ =>
              bind (gen_appraise_AM expected_et resev) (fn app_res =>
                ret (Coq_am_appev app_res)))) end))) end)
