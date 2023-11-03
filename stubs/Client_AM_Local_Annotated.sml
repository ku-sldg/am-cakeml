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

(** val aspid_in_amlib_bool : coq_AM_Library -> coq_ASP_ID -> bool **)

fun aspid_in_amlib_bool al i =
  case map_get coq_Eq_Class_ID_Type
         (let val Build_AM_Library _ _ _ _ _ _ _ _ _ local_ASPS _ _ _ = al in
          local_ASPS end) i of
    Some _ => True
  | None => False

(** val uuid_plc_in_amlib_bool : coq_AM_Library -> coq_Plc -> bool **)

fun uuid_plc_in_amlib_bool al p =
  case map_get coq_Eq_Class_ID_Type
         (let val Build_AM_Library _ _ _ _ _ _ _ _ _ _ _ local_Plcs _ = al in
          local_Plcs end) p of
    Some _ => True
  | None => False

(** val pubkey_plc_in_amlib_bool : coq_AM_Library -> coq_Plc -> bool **)

fun pubkey_plc_in_amlib_bool al p =
  case map_get coq_Eq_Class_ID_Type
         (let val Build_AM_Library _ _ _ _ _ _ _ _ _ _ _ _ local_PubKeys = al in
          local_PubKeys end) p of
    Some _ => True
  | None => False

(** val appraisal_aspid_in_amlib_bool :
    coq_AM_Library -> (coq_Plc, coq_ASP_ID) prod -> bool **)

fun appraisal_aspid_in_amlib_bool al pr =
  case map_get (pair_EqClass coq_Eq_Class_ID_Type coq_Eq_Class_ID_Type)
         (let val Build_AM_Library _ _ _ _ _ _ _ _ _ _ local_Appraisal_ASPS _
            _ = al
          in
          local_Appraisal_ASPS end) pr of
    Some _ => True
  | None => False

(** val lib_supports_aspids_bool :
    coq_ASP_ID list -> coq_AM_Library -> bool **)

fun lib_supports_aspids_bool ls al =
  forallb (aspid_in_amlib_bool al) ls

(** val lib_supports_uuid_plcs_bool :
    coq_Plc list -> coq_AM_Library -> bool **)

fun lib_supports_uuid_plcs_bool ls al =
  forallb (uuid_plc_in_amlib_bool al) ls

(** val lib_supports_pubkey_plcs_bool :
    coq_Plc list -> coq_AM_Library -> bool **)

fun lib_supports_pubkey_plcs_bool ls al =
  forallb (pubkey_plc_in_amlib_bool al) ls

(** val lib_supports_appraisal_aspids_bool :
    (coq_Plc, coq_ASP_ID) prod list -> coq_AM_Library -> bool **)

fun lib_supports_appraisal_aspids_bool ls al =
  forallb (appraisal_aspid_in_amlib_bool al) ls

(** val lib_supports_manifest_bool :
    coq_AM_Library -> coq_Manifest -> bool **)

fun lib_supports_manifest_bool al am =
  let val aspid_list =
    let val Build_Manifest _ asps _ _ _ _ _ = am in asps end
  in
  let val uuid_plcs_list =
    let val Build_Manifest _ _ _ uuidPlcs _ _ _ = am in uuidPlcs end
  in
  let val pubkey_plcs_list =
    let val Build_Manifest _ _ _ _ pubKeyPlcs _ _ = am in pubKeyPlcs end
  in
  let val appraisal_asps_list =
    let val Build_Manifest _ _ appraisal_asps _ _ _ _ = am in
    appraisal_asps end
  in
  let val aspid_list_bool = lib_supports_aspids_bool aspid_list al in
  let val uuid_plcs_list_bool = lib_supports_uuid_plcs_bool uuid_plcs_list al
  in
  let val pubkey_plcs_list_bool =
    lib_supports_pubkey_plcs_bool pubkey_plcs_list al
  in
  let val appraisal_aspids_list_bool =
    lib_supports_appraisal_aspids_bool appraisal_asps_list al
  in
  (case case case aspid_list_bool of
               True => uuid_plcs_list_bool
             | False => False of
          True => pubkey_plcs_list_bool
        | False => False of
     True => appraisal_aspids_list_bool
   | False => False) end end end end end end end end

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
   | False =>
     am_failm (Coq_am_dispatch_error (Runtime errStr_lib_supports_man_check))) end end

(** val config_AM_if_lib_supported_app :
    coq_Evidence -> coq_AM_Library -> unit coq_AM **)

fun config_AM_if_lib_supported_app et amLib =
  let val absMan = manifest_generator_app et in
  let val supportsB = lib_supports_manifest_bool amLib absMan in
  (case supportsB of
     True =>
     let val amConf = manifest_compiler absMan amLib in
     put_amConfig amConf end
   | False =>
     am_failm (Coq_am_dispatch_error (Runtime
       errStr_lib_supports_man_app_check))) end end

(** val check_et_length : coq_Evidence -> coq_RawEv -> unit coq_AM **)

fun check_et_length et ls =
  case eqb nat_EqClass (et_size et) (length ls) of
    True => ret ()
  | False => am_failm (Coq_am_dispatch_error (Runtime errStr_et_size))

(** val get_am_policy : coq_PolicyT coq_AM **)

val get_am_policy : coq_PolicyT coq_AM =
  bind get (fn st =>
    ret
      (let val Build_Manifest _ _ _ _ _ _ policy =
         let val Coq_mkAmConfig absMan _ _ _ _ _ =
           let val Coq_mkAM_St _ _ amConfig = st in amConfig end
         in
         absMan end
       in
       policy end))

(** val check_disclosure_policy :
    coq_Term -> coq_Plc -> coq_Evidence -> unit coq_AM **)

fun check_disclosure_policy t p e =
  bind get_am_policy (fn policy =>
    case policy_list_not_disclosed t p e policy of
      True => ret ()
    | False => am_failm (Coq_am_dispatch_error (Runtime errStr_privPolicy)))

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
