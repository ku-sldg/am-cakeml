(* TODO: dependencies *)
structure ManifestUtils = struct
  exception Excn string

  type privateKey_t       = coq_PrivateKey
  type Partial_ASP_CB     = (* coq_ConcreteManifest -> *) coq_DispatcherErrors coq_ASPCallback
  type Partial_Plc_CB     = (* coq_ConcreteManifest -> *) coq_PlcCallback
  type Partial_PubKey_CB  = (* coq_ConcreteManifest -> *) coq_PubKeyCallback
  type Partial_UUID_CB    = (* coq_ConcreteManifest -> *) coq_UUIDCallback

  type AM_Config = coq_AM_Config 
  
  (*
  (coq_ConcreteManifest * privateKey_t *
      (coq_ASPCallback) * 
      (coq_PlcCallback) * 
      (coq_PubKeyCallback) * 
      (coq_UUIDCallback))
    *)

  val local_formal_manifest = Ref (Err "Formal Manifest not set") : ((coq_Manifest, string) result) ref

  val local_concreteManifest = Ref (Err "Concrete Manifest not set") : ((coq_ConcreteManifest, string) result) ref

  val local_aspCb = Ref (Err "ASP Callback not set") : ((Partial_ASP_CB, string) result) ref

  val local_plcCb = Ref (Err "Plc Callback not set") : ((Partial_Plc_CB, string) result) ref

  val local_pubKeyCb = Ref (Err "PubKey Callback not set") : ((Partial_PubKey_CB, string) result) ref

  val local_uuidCb = Ref (Err "UUID callback not set") : ((Partial_UUID_CB, string) result) ref

  val local_PrivKey = Ref (Err "Private Key not set") : ((privateKey_t, string) result) ref

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
    (let val (Build_ConcreteManifest my_plc _ _ _ _ _ _ _ _ _) = get_ConcreteManifest() in
      my_plc
    end) : coq_Plc

  (* Compiles a concrete manifest from a Formal Manifest and AM Lib
    : coq_Manifest -> coq_AM_Library -> coq_ConcreteManifest *)
  fun compile_manifest (fm : coq_Manifest) (al : coq_AM_Library) =
    (case (manifest_compiler fm al) of
      Coq_mkAmConfig concrete _ _ _ _ _ => concrete) : coq_ConcreteManifest

      (*
      Coq_pair (Coq_pair (Coq_pair (Coq_pair (Coq_pair concrete _) _) _) _) _ => concrete
    )  : coq_ConcreteManifest *)

  (* Setups up the relevant information and compiles the manifest
      : coq_Manifest -> coq_AM_Library -> () *)
  fun setup_AM_config (fm : coq_Manifest) (al : coq_AM_Library) (privKey : privateKey_t) (* (t:coq_Term) *) =
    (case (manifest_compiler fm al) of
      Coq_mkAmConfig concrete aspDisp appDisp plcDisp pubKeyDisp uuidDisp =>
      (* Coq_pair (Coq_pair (Coq_pair (Coq_pair concrete aspDisp) plcDisp) pubKeyDisp) uuidDisp  => *)
        let val _ = local_formal_manifest := Ok fm
            val _ = local_concreteManifest := Ok concrete
            val _ = local_aspCb := Ok aspDisp
            val _ = local_plcCb := Ok plcDisp
            val _ = local_pubKeyCb := Ok pubKeyDisp
            val _ = local_uuidCb := Ok uuidDisp
            val _ = local_PrivKey := Ok privKey
            (* val _ = local_authTerm := Ok t *)
            (*
            val _ = local_authEv := 
              let val myPlc = get_myPlc () in 
                run_cvm_rawEv t myPlc coq_mt
              end
              *)
        in
          ()
        end) : unit

  (* Retrieves the formal manifest, or exception if not configured 
    : _ -> coq_Manifest *)
  fun get_FormalManifest _ =
    (case (!local_formal_manifest) of
      (Ok v) => v
      | Err e => raise Excn e) : coq_Manifest

  (* Sets the concrete manifest, should not throw
    : coq_ConcreteManifest -> () *)
  fun set_ConcreteManifest (c : coq_ConcreteManifest) =
    let val _ = local_concreteManifest := Ok c
    in 
      ()
    end

  (* Retrieves the asp callback, or exception if not configured 
    : _ -> coq_ASPCallback *)
  fun get_ASPCallback _ =
    (let val cm = get_ConcreteManifest() 
    in
      case (!local_aspCb) of
      (Ok v) => (v (*cm*))
      | Err e => raise Excn e
    end) : coq_DispatcherErrors coq_ASPCallback

  (* Retrieves the plc callback, or exception if not configured 
    : _ -> coq_CakeML_PlcCallback *)
  fun get_PlcCallback _ =
    (let val cm = get_ConcreteManifest()
    in
      case (!local_plcCb) of
      (Ok v) => (v (*cm*))
      | Err e => raise Excn e
    end) : coq_PlcCallback

  (* Retrieves the asp callback, or exception if not configured 
    : _ -> coq_CakeML_PubKeyCallback *)
  fun get_PubKeyCallback _ =
    (let val cm = get_ConcreteManifest()
    in
      case (!local_pubKeyCb) of
      (Ok v) =>
      let val _ = print "\n\nLooking up pubkey callback\n\n" in
        (v (*cm*))
      end
      | Err e => raise Excn e
    end) : coq_PubKeyCallback

  (* Retrieves the asp callback, or exception if not configured 
    : _ -> coq_CakeML_uuidCallback *)
  fun get_UUIDCallback _ =
    (let val cm = get_ConcreteManifest()
    in
      case (!local_uuidCb) of
      (Ok v) => (v (*cm*))
      | Err e => raise Excn e
    end) : coq_UUIDCallback


