(* TODO: dependencies *)
structure ManifestUtils = struct
  exception Excn string

  type privateKey_t       = coq_PrivateKey
  type Partial_ASP_CB     = coq_DispatcherErrors coq_ASPCallback
  type Partial_Plc_CB     = coq_PlcCallback
  type Partial_PubKey_CB  = coq_PubKeyCallback

  type AM_Config = coq_AM_Config 

  val local_formal_manifest = Ref (Err "Formal Manifest not set") : ((coq_Manifest, string) result) ref

  val local_uuid_clone = Ref (Err "UUID clone not set") : ((coq_UUID, string) result) ref

  val local_amConfig = Ref (Err "AM_Config not set") : ((coq_AM_Config, string) result) ref

  val local_amLib = Ref (Err "AM_Lib not set") : ((coq_AM_Library, string) result) ref

  val local_aspCb = Ref (Err "ASP Callback not set") : ((Partial_ASP_CB, string) result) ref

  val local_plcCb = Ref (Err "Plc Callback not set") : ((Partial_Plc_CB, string) result) ref

  val local_pubKeyCb = Ref (Err "PubKey Callback not set") : ((Partial_PubKey_CB, string) result) ref

  val local_PrivKey = Ref (Err "Private Key not set") : ((privateKey_t, string) result) ref
  
   (* Retrieves the AM_Config, or exception if not configured 
    : _ -> coq_AM_Config *)
  fun get_local_amConfig _ =
    (case (!local_amConfig) of
      (Ok v) => v
      | Err e => raise Excn e) : coq_AM_Config

  (* Retrieves the AM_Lib, or exception if not configured 
    : _ -> coq_AM_Library *)
  fun get_local_amLib _ =
    (case (!local_amLib) of
      (Ok v) => v
      | Err e => raise Excn e) : coq_AM_Library

    (* Retrieves the formal manifest, or exception if not configured 
    : _ -> coq_Manifest *)
  fun get_FormalManifest _ =
    (case (!local_formal_manifest) of
      (Ok v) => v
      | Err e => raise Excn e) : coq_Manifest

  (* Retrieves the UUID clone address, or exception if not configured 
    : _ -> coq_UUID *)
  fun get_Clone_uuid _ =
    (case (!local_uuid_clone) of
      (Ok v) => v
      | Err e => raise Excn e) : coq_UUID

    (* Retrieves the plc corresponding to this processes Manifest/AM_Config
      throws an exception if configuration not completed
    : _ -> coq_Plc *)
  fun get_myPlc _ = 
    (let val (Build_Manifest my_plc _ _ _ _ _ _) = get_FormalManifest() in
      my_plc
    end) : coq_Plc

  (* Setups up the relevant information and compiles the manifest
      : coq_Manifest -> coq_AM_Library -> () *)
  fun setup_AM_config (fm : coq_Manifest) (al : coq_AM_Library) (privKey : privateKey_t) (* (t:coq_Term) *) =
    (case (manifest_compiler fm al) of
      Coq_mkAmConfig compiled_fm clone_uuid aspDisp appDisp plcDisp pubKeyDisp =>
        let val _ = local_formal_manifest := Ok compiled_fm
            val _ = local_uuid_clone := Ok clone_uuid
            val _ = local_aspCb := Ok aspDisp
            val _ = local_plcCb := Ok plcDisp
            val _ = local_pubKeyCb := Ok pubKeyDisp
            val _ = local_PrivKey := Ok privKey
            val _ = local_amConfig := Ok (Coq_mkAmConfig compiled_fm clone_uuid aspDisp appDisp plcDisp pubKeyDisp)
            val _ = local_amLib := Ok al
        in
          ()
        end) : unit

  (* Sets the AM_Config, should not throw an exception
  : coq_AM_Config -> () *)
  fun set_AM_Config (c : coq_AM_Config) =
    let val _ = local_amConfig := Ok c
    in 
      ()
    end

(*
  (* TODO:  consider removing this setter...might be unwise to expose this interface *)
  (* Sets the AM_Library, should not throw an exception
  : coq_AM_Library -> () *)
  fun set_AM_Lib (al : coq_AM_Library) =
    let val _ = local_amLib := Ok al
    in 
      ()
    end
*)

  (* Retrieves the asp callback, or exception if not configured 
    : _ -> coq_ASPCallback *)
  fun get_ASPCallback _ =
    (
      case (!local_aspCb) of
      (Ok v) => v
      | Err e => raise Excn e) : coq_DispatcherErrors coq_ASPCallback

  (* Retrieves the plc callback, or exception if not configured 
    : _ -> coq_PlcCallback *)
  fun get_PlcCallback _ =
    (
      case (!local_plcCb) of
      (Ok v) => v
      | Err e => raise Excn e) : coq_PlcCallback

  (* Retrieves the asp callback, or exception if not configured 
    : _ -> coq_PubKeyCallback *)
  fun get_PubKeyCallback _ =
    (
      case (!local_pubKeyCb) of
      (Ok v) => v
      | Err e => raise Excn e) : coq_PubKeyCallback

  
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
    (
    let val fm = get_FormalManifest()
        val clone_uuid = get_Clone_uuid()
        val aspCb = get_ASPCallback()
        val plcCb = get_PlcCallback()
        val pubKeyCb = get_PubKeyCallback()
    in
      Coq_mkAmConfig fm clone_uuid aspCb aspCb plcCb pubKeyCb 
    end) : AM_Config

  (* Directly combines setup and get steps in one function call. 
    : coq_Manifest -> coq_AM_Library -> privateKey_t -> AM_Config *)
  fun setup_and_get_AM_config (fm : coq_Manifest) (al : coq_AM_Library) (privKey : privateKey_t) =
    (let val _ = setup_AM_config fm al privKey
      in 
        get_AM_config()
    end) : AM_Config
end