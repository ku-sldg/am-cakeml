structure ManifestUtils = struct
  exception Excn string

  type Partial_ASP_CB     = coq_ConcreteManifest -> coq_CakeML_ASPCallback
  type Partial_Plc_CB     = coq_ConcreteManifest -> coq_CakeML_PlcCallback
  type Partial_PubKey_CB  = coq_ConcreteManifest -> coq_CakeML_PubKeyCallback
  type Partial_UUID_CB    = coq_ConcreteManifest -> coq_CakeML_uuidCallback

  type AM_Config = (coq_ConcreteManifest * 
      (coq_CakeML_ASPCallback) * 
      (coq_CakeML_PlcCallback) * 
      (coq_CakeML_PubKeyCallback) * 
      (coq_CakeML_uuidCallback))

  val local_formal_manifest = Ref (Err "Formal Manifest not set") : ((coq_Manifest, string) result) ref

  val local_concreteManifest = Ref (Err "Concrete Manifest not set") : ((coq_ConcreteManifest, string) result) ref

  val local_aspCb = Ref (Err "ASP Callback not set") : ((Partial_ASP_CB, string) result) ref

  val local_plcCb = Ref (Err "Plc Callback not set") : ((Partial_Plc_CB, string) result) ref

  val local_pubKeyCb = Ref (Err "PubKey Callback not set") : ((Partial_PubKey_CB, string) result) ref

  val local_uuidCb = Ref (Err "UUID callback not set") : ((Partial_UUID_CB, string) result) ref

  (* Setups up the relevant information and compiles the manifest
      : coq_Manifest -> coq_AM_Library -> () *)
  fun setup_AM_config (fm : coq_Manifest) (al : coq_AM_Library) =
    (case (manifest_compiler fm al) of
      Coq_pair (Coq_pair (Coq_pair (Coq_pair concrete aspDisp) plcDisp) pubKeyDisp) uuidDisp =>
        let val _ = local_formal_manifest := Ok fm
            val _ = local_concreteManifest := Ok concrete
            val _ = local_aspCb := Ok aspDisp
            val _ = local_plcCb := Ok plcDisp
            val _ = local_pubKeyCb := Ok pubKeyDisp
            val _ = local_uuidCb := Ok uuidDisp
        in
          ()
        end) : unit

  (* Retrieves the formal manifest, or exception if not configured 
    : _ -> coq_Manifest *)
  fun get_FormalManifest _ =
    (case (!local_formal_manifest) of
      (Ok v) => v
      | Err e => raise Excn e) : coq_Manifest
    
  (* Retrieves the concrete manifest, or exception if not configured 
    : _ -> coq_ConcreteManifest *)
  fun get_ConcreteManifest _ =
    (case (!local_concreteManifest) of
      (Ok v) => v
      | Err e => raise Excn e) : coq_ConcreteManifest

  (* Retrieves the plc corresponding to this processes Manifest/AM_Config
      throws an exception if configuration not completed
    : _ -> coq_Plc *)
  fun get_myPlc _ = 
    (let val (Build_ConcreteManifest my_plc _ _ _ _ _ _ _ _) = get_ConcreteManifest() in
      my_plc
    end) : coq_Plc

  (* Retrieves the asp callback, or exception if not configured 
    : _ -> coq_CakeML_ASPCallback *)
  fun get_ASPCallback _ =
    (let val cm = get_ConcreteManifest() 
    in
      case (!local_aspCb) of
      (Ok v) => (v cm)
      | Err e => raise Excn e
    end) : coq_CakeML_ASPCallback

  (* Retrieves the plc callback, or exception if not configured 
    : _ -> coq_CakeML_PlcCallback *)
  fun get_PlcCallback _ =
    (let val cm = get_ConcreteManifest()
    in
      case (!local_plcCb) of
      (Ok v) => (v cm)
      | Err e => raise Excn e
    end) : coq_CakeML_PlcCallback

  (* Retrieves the asp callback, or exception if not configured 
    : _ -> coq_CakeML_PubKeyCallback *)
  fun get_PubKeyCallback _ =
    (let val cm = get_ConcreteManifest()
    in
      case (!local_pubKeyCb) of
      (Ok v) => (v cm)
      | Err e => raise Excn e
    end) : coq_CakeML_PubKeyCallback

  (* Retrieves the asp callback, or exception if not configured 
    : _ -> coq_CakeML_uuidCallback *)
  fun get_UUIDCallback _ =
    (let val cm = get_ConcreteManifest()
    in
      case (!local_uuidCb) of
      (Ok v) => (v cm)
      | Err e => raise Excn e
    end) : coq_CakeML_uuidCallback

  (* Retrieves all AM config information, 
      if a Manifest has not be compiled yet it will throw an error
    : _ -> AM_Config *)
  fun get_AM_config _ =
    (let val cm = get_ConcreteManifest()
        val aspCb = get_ASPCallback()
        val plcCb = get_PlcCallback()
        val pubKeyCb = get_PubKeyCallback()
        val uuidCb = get_UUIDCallback()
    in
      (cm, aspCb, plcCb, pubKeyCb, uuidCb)
    end) : AM_Config
    (* (case (!local_concreteManifest, !local_aspCb, !local_plcCb, !local_pubKeyCb, !local_uuidCb) of
      (Ok cm, Ok aspCb, Ok plcCb, Ok pubKeyCb, Ok uuidCb) => (cm, aspCb, plcCb, pubKeyCb, uuidCb)
      | (_, _, _, _, _) => raise Excn "One of the necessary fields is ERR") : AM_Config *)

  (* Directly combines setup and get steps in one function call
    : coq_Manifest -> coq_AM_Library -> AM_Config *)
  fun setup_and_get_AM_config (fm : coq_Manifest) (al : coq_AM_Library) =
    (let val _ = setup_AM_config fm al in
      get_AM_config()
    end) : AM_Config
end