(*
  datatype ('a, 'e) coq_ResultT =
  Coq_errC 'e
| Coq_resultC 'a

*)

  
  (* Retrieves the uuid corresponding to this processes Manifest/AM_Config
      throws an exception if configuration not completed
    : _ -> coq_UUID *)
  fun get_myUUID _ = 
    (let val my_plc = get_myPlc()
        val plc_to_uuid = get_PlcCallback()
        val res_uuid = plc_to_uuid my_plc
    in
      case res_uuid of 
        Coq_errC e => raise Excn ("get_myUUID error") 
      | Coq_resultC my_uuid => my_uuid
    end) : coq_UUID

  (* Retrieves the private key corresponding to this processes Manifest/AM_Config
      throws an exception if configuration not completed
    : _ -> coq_PrivateKey *)
  fun get_myPrivateKey _ = 
    (case (!local_PrivKey) of
      (Ok v) => v
      | Err e => raise Excn e) : coq_PrivateKey

  (* Retrieves all AM config information, 
      if a Manifest has not be compiled yet it will throw an error
    : _ -> AM_Config *)
  fun get_AM_config _ =
    (let val cm = get_ConcreteManifest()
        (* val privKey = get_myPrivateKey() *)
        val aspCb = get_ASPCallback()
        val plcCb = get_PlcCallback()
        val pubKeyCb = get_PubKeyCallback()
        val uuidCb = get_UUIDCallback()
    in
      Coq_mkAmConfig cm aspCb aspCb plcCb pubKeyCb uuidCb
    end) : AM_Config

  (* Directly combines setup and get steps in one function call. 
      Additionally, we must provide a "fresh" Concrete Manifest to 
      use for manifest operations
    : coq_Manifest -> coq_AM_Library -> AM_Config *)
  fun setup_and_get_AM_config (fm : coq_Manifest) (al : coq_AM_Library) (cm : coq_ConcreteManifest) (privKey : privateKey_t) (* (t:coq_Term) *) =
    (let val _ = setup_AM_config fm al privKey (*t*)
         val _ = set_ConcreteManifest cm in
      get_AM_config()
    end) : AM_Config
